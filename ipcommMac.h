//
//  ipcomm.h
//  wsjtx
//
//  Created by Joe Mastroianni on 8/27/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//








#ifndef __wsjtx__ipcomm__
#define __wsjtx__ipcomm__


#import <Cocoa/Cocoa.h>
//#define NSMAX 1365
#define NSMAX 6827
#define NTMAX 120
    


@interface  ipcommMac : NSObject {
    
}


@property          int      shmId;
@property          int      memSize;
@property          void     *mem_jt9;
@property          key_t    memoryKey;
@property          key_t    memoryKeyInt;
@property (nonatomic,retain) NSString *memoryKeyString;
@property (nonatomic,retain) NSString *memoryKeySeed;



-(bool)        create;
-(void*)       attach;
-(bool)        detach;
-(const void*) address;
-(int)         size;
-(bool)        setMyKey :(const char*) myKey :(int) myKeyLen;
-(void)        initializeKey : (NSString*)memKeyPath;
-(void)        removeSharedMemoryFile :(NSString*)memKeyPath;


 
@end
 

#endif /* defined(__wsjtx__ipcomm__) */

