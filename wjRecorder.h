//
//  recorder.h
//  wsjtx
//
//  Created by Joe Mastroianni on 9/6/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//




#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#define kNumberRecordBuffers	3
#include "common.h"
#include "externSettings.h"


typedef struct MyRecorder {
    AudioFileID					recordFile; // reference to your output file
    SInt64						kin; // current packet index in output file
    Boolean						running; // recording state
    Boolean                     recording;
    Boolean                     bzero;
    struct jt9Common            *ptr_jt9com_;
    } MyRecorder;

//typedef void (*myCallback)(void * inUserData, AudioQueueRef inQueue, AudioQueueBufferRef inBuffer, const AudioTimeStamp * inStartTime,
//UInt32 inNumPackets, const AudioStreamPacketDescription * inPacketDesc);

extern void* mem_jt9;
void CheckError  (OSStatus error , const char*  operation);

@interface wjRecorder : NSObject {
    
    struct MyRecorder *theRecorder;
    AudioQueueRef      myQueue;
    AudioStreamBasicDescription recordFormat;
    NSString          *theOutputPath;
    dispatch_queue_t   monitorQueue;
    

}



//-(OSStatus) MyGetDefaultInputDeviceSampleRate:(Float64*) outSampleRate;
-(void) MyCopyEncoderCookieToFile : (AudioQueueRef) queue : (AudioFileID) theFile;
-(int)  MyComputeRecordBufferSize : (const AudioStreamBasicDescription *)format : (AudioQueueRef) queue : (float) seconds;
-(void) initializeRecorder;
-(void) killRecorder : (bool) killDead;
-(void) startRecording;
-(void) createAudioFile : (NSString*) theOutFile;

@end
