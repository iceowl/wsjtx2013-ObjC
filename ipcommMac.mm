//
//  ipcomm.m
//  wsjtx
//
//  Created by Joe Mastroianni on 8/27/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import "ipcommMac.h"
#import "common.h"


#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <md4.h>
#include <md5.h>





@implementation ipcommMac

@synthesize  shmId         = _shmId;
@synthesize  memoryKey     = _memoryKey;
@synthesize  memSize       = _memSize;
@synthesize  mem_jt9        = _mem_jt9;
@synthesize  memoryKeyString = _memoryKeyString;
@synthesize  memoryKeySeed   = _memoryKeySeed;
@synthesize  memoryKeyInt   = _memoryKeyInt;



-(id) init {
    
    self = [super init];
    if(self){
        
        [self setShmId:-1];
        [self setMemoryKeyInt:1111];
        _memoryKeyString = nil;
        
    }
    return self;
}

-(bool)create {
    @synchronized (self) {
        if(_memoryKeyString == nil) {
            [self setMyKey:[_memoryKeySeed cStringUsingEncoding:NSASCIIStringEncoding] :(int)[_memoryKeySeed length]];
            if(_memoryKeyString == nil) {
                return FALSE;
            }
        }

        [self setMemoryKey : ftok([_memoryKeyString cStringUsingEncoding:NSASCIIStringEncoding],_memoryKeyInt)];
        [self setShmId : shmget(_memoryKey, sizeof(jt9com_), IPC_CREAT | S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP |S_IWOTH | S_IROTH)];
        
        if (_shmId< 0) {
            perror("shm_open");
            return FALSE;
        }
        
        
        //NSLog(@"shm_open succeeded");
        return TRUE;
    }
}

-(void*)attach {
    @synchronized (self) {
        
        [self setMemoryKey : ftok([_memoryKeyString cStringUsingEncoding:NSASCIIStringEncoding],_memoryKeyInt)];
        
        
        [self setShmId : shmget(_memoryKey, 0, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP |S_IWOTH | S_IROTH)];
        
        
        //NSLog(@"jt9com_ is at %p",&jt9com_);
        [self setMem_jt9 : shmat(_shmId, NULL, 0)];
        long addr = 1;
        while(_mem_jt9 == MAP_FAILED){
            [self setMem_jt9 : shmat(_shmId, (const void*)addr, 0600)];
            addr++;
        }
        if (_mem_jt9 == MAP_FAILED) {
            //NSLog(@"shmid %d",_shmId);
            perror("mmap");
            return nil;
        }
        
        //memset(mem_jt9,0,sizeof(jt9com_));
        
        //NSLog(@"memory attached");
        //NSLog(@" mem_jt9 is %p",_mem_jt9);
        
        // grab the size
        shmid_ds shmid_ds;
        if (!shmctl(_shmId, IPC_STAT, &shmid_ds)) {
            [self setMemSize : (int)shmid_ds.shm_segsz];
        } else {
            perror("shmctl");
            return nil;
        }
        
        //NSLog(@"memory size %d",_memSize);
        return _mem_jt9;
    }
}



-(bool)detach {
    
    shmdt(_mem_jt9);
    [self setShmId : shmget(_memoryKey, 0, 0600)];
    struct shmid_ds shmid_ds;
    if (0 != shmctl(_shmId, IPC_STAT, &shmid_ds)) {
        switch (errno) {
            case EINVAL:
                return true;
            default:
                return false;
        }
    }
    // If there are no attachments then remove it.
    if (shmid_ds.shm_nattch == 0) {
        // mark for removal
        if (-1 == shmctl(_shmId, IPC_RMID, &shmid_ds)) {
            switch (errno) {
                case EINVAL:
                    return true;
                default:
                    return false;
            }
        }
    }
    shm_unlink([_memoryKeyString cStringUsingEncoding:NSASCIIStringEncoding]);
    //NSLog(@"memory detached:");
    return TRUE;
    
}

-(int)size {
    return _memSize ;
}


-(const void*)address {
    @synchronized (self){
        return _mem_jt9;
    }
}

-(void)initializeKey : (NSString *) memKeyPath {
    
    NSString *slash =@"/";
    NSUUID *uui = [[NSUUID alloc]init];
    [self setMemoryKeySeed : [slash stringByAppendingString:[uui UUIDString]]];

   // unsigned char result[MD4_RESULTLEN] ;
   // md4_context *ctx = new md4_context;
   // md4_update(ctx,(const unsigned char*)[_memoryKeySeed cStringUsingEncoding:NSASCIIStringEncoding], [_memoryKeySeed length]);
    //md4_final(ctx,(unsigned char*)result);
    MD5 *a5 = new MD5();
    a5->update((const unsigned char*)[_memoryKeySeed cStringUsingEncoding:NSASCIIStringEncoding], (unsigned int)[_memoryKeySeed length]);
    a5->finalize();
    NSString *keyString = [NSString stringWithCString:(a5->hexdigest()).c_str() encoding:NSASCIIStringEncoding];
    
    
    
    //int value = 0;
    
  //  for(int i = 0;i < MD4_RESULTLEN;i++){
  //      value += pow(2,i)*(int)result[i];
  //  }
    //NSString *keyString = [NSString stringWithFormat:@"%X",value];
   // NSLog(@"keyString %@",keyString);
    
    [self setMemoryKeyString : [slash stringByAppendingString: keyString]];
    //NSLog(@"memoryKeyString %@",_memoryKeyString);
    NSString *shareFile = [memKeyPath  stringByAppendingString:_memoryKeyString];
    FILE* fd = fopen([shareFile cStringUsingEncoding:NSISOLatin1StringEncoding], "w");
    if(fd == NULL) {
        perror("fopen");
        NSLog(@"set key but can't create shared mem file %@",shareFile);
    } else {
        fclose(fd);
    }
    
    //NSLog(@"memoryKey=%@",_memoryKeyString);
   // delete(ctx);
    return;
    
}
-(bool)setMyKey:(const char*) mykey : (int) mykey_len{
    
        
    [self setMemoryKeyString : [NSString stringWithCString:mykey encoding:NSASCIIStringEncoding]];
    //NSLog(@"memory key string from setMyKey %@",_memoryKeyString);
        return TRUE; 
        
}

-(void)removeSharedMemoryFile: (NSString*)memKeyPath{
    NSString *shareFile = [memKeyPath  stringByAppendingString:_memoryKeyString];
    unlink([shareFile cStringUsingEncoding:NSASCIIStringEncoding]);
}

-(void)dealloc {
    [self detach];
}



@end
