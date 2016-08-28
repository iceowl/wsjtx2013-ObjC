//
//  WSJTXAppDelegate.h
//  wsjtx
//
//  Created by Joe Mastroianni on 8/22/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import <Cocoa/Cocoa.h>
#import "common.h"
#import "ipcommMac.h"
#import "wjRecorder.h"
#import "wjPlayer.h"
#import "wideGraph.h"
#import "recIndicator.h"
#import "globalSettings.h"
#import "qsoManager.h"
#import "outputTextView.h"
#import "queueDispatcher.h"
#import "rigClass_link.h"
#import "masterClock.h"
#import "hamAlert.h"


typedef void (^ConsoleBlock)(void);

typedef struct commHdr{
    char    ariff[4];  //ChunkID:    "RIFF"
    int32_t nchunk;    //ChunkSize: 36+SubChunk2Size
    char    awave[4];  //Format: "WAVE"
    char    afmt[4];   //Subchunk1ID: "fmt "
    int32_t lenfmt;    //Subchunk1Size: 16
    int16_t nfmt2;     //AudioFormat: 1
    int16_t nchan2;    //NumChannels: 1
    int32_t nsamrate;  //SampleRate: 12000
    int32_t nbytesec;  //ByteRate: SampleRate*NumChannels*BitsPerSample/8
    int16_t nbytesam2; //BlockAlign: NumChannels*BitsPerSample/8
    int16_t nbitsam2;  //BitsPerSample: 16
    char    adata[4];  //Subchunk2ID: "data"
    int32_t ndata;     //Subchunk2Size: numSamples*NumChannels*BitsPerSample/8
} commHdr;


//globals

 //wideGraph           *waterfallGraph;
 void*                  mem_jt9;
 dispatch_source_t      aTimer;
 dispatch_source_t      cTimer;

 extern globalSettings *gSettings; //this is set up in main now.


@interface WSJTXAppDelegate : NSObject <NSApplicationDelegate> {
    
    
    IBOutlet NSTextView          *outputView;
    IBOutlet NSTextField         *playingFile;
    IBOutlet NSTextView          *programConsoleView;
    IBOutlet queueDispatcher     *qDis;
    IBOutlet qsoManager          *qManager;
    IBOutlet rigClass_link       *myRig;
    IBOutlet masterClock         *myClock;
    IBOutlet wideGraph           *waterfallGraphClass;
    
    NSTask              *jt9Task;
    NSWindow            *window;
    
    ipcommMac           *iComm;
    wjRecorder          *wRecorder;
    
    wjPlayer            *wPlayer;
    outputTextView      *oView;
    
    ConsoleBlock        cBlock;
    
    hamAlert            *hAlert;
    
    FILE* lockFile;

    struct commHdr   hdr;
    dispatch_queue_t wideGraphQueue;
        
}

@property IBOutlet  NSWindow                     *window;
@property IBOutlet  NSTextField                  *playingFile;
@property (retain)  dispatch_queue_t              wideGraphQueue;
@property           wideGraph                    *waterfallGraphClass;
@property (retain)  masterClock                  *myClock;
@property (retain)  NSString                     *lineIn;
@property (retain)  qsoManager                   *qManager;
@property (retain)  outputTextView               *oView;
@property (retain)  queueDispatcher              *qDis;
@property (retain)  NSMutableArray               *inputLines;
@property (retain)  NSImage                      *b_dot;
@property (retain)  NSImage                      *r_dot;
@property (retain)  NSTextAttachmentCell         *b_ac;
@property (retain)  NSTextAttachment             *b_at;
@property (retain)  NSTextAttachmentCell         *r_ac;
@property (retain)  NSTextAttachment             *r_at;
@property (retain)  NSMutableArray               *heardStations;
@property (retain)  NSMutableArray               *args;
@property (retain)  NSFileHandle                 *fh;
@property (retain)  NSNotificationCenter         *nc;
@property           rigClass_link                *myRig;
@property (retain)  NSTask                       *jt9Task;
@property (retain)  NSPipe                       *pipe;
@property (retain)  NSPipe                       *consolePipe;
@property (retain)  NSPipe                       *errorPipe;
@property (retain)  NSFileHandle                 *consoleFile;
@property (retain)  NSFileHandle                 *consoleFileError;
@property (retain)  NSNotificationCenter         *consoleNotification;
@property (retain)  NSString                     *memoryKeyPath;
@property (retain)  NSString                     *launchPath;
@property (retain)  NSString                     *inputWavFile;
@property (retain)  NSString                     *callListFile;


- (IBAction) getDecodeTextFromFile:(id)sender;
- (IBAction) putDecodeTextIntoFileandUseSharedMemory:(id)sender;
- (IBAction) record48SecondsAndDecode:(id)sender;
- (IBAction) showOpenPanel:(id)sender;
- (IBAction) startPlayer:(id)sender;
- (IBAction) quitPlayer:(id)sender;
- (IBAction) transmitMessage:(id)sender;
- (IBAction) testLine:(id)sender;
- (IBAction) killAllQueues:(id)sender;
- (IBAction) logQso:(id)sender;
- (id)       init;
- (bool)     setUpJt9 : (bool)doINeedToOpenFile;
- (void)     appendData:(NSData *)d;
- (void)     dataReady:(NSNotification *)n;
- (void)     taskTerminated:(NSNotification *)note;
- (void)     applicationWillTerminate:(NSNotification *)notification;
- (void)     startJt9Task;
- (bool)     setUpAndAttachSharedMemory;


@end
