//
//  queueDispatcher.h
//  wsjtx
//
//  Created by Joe Mastroianni on 10/5/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import <Foundation/Foundation.h>
#import "recIndicator.h"
#import "externSettings.h"
#import "wjPlayer.h"
#import "wjRecorder.h"
#import "qsoManager.h"
#import "rigClass_link.h"


extern void* mem_jt9;

@interface queueDispatcher : NSObject {
    
}

@property (retain)  IBOutlet NSProgressIndicator *waitToRecord;
@property (retain)  IBOutlet NSTextField         *recordWait;
@property (retain)  IBOutlet recIndicator        *recInd;
@property (retain)  dispatch_queue_t              recQueue;
@property (retain)  dispatch_queue_t              tickRecQueue;
@property (retain)  wjPlayer                     *wPlayer;
@property (retain)  wjRecorder                   *wRecorder;
@property (retain)  NSString                     *memoryKeyPath;
@property (retain)  IBOutlet qsoManager          *qManager;
@property (retain)  NSTask                       *jt9Task;
@property (retain)  IBOutlet NSButton            *monitorButton;
@property (retain)  IBOutlet NSButton            *transmitButton;
@property           IBOutlet rigClass_link       *myRig;


-(void)dispatchMonitorQueue;
-(void)dispatchTransmitQueue;
-(void)killAllViaTransmitQueue;

@end
