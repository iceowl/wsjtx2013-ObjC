//
//  wjPlayer.h
//  wsjtx
//
//  Created by Joe Mastroianni on 9/27/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include "externSettings.h"
#include "wjRecorder.h"

#define INPUTDATASIZE 12000 * 60

typedef struct MyWavePlayer
{
	AudioUnit   outputUnit;
	int         startingFrameCount;
    int         totalDataPoints;
    short       *inputData;
    bool        imDone;
    bool        running;
    bool        cwTime;
    int         dnsps;
    int         nsym;
    int         ntxFreq;
    int         xit;
    int         ntrPeriod;
    int         *generatedTones;
    int         cwMax;
    uint8       *cwDat;
    
} MyWavePlayer;

extern void genjt9_(char* msg, int* ichk, char* msgsent, int *itone,
             int* itext, int len1, int len2);

extern void gen65_(char* msg, int* ichk, char* msgsent, int *itone,
            int* itext, int len1, int len2);
extern void CheckError(OSStatus error, const char *operation);



@interface wjPlayer : NSObject {
    
    dispatch_queue_t         playQueue;
    AudioStreamBasicDescription _audioFormat;
 //   AudioQueueBufferRef	buffers[kNumberPlaybackBuffers];

    
}
@property           struct   MyWavePlayer         *thePlayer;
@property                    short                *inputData;
@property                    char                 *hdr;
@property                    int                  *generatedTones;
@property                    char                 *msgSent;
@property           (retain) NSMutableString      *s3;
@property                    uint8                **cwChars;
@property                    uint8                *cwDat;
@property                    int                  cwMax;


-(void) initializePlayer : (NSString*) inputWavFile : (BOOL) fileOrSymbol;
-(void) quitPlayer;
-(NSString*) generateTones : (NSString*) message;
-(void) morse : (NSString*)msg;


@end

