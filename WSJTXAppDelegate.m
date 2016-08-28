//
//  WSJTXAppDelegate.m
//  wsjtx
//
//  Created by Joe Mastroianni on 8/22/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import "WSJTXAppDelegate.h"
#include "common.h"
#import "MLog.h"


@implementation WSJTXAppDelegate

@synthesize window;
@synthesize wideGraphQueue = _wideGraphQueue;
@synthesize lineIn         = _lineIn;
@synthesize qManager       = _qManager;
@synthesize oView          = _oView;
@synthesize qDis           = _qDis;
@synthesize inputLines     = _inputLines;
@synthesize b_dot          = _b_dot;
@synthesize r_dot          = _r_dot;
@synthesize b_ac           = _b_ac;
@synthesize b_at           = _b_at;
@synthesize r_ac           = _r_ac;
@synthesize r_at           = _r_at;
@synthesize playingFile    = _playingFile;
@synthesize waterfallGraphClass = _waterfallGraphClass;
@synthesize myRig          = _myRig;
@synthesize myClock        = _myClock;
@synthesize heardStations  = _heardStations;
@synthesize args           = _args;
@synthesize fh             = _fh;
@synthesize nc             = _nc;
@synthesize jt9Task        = _jt9Task;
@synthesize pipe           = _pipe;
@synthesize consolePipe    = _consolePipe;
@synthesize errorPipe      = _errorPipe;
@synthesize memoryKeyPath  = _memoryKeyPath;
@synthesize launchPath     = _launchPath;
@synthesize inputWavFile   = _inputWavFile;
@synthesize callListFile   = _callListFile;
@synthesize consoleFile    = _consoleFile;
@synthesize consoleFileError    = _consoleFileError;
@synthesize consoleNotification = _consoleNotification;



-(id) init {
    self = [super init];
    if(self){
        
        hAlert = [[hamAlert alloc] init];
        [self startConsole];
        
        //gSettings = [[globalSettings alloc] init]; // global vars now set up in main.m // initialize global vars
        
        _inputWavFile = @"/Library/Application Support/wsjtx/jt9_exe/out.wav";
        _memoryKeyPath  = @"/Library/Application Support/wsjtx/jt9_exe";
        _launchPath      = @"/jt9";
        
        _heardStations = [[NSMutableArray alloc] init];
        [self initAllFiles];
        
        _inputLines = [[NSMutableArray alloc] initWithCapacity:30];
        
        // **IPComm initialize
        
        iComm = [[ipcommMac alloc] init];
        
        [iComm initializeKey : _memoryKeyPath];
        [self setUpAndAttachSharedMemory];
        //*recorder initialize
        
        wRecorder = [[wjRecorder alloc]init];
        [wRecorder initializeRecorder];
        
        wPlayer = [[wjPlayer alloc] init];
        
        _lineIn = @" ";
        
        mem_jt9 = NULL;
        
        _b_dot = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blue-dot" ofType:@"png"]];
        _b_ac = [[NSTextAttachmentCell alloc] initImageCell:_b_dot];
        _b_at = [[NSTextAttachment alloc] init];
        [_b_at setAttachmentCell: _b_ac ];
        _r_dot = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"red-dot" ofType:@"png"]];
        _r_ac = [[NSTextAttachmentCell alloc] initImageCell:_r_dot];
        _r_at = [[NSTextAttachment alloc] init];
        [_r_at setAttachmentCell: _r_ac ];
        
        
        
        // _myRig = [[rigClass_link alloc]init]; // be careful RIG is currently set up in IBOutlet and directly connected to queue dispatcher
        
        
    }
    return self;
}




-(void)awakeFromNib {
    
    
    [self setupQueueDispatcher];
    [_qManager setWPlayer:wPlayer];
    [_qManager setHeardStations:_heardStations];
    [_playingFile setSelectable:NO];
    [_playingFile setEditable:NO];
    
    [self setValue:[NSNumber numberWithInt:0] forKey:@"m_saveAll"];
    [self valueForKey:@"m_saveAll"];
    
    
    
}

-(void)initAllFiles {
    
    
    NSMutableString *finalPath = [[NSMutableString alloc] initWithString:NSHomeDirectory()];
    [finalPath appendString:_memoryKeyPath];
    _memoryKeyPath = [[NSString alloc] initWithString:finalPath]; // this is the home directory with the memoryKeyPath appended, which gives the explicit location
    
    NSString* logFile= @"/wsjtx_callList.log";//file path...
    // NSString* fileRoot = [[NSBundle mainBundle]
    //          pathForResource:filePath ofType:@"txt"];
    
    
    // MLogString(@"log file = %@",fileRoot);
    [finalPath appendString:logFile]; // append the log file name to final path to give the log file path
    _callListFile = [[NSString alloc]initWithString:finalPath];
    
    NSString *fileContents;
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:_callListFile]) {
        fileContents =
        [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"" ofType:@"txt"]
                                  encoding:NSUTF8StringEncoding error:nil];
        [[NSFileManager defaultManager] createFileAtPath:_callListFile contents:[fileContents dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];
    } else {
        fileContents =
        [NSString stringWithContentsOfFile:_callListFile
                                  encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSArray *hs =
    [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet characterSetWithCharactersInString:@";"]];
    
    
    
    
    for (int i=0; i<[hs count]; i++) {
        [_heardStations addObject:[hs objectAtIndex:i]];
    }
    
    NSString *jt9Path = [[NSBundle mainBundle] pathForResource:@"jt9" ofType:@""];
    _launchPath = jt9Path;
    
    
    //_launchPath = [_memoryKeyPath stringByAppendingString:_launchPath];
    
   // MLogString(@"launch path = %@",_launchPath);
    
    BOOL exists = FALSE;
    [[NSFileManager defaultManager] fileExistsAtPath:_memoryKeyPath isDirectory:&exists];
    if(!exists){
        NSError *error;
        [[NSFileManager defaultManager]
                        createDirectoryAtPath:_memoryKeyPath
                        withIntermediateDirectories:YES
                        attributes:nil
                        error:&error];
        if(error) {
            [hAlert raiseAlert:[error localizedDescription] :@"error setting up call list file path"];
            MLogString(@"%@",[error localizedDescription]);
        }
    }
    
    gSettings.m_saveDir = _memoryKeyPath;
    
}


-(void)setupQueueDispatcher {
    [_qDis setWPlayer:wPlayer];
    [_qDis setWRecorder:wRecorder];
    [_qDis setMemoryKeyPath:_memoryKeyPath];
}


-(IBAction)transmitMessage:(id)sender {
    
    // [_qManager generateTonesForMessage];
    [self setUpAndAttachSharedMemory];
    [_qDis dispatchTransmitQueue];
    
}


-(IBAction)startPlayer:(id)sender {
    [wPlayer initializePlayer : _inputWavFile : TRUE];
    [_playingFile setStringValue:_inputWavFile];
}

-(IBAction)quitPlayer:(id)sender {
    [wPlayer quitPlayer];
    [_playingFile setStringValue:@""];
    
}

-(IBAction)killAllQueues:(id)sender {
    [_qDis killAllViaTransmitQueue];
}



-(IBAction)sendCallAfterNextTransmission:(id)sender {
    
    gSettings.m_sendCall = TRUE;
    [_qManager informSign];
}


-(bool)setUpJt9: (bool) doINeedToOpenFile {
    
    
    if(doINeedToOpenFile){
        memset(jt9com_.d2,0,NTMAX*12000);
        jt9com_.nutc=0;
        NSRange i0=[_inputWavFile rangeOfString:@".wav"];
        NSRange r1;
        NSRange r2;
        r1.location = i0.location-4;
        r2.location = i0.location-2;
        r1.length = r2.length = 2;
        NSString *s1 = [NSString stringWithString:[_inputWavFile substringWithRange:r1]];
        NSString *s2 = [NSString stringWithString:[_inputWavFile substringWithRange:r2]];
        if(i0.location > 0){
            jt9com_.nutc = 100 * [s1 intValue] + [s2 intValue];
        }
    } else {
        CFAbsoluteTime atc = CFAbsoluteTimeGetCurrent();
        CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(atc, NULL);
        
        int imin = gd.minute;
        int ihour = gd.hour*100;
        jt9com_.nutc = imin+ihour;
    }
    jt9com_.ndiskdat  =1;
    jt9com_.newdat    =1;
    jt9com_.nagain    =0;
    jt9com_.ntrperiod =1;
    jt9com_.ndepth    =1;
    jt9com_.nfqso     =1500;
    jt9com_.ntol      =3;
    jt9com_.ntxmode   =65;
    jt9com_.nmode     =gSettings.m_mode; // =65 or 9 or 9+65
    jt9com_.nfa       =100;// used to be 1000 and before that 2700
    jt9com_.nfb       =5000;   //5000;
    jt9com_.nzhsym    =173;
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dfTime = [NSDateFormatter new];
    [dfTime setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSString *time = [dfTime stringFromDate:date];
    strncpy(jt9com_.datetime,[time cStringUsingEncoding:NSASCIIStringEncoding],20);
    
    int npts = (jt9com_.ntrperiod*48)*12000;
    //int npts = NTMAX*12000;
    
    // Read (and ignore) a 44-byte WAV header; then read data
    if(doINeedToOpenFile) {
        FILE* myFile = fopen([_inputWavFile cStringUsingEncoding:NSASCIIStringEncoding],"rb");
        if(myFile == NULL){
            [hAlert raiseAlert:@"error opening file" :_inputWavFile];
            MLogString(@"error opening file %@", _inputWavFile);
            return FALSE;
        }
        
        size_t n = fread(&hdr,1,44,myFile);
        
        if( n  == -1){
            MLogString(@"failure to read 44 bytes from file");
            jt9com_.newdat = 2;
            return FALSE;
        } else {
            //  MLogString(@" read %zd bytes",n);
        }
        // jt9com_.npts8 = hdr.ndata;
        n = fread(&(jt9com_.d2),2,npts,myFile);
        
        if(n == -1 ) {
            MLogString(@"failure to read %d points from file", npts);
            return FALSE;
        } else {
            //  MLogString(@"read %zd bytes",n*2);
        }
        if(fclose(myFile) == -1) {
            MLogString(@"Error closing file %@",_inputWavFile);
            jt9com_.newdat = 2;
            return FALSE;
        }
       // MLogString(@"Sound file opened and read %ld points into shared memory",n);
    }
    
    if(mem_jt9 != NULL){
        memcpy(mem_jt9,&jt9com_,sizeof(jt9com_));
        
    } else {
        [hAlert raiseAlert:@"mem_jt9 is NULL stopping" :@""];
      //  MLogString(@"mem_jt9 is NULL - stopping");
        [_jt9Task interrupt];
        return FALSE;
    }
    NSString *lockFilePath = [_memoryKeyPath stringByAppendingString: @"/.lock"];
    unlink([lockFilePath cStringUsingEncoding:NSASCIIStringEncoding]);
    //MLogString(@"Killed lock file");
    //lock file recreated when <DecodeFinished> tag is received by Jt9
    
    return TRUE;
}


-(IBAction)putDecodeTextIntoFileandUseSharedMemory:(id)sender{
    
    
    if([self setUpAndAttachSharedMemory]) {
        [self startJt9Task];
        [self setUpJt9:TRUE];
    } else {
        [hAlert raiseAlert:@"failed to set up and attach shared memory" :@""];
        MLogString(@"failed to set up and attach shared memory");
    }
    
    
}

- (IBAction)getDecodeTextFromFile:(id)sender
{
    
    NSString *TRPeriod = [NSString stringWithFormat:@"%@", @"1"];
    NSString *depth = [NSString stringWithFormat:@"%@",@"1"];
    NSString *TRLength = [NSString stringWithFormat:@"%@",@"1500"];
    //NSString *fl = [NSString stringWithFormat:@"%@",@"/Applications/WSJT-X/save/130821_0201.wav"];
    
    _args = [NSMutableArray arrayWithObjects:TRPeriod, depth, TRLength,_inputWavFile, nil];
    [self startJt9Task];
    
}

-(void) startJt9Task {
    // Is the task running?
    if (_jt9Task) {
        // [jt9Task interrupt];
        return;
    }
    
    _jt9Task = [[NSTask alloc] init];
    [_jt9Task setLaunchPath:_launchPath];
    [_jt9Task setCurrentDirectoryPath:_memoryKeyPath];
    [_jt9Task setArguments:_args];
    
    // Create a new pipe
    _pipe = [[NSPipe alloc] init];
    [_jt9Task setStandardOutput:_pipe];
    
    _fh = [_pipe fileHandleForReading];
    
    if(_nc == nil) {
        _nc = [NSNotificationCenter defaultCenter];
        [_nc removeObserver:self];
    }
    
    
    [_nc addObserver:self
            selector:@selector(dataReady:)
                name:NSFileHandleReadCompletionNotification
              object:_fh];
    
    [_nc addObserver:self
            selector:@selector(taskTerminated:)
                name:NSTaskDidTerminateNotification
              object:_jt9Task];
    
    [_jt9Task launch];
    
    [outputView setString:@""];
    
    [_fh readInBackgroundAndNotify];
    
    [_qDis setJt9Task:_jt9Task];
    
    
}

-(void)startConsole {
    
 
    
    _consolePipe = [[NSPipe alloc]init];
    _errorPipe   = [[NSPipe alloc]init];
    _consoleFile = [_consolePipe fileHandleForReading];
    _consoleFileError = [_errorPipe fileHandleForReading];
    dup2([[_consolePipe fileHandleForWriting] fileDescriptor], fileno(stdout));
    dup2([[_errorPipe fileHandleForWriting] fileDescriptor], fileno(stderr));
    
    if(_nc == nil) {
        _nc = [NSNotificationCenter defaultCenter];
        [_nc removeObserver:self];
    }
    [_nc addObserver:self
            selector:@selector(consoleDataReady:)
                name: NSFileHandleReadCompletionNotification
              object:_consoleFile];
    
    [_nc addObserver:self
            selector:@selector(consoleDataReady:)
                name: NSFileHandleReadCompletionNotification
              object:_consoleFileError];
    [_consoleFile readInBackgroundAndNotify];
    [_consoleFileError readInBackgroundAndNotify];
    fflush(stderr);
    fflush(stdout);
    MLogString(@"Console Window Started:");
    
}



- (void)appendData:(NSData *)d
{
    NSString *nline = @"\n";
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSRange r = [s rangeOfString:@"<DecodeFinished>"];
    // NSTextStorage *ts = [outputView textStorage];
    
    if((r.location) != NSNotFound){
        NSString *lockFilePath = [_memoryKeyPath stringByAppendingString: @"/.lock"];
        //MLogString(@"created lock file = %@", lockFilePath);
        lockFile = fopen([lockFilePath cStringUsingEncoding:NSASCIIStringEncoding], "w");
        if(lockFile == NULL){
            perror("fopen");
            [hAlert raiseAlert:@"cant create Lock File" :lockFilePath];
            MLogString(@"cant create lock file");
        }
        fclose(lockFile);
        [self printHeardSignals];
        
    } else {
        _lineIn = [_lineIn stringByAppendingString:s];
        NSRange r1 = [s rangeOfString:nline];
        if(r1.location != NSNotFound){
            [_inputLines addObject:_lineIn];
            
            _lineIn = @" ";
            
        }
        
    }
    
}

-(IBAction)logQso:(id)sender{
    //    NSString* filePath = @"";//file path...
    //    NSString* fileRoot = [[NSBundle mainBundle]
    //                          pathForResource:filePath ofType:@"txt"];
    if(gSettings.m_hisCall) {
        
        for(int i=0;i < [_heardStations count]; i++){
            if([[_heardStations objectAtIndex:i] isEqualToString:gSettings.m_hisCall]) {
                [_qManager informLog:TRUE];
                return;
            }
        }
        
        
        NSFileHandle *logFile = [NSFileHandle fileHandleForWritingAtPath:_callListFile];
        NSMutableString *newCall = [[NSMutableString alloc]init];
        [newCall appendString:gSettings.m_hisCall];
        [newCall appendString:@";"];
        [logFile seekToEndOfFile];
        [logFile writeData:[newCall dataUsingEncoding:NSASCIIStringEncoding]];
        // [gSettings.m_hisCall writeToFile:fileRoot atomically:YES encoding:NSASCIIStringEncoding error:Nil]; // this will overwrite the file... not good.
        [logFile closeFile];
        [_heardStations addObject:[NSString stringWithString:gSettings.m_hisCall]]; // will this create a memory leak???
        [_qManager informLog : FALSE];
    }
    return;
}

-(IBAction)testLine:(id)sender {
    NSString *sm = [[NSString alloc] initWithFormat:@"%@",[_qManager.theMessage stringValue]];
    [_inputLines addObject:sm];
    [self printHeardSignals];
    [_qManager testLine];
}

-(void) printHeardSignals {
    
    NSTextStorage *ts = [outputView textStorage];
    NSString *cqs = @" CQ ";
    bool  isOnMyFreq = FALSE;
    for(int i=0;i<[_inputLines count];i++){
        NSRange r = [[_inputLines objectAtIndex:i] rangeOfString:cqs];
        NSRange r1 = [[_inputLines objectAtIndex:i] rangeOfString:gSettings.m_myCall];
        isOnMyFreq = [_qManager.theSequencer determineIfThisIsOnMyFrequency:[_inputLines objectAtIndex:i]];
        if((r.location != NSNotFound) && !(isOnMyFreq && gSettings.m_qsoInProgress)){
            NSAttributedString *s2 = [NSAttributedString attributedStringWithAttachment:_b_at]; //add blue dot cell if there's a CQ in this line
            [ts replaceCharactersInRange:NSMakeRange([ts length], 0)
                    withAttributedString:s2];
            
        } else if ((r1.location != NSNotFound) || (isOnMyFreq && gSettings.m_qsoInProgress)) {
            NSAttributedString *s2 = [NSAttributedString attributedStringWithAttachment:_r_at]; //add red dot cell if there's my Call in this line
            [ts replaceCharactersInRange:NSMakeRange([ts length], 0)
                    withAttributedString:s2];
            if(gSettings.m_hisCall != nil) {
                NSRange r2 = [[_inputLines objectAtIndex:i] rangeOfString:gSettings.m_hisCall];
                if(r2.location != NSNotFound) { // we just received a communication - log it in the QV view
                    [_qManager addReceivedQSOLine : [_inputLines objectAtIndex:i]];
                    if(gSettings.m_qsoInProgress && !gSettings.m_transmitting){
                        [_qManager.theSequencer toggleXmitSequence];
                        [self transmitMessage:self];
                    } // if this was a communication to us we have 12 seconds to respond if m_qsoInProgress was set by qsoManager make sure the transmit queue is ready to go
                }
            }
            
        } else {
            [ts replaceCharactersInRange:NSMakeRange([ts length], 0)
                              withString:@"   " ];
        }
        
        [ts replaceCharactersInRange:NSMakeRange([ts length], 0)
                          withString:[_inputLines objectAtIndex:i]];
        
    }
    [ts replaceCharactersInRange:NSMakeRange([ts length], 0)
                      withString:@"\n   ------------ \n   \n"];
    [_qManager parseAllInputLinesAndBuildDictionary:_inputLines];
    [_inputLines removeAllObjects];
    [outputView scrollToEndOfDocument:self];
}

-(void)consoleDataReady:(NSNotification*)n {
    if(programConsoleView) {
        NSData *d;
        d = [[n userInfo] valueForKey:NSFileHandleNotificationDataItem];
        if([d length]) {
            [self appendConsoleData:d];
        }
        
        [_consoleFile readInBackgroundAndNotify];
        [_consoleFileError readInBackgroundAndNotify];
        fflush(stdout);
        fflush(stderr);
    }
}

-(void)appendConsoleData:(NSData*) d {
    NSString      *s  = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSTextStorage *tsPCV = [programConsoleView textStorage];
    [tsPCV replaceCharactersInRange:NSMakeRange([tsPCV length], 0)
                         withString:s];
    [programConsoleView needsDisplay];
}


- (void)dataReady:(NSNotification *)n
{
    NSData *d;
    d = [[n userInfo] valueForKey:NSFileHandleNotificationDataItem];
	
    //MLogString(@"dataReady:%ld bytes", (unsigned long)[d length]);
    
	if ([d length]) {
        [self appendData:d];
    }
    
	// If the task is running, start reading again
    if (_jt9Task)
        [[_pipe fileHandleForReading] readInBackgroundAndNotify];
}

- (void)taskTerminated:(NSNotification *)note
{
    
    //[iComm detach];
    [hAlert raiseAlert:@"jt9 task terminated" :@" "];
    MLogString(@"taskTerminated:");
	_jt9Task = nil;
    _pipe = nil;
    _fh = nil;
    _nc = nil;
	//[goButton setState:0];
}

-(void)applicationWillTerminate:(NSNotification *)notification {
    [_waterfallGraphClass killWaterfallTimer];
    [_myClock killClockTimer];
    [wRecorder killRecorder:TRUE];
    [wPlayer quitPlayer];
    if(_jt9Task) [_jt9Task interrupt];
    [iComm detach];
    [iComm removeSharedMemoryFile:_memoryKeyPath];
    _jt9Task = nil;
    _pipe = nil;
    // dispatch_source_cancel(consoleTimer);
}

-(bool) setUpAndAttachSharedMemory {
    
    if(!mem_jt9) {
        NSString *selectS = [NSString stringWithFormat:@"%@", @"-s"];
        _args = [NSMutableArray arrayWithObjects:selectS,iComm.memoryKeyString, _memoryKeyPath,nil];
        
        //MLogString(@"memory Key String from Main %@",iComm.memoryKeyString);
        NSString *lockFilePath = [_memoryKeyPath stringByAppendingString: @"/.lock"];
        //MLogString(@"lock file = %@", lockFilePath);
        lockFile = fopen([lockFilePath cStringUsingEncoding:NSASCIIStringEncoding], "w");
        if(lockFile == NULL){
            perror("fopen");
            [hAlert raiseAlert:@"cant create lock file" :lockFilePath];
            MLogString(@"cant create lock file");
        } else {
            fclose(lockFile);
            //MLogString(@"create/attach shared memory ");
            
            if([iComm create]){
                if((mem_jt9 = [iComm attach]) != NULL){
                    [self startJt9Task];
                    return TRUE;
                    
                }else {
                    [hAlert raiseAlert:@"shared memory = NULL" :@"shutting down jt9 task"];
                    MLogString(@"shared memory == NULL shutting down jt9 task");
                    [_jt9Task interrupt];
                    _jt9Task = nil;
                    _pipe = nil;
                    return FALSE;
                }
            }
        }
        
    }
    if(!_jt9Task) [self startJt9Task];
    
    return TRUE;
}

-(IBAction)record48SecondsAndDecode:(id)sender{
    //[self dispatchMonitorQueue];
    if([self setUpAndAttachSharedMemory]){
        [_qDis dispatchMonitorQueue];
    } else {
        [hAlert raiseAlert:@"failed to set up shared memory" :@" "];
        MLogString(@"failed to set up shared memory");
    }
    
}


-(IBAction)showOpenPanel:(id)sender {
    NSArray *fileTypes = NULL;
    __block NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:fileTypes];
    [panel beginSheetModalForWindow:window  completionHandler:^(NSInteger result) {
        
        if(result == NSOKButton){
            NSArray *a = [panel URLs];
            NSURL *b = [a objectAtIndex:0];
            _inputWavFile = [[NSString alloc] initWithString:[b relativePath]];
        }
        
    }];
}


-(void)dealloc {
    
    [wRecorder killRecorder:TRUE];
    if(_jt9Task != nil){
        [_jt9Task interrupt];
    }
    if(iComm)[iComm removeSharedMemoryFile:_memoryKeyPath];
    
}


-(BOOL)m_transmitting {
    return gSettings.m_transmitting;
}

-(int) m_saveAll {
    return gSettings.m_saveAll;
}

-(void)setM_transmitting : (BOOL) inTransmitting {
    gSettings.m_transmitting = inTransmitting;
}

-(void) setM_saveAll : (int) inSave {
    gSettings.m_saveAll = inSave;
    jt9com_.nsave = inSave;
}


-(void) dispatchConsoleReadLoop {
    
}

@end


