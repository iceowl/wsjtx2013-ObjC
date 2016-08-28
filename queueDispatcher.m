//
//  queueDispatcher.m
//  wsjtx
//
//  Created by Joe Mastroianni on 10/5/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import "queueDispatcher.h"
#import "common.h"

@implementation queueDispatcher

@synthesize waitToRecord   = _waitToRecord;
@synthesize recordWait     = _recordWait;
@synthesize recInd         = _recInd;
@synthesize recQueue       = _recQueue;
@synthesize tickRecQueue   = _tickRecQueue;
@synthesize wPlayer        = _wPlayer;
@synthesize wRecorder      = _wRecorder;
@synthesize memoryKeyPath  = _memoryKeyPath;
@synthesize qManager       = _qManager;
@synthesize jt9Task        = _jt9Task;
@synthesize transmitButton = _transmitButton;
@synthesize monitorButton  = _monitorButton;
@synthesize myRig          = _myRig;


-(id)init {
    
    self = [super init];
    if(self){
        
        _recInd = [[recIndicator alloc]init];
        [self setRecInd:_recInd];
        [_recInd setActive:FALSE];
        [_recInd setRecording:FALSE];
        
        
        
    }
    //  NSLog(@" queueDispatcher = %@",self); // how many of me are we creating?
    
    return self;
}

-(void)awakeFromNib {
    
    [_waitToRecord setUsesThreadedAnimation:TRUE];
    [_recordWait setStringValue:@" "];
    [_recordWait setSelectable:NO];
    [_recordWait setEditable:NO];
    
}


-(void) dispatchMonitorQueue {
    
    __block bool recording = TRUE;
    gSettings.m_monitoring = !gSettings.m_monitoring;
    gSettings.m_killAll = FALSE;
    [self setRecordState:gSettings.m_monitoring : 0];
    [_monitorButton setEnabled:NO];
    if(gSettings.m_monitoring && !gSettings.m_transmitting){
        [_transmitButton setEnabled:YES];
        if(!_recQueue){
            _recQueue = dispatch_queue_create("com.owlhousetoys.mon_wsjtx", DISPATCH_QUEUE_CONCURRENT);
        }
        if(!_tickRecQueue) {
            _tickRecQueue = dispatch_queue_create("com.owlhousetoys.tick_wsjtx",DISPATCH_QUEUE_CONCURRENT);
        }
        
        //recQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        dispatch_async(_recQueue, ^(void) {
            int i1 = 0;
            while(gSettings.m_monitoring && !gSettings.m_killAll && !gSettings.m_transmitting){
                __block CFAbsoluteTime at= CFAbsoluteTimeGetCurrent();
                __block CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
                if(recording) {
                    recording = FALSE;
                    int i = 1;
                    [_waitToRecord  setDoubleValue:(double)floor(gd.second)];
                    while((i != 60) && (i != 0) && gSettings.m_monitoring && !gSettings.m_transmitting) {
                        at = CFAbsoluteTimeGetCurrent();
                        gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
                        i = floor(gd.second);
                        if(i != i1){
                            //NSLog(@" wait sec = %d",i);
                            i1 = i;
                            [_waitToRecord incrementBy:1.0];
                        }
                        usleep(100000);
                    }
                    //NSLog(@"escaped");
                    
                    if(gSettings.m_monitoring && !gSettings.m_killAll && !gSettings.m_transmitting){
                        [self setRecordState:gSettings.m_monitoring : 1];
                        if(jt9com_.nsave)[_wRecorder startRecording];
                        [_transmitButton setEnabled:NO];
                        void (^onTick)() = ^{
                            int i1 = 0;
                            int i = 0;
                            while((i <= 48) && gSettings.m_monitoring && !gSettings.m_transmitting && !gSettings.m_killAll) {
                                at = CFAbsoluteTimeGetCurrent();
                                gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
                                i = floor(gd.second);
                                if(i != i1){
                                    //NSLog(@" wait sec = %d",i);
                                    i1 = i;
                                    [_waitToRecord incrementBy:1.0];
                                }
                                usleep(100000);
                            }
                            if(!gSettings.m_monitoring || gSettings.m_killAll) {
                                //    NSLog(@"onTick hit");
                                [self setRecordState:FALSE :0];
                            } else {
                                //  NSLog(@"onTick hit");
                                [_wRecorder killRecorder : FALSE];
                                [self setRecordState:TRUE : 0];
                                //    NSLog(@"copied %d bytes to jt9com_.d2", jt9com_.kin * 2);
                                [self setUpJt9];
                                if(gSettings.m_qsoInProgress) [self dispatchTransmitQueue];
                            }
                            recording = TRUE;
                            [_transmitButton setEnabled:YES];
                        };
                        
                        dispatch_async(_tickRecQueue,^(void){onTick();});
                    }
                    usleep(100000);
                }
                usleep(50000);
            }
        });
    }
}


-(void)dispatchTransmitQueue {
    
    
    // m_tx2QSO = TRUE; // set this = TRUE if you want to decode your own transmissions
    
    if(gSettings.m_transmitting){
        //[self killAllViaTransmitQueue];
        gSettings.m_transmitting = FALSE;
        gSettings.m_monitoring = FALSE;
        [_transmitButton setEnabled:NO];
        [_monitorButton setEnabled:YES];
        [self dispatchMonitorQueue];
        return;
    }
    
    [_transmitButton setEnabled:YES];
    [self setM_killAll:FALSE];
    
    if(gSettings.m_monitoring) {
        gSettings.m_transmitting = TRUE;
    } else {
        gSettings.m_transmitting = !gSettings.m_transmitting;
    }
    
    [self setRecordState:gSettings.m_transmitting : 0];
    if(!gSettings.m_transmitting) {
        gSettings.m_monitoring = FALSE;
        [self setM_qsoInProgress:FALSE];
        // [self dispatchMonitorQueue];
    }
    
    if(gSettings.m_transmitting){
        
        [_monitorButton setEnabled:NO];
        
        if(!_recQueue){
            _recQueue = dispatch_queue_create("com.owlhousetoys.mon_wsjtx", DISPATCH_QUEUE_CONCURRENT);
        }
        if(!_tickRecQueue) {
            _tickRecQueue = dispatch_queue_create("com.owlhousetoys.tick_wsjtx",DISPATCH_QUEUE_CONCURRENT);
        }
        
       
        
        
        dispatch_async(_recQueue, ^(void) {
            
            
            __block CFAbsoluteTime at= CFAbsoluteTimeGetCurrent();
            __block CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
            if(gSettings.m_transmitting) {
                int i = 1;
                int i1 = 0;
                [_waitToRecord  setDoubleValue:(double)floor(gd.second)];
                [self setRecordState:TRUE :4];
                while((i != 60) && (i != 0) && gSettings.m_transmitting) {
                    at = CFAbsoluteTimeGetCurrent();
                    gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
                    i = floor(gd.second);
                    if(i != i1){
                        //     NSLog(@" wait sec = %d",i);
                        i1 = i;
                        [_waitToRecord incrementBy:1.0];
                    }
                    usleep(100000);
                }
                
                if(gSettings.m_transmitting){
                    [_qManager generateTonesForMessage];
                    if(gSettings.m_sent73 || gSettings.m_sendCall)[_wPlayer morse:gSettings.m_myCall];
                    [_myRig clickPttOn];
                    [_wPlayer initializePlayer:NULL : FALSE];
                    [self setRecordState:gSettings.m_transmitting : 3];
                    void (^onTick2)() = ^{
                        int i = 0;
                        int i1 = 0;
                        while((i <= 48) && gSettings.m_transmitting && !gSettings.m_killAll) {
                            at = CFAbsoluteTimeGetCurrent();
                            gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
                            i = floor(gd.second);
                            if(i != i1){
                                //NSLog(@" wait sec = %d",i);
                                i1 = i;
                                [_waitToRecord incrementBy:1.0];
                            }
                            usleep(100000);
                        }
                        while(_wPlayer.thePlayer->cwTime && !gSettings.m_killAll && gSettings.m_morseNext && gSettings.m_transmitting){
                            usleep(100000);
                        }//wait while morse goes;
                        gSettings.m_morseNext = FALSE;
                        [_wPlayer quitPlayer];
                        [_myRig clickPttOff];
                        //NSLog(@"onTick2 hit");
                        if(!gSettings.m_transmitting) {
                            [self setRecordState:FALSE :0];
                        } else {
                            [self setRecordState:TRUE : 2];
                        }
                        
                        
                        [self setM_monitoring: FALSE];
                        [_monitorButton setEnabled:YES];
                        [self setM_transmitting:FALSE];
                        if(gSettings.m_qsoInProgress) [_qManager toggleXmitSequence];
                        if(gSettings.m_sent73) [self setM_qsoInProgress:FALSE];
                        if(!gSettings.m_killAll) {
                            //  [_transmitButton setEnabled:NO];
                            //  [_monitorButton setEnabled:YES];
                            gSettings.m_monitoring = FALSE;
                            
                            [_qManager postTransmittedLines];
                            if(gSettings.m_tx2QSO) {
                                [_wRecorder killRecorder : FALSE];
                                [self setUpJt9];
                            }
                            [self dispatchMonitorQueue];
                        }
                    };
                    dispatch_async(_tickRecQueue,^(void){onTick2();});
                    
                }
            }
        });
        
    }
}

-(void)killAllViaTransmitQueue {
    
    [self setM_monitoring:FALSE];
    [self setM_transmitting:FALSE];
    [self setM_qsoInProgress:FALSE];
    [self setM_killAll:TRUE];
    [self setRecordState:FALSE :0];
    [_qManager abortTransmit];
    [_monitorButton setEnabled:YES];
    
}


-(void) setRecordState : (bool) onOff : (int) recWait {
    
    [_recInd setActive:onOff];
    
    
    if(!onOff && recWait == 0){
        [_waitToRecord setDoubleValue:0.0];
        [_waitToRecord stopAnimation:self];
        [_recordWait setStringValue:@""];
    }
    
    if(onOff && (recWait == 0)){
        [_waitToRecord startAnimation:self];
        [_recordWait setStringValue:@"RecWait"];
        [_recInd setRecording:FALSE];
        [_recInd setTransmitting:FALSE];
        
    } else if(onOff && (recWait == 1)){
        [_waitToRecord setDoubleValue:12.0];
        [_recordWait setStringValue:@"Recording"];
        [_recInd setRecording:TRUE];
        [_recInd setTransmitting:FALSE];
        
    } else if(onOff && (recWait == 2)){
        [_waitToRecord startAnimation:self];
        [_recInd setRecording:FALSE];
        [_recInd setTransmitting:FALSE];
        [_recordWait setStringValue:@"Waiting"];
        
    } else if(onOff && (recWait == 3)) {
        [_recInd setTransmitting:TRUE];
        [_recInd setRecording:FALSE];
        [_waitToRecord setDoubleValue:12.0];
        [_recordWait setStringValue:@"Transmitting"];
        
    }  else if(onOff && (recWait == 4)) {
        [_waitToRecord startAnimation:self];
        [_recordWait setStringValue:@"TrWait"];
        [_recInd setRecording:FALSE];
        [_recInd setTransmitting:FALSE];
    }
    
}

-(void) setM_monitoring :(BOOL)x{
    gSettings.m_monitoring = x;
}

-(void)setM_transmitting :(BOOL)x {
    gSettings.m_transmitting = x;
}

-(void)setM_qsoInProgress :(BOOL)x {
    [_qManager setM_qsoInProgress:x];
}

-(void) setM_killAll : (BOOL)x {
    gSettings.m_killAll  = x;
}

-(bool)setUpJt9 {
    
    
    
    CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
    CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
    
    int imin = gd.minute;
    int ihour = gd.hour*100;
    jt9com_.nutc = imin+ihour;
    jt9com_.ndiskdat  =1;
    jt9com_.newdat    =1;
    jt9com_.nagain    =0;
    jt9com_.ntrperiod =1;
    jt9com_.ndepth    =1;
    jt9com_.nfqso     =1500;
    jt9com_.ntol      =3;
    jt9com_.ntxmode   =65;
    jt9com_.nmode     =9+65;
    jt9com_.nfa       =1000; //2700
    jt9com_.nfb       =5000;   //5000;
    jt9com_.nzhsym    =173;
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dfTime = [NSDateFormatter new];
    [dfTime setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSString *time = [dfTime stringFromDate:date];
    strncpy(jt9com_.datetime,[time cStringUsingEncoding:NSASCIIStringEncoding],20);
    
    if(mem_jt9 != NULL){
        memcpy(mem_jt9,&jt9com_,sizeof(jt9com_));
        
    } else {
        NSLog(@"queue dispatcher finds mem_jt9 is NULL - killall");
        [_jt9Task interrupt];
        [self setM_qsoInProgress:FALSE];
        [self setM_monitoring:FALSE];
        [self setM_transmitting:FALSE];
        return FALSE;
    }
    NSString *lockFilePath = [_memoryKeyPath stringByAppendingString: @"/.lock"];
    unlink([lockFilePath cStringUsingEncoding:NSASCIIStringEncoding]);
    //NSLog(@"Killed lock file");
    //lock file recreated by intercepting <DecodeFinished> in the stdio pipe in main
    
    return TRUE;
}





@end
