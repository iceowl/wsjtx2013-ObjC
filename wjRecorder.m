//
//  recorder.m
//  wsjtx
//
//  Created by Joe Mastroianni on 9/6/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import "wjRecorder.h"

@implementation wjRecorder



-(id) init {
    
    self = [super init];
    if(self ) {
        
        theRecorder = malloc(sizeof(MyRecorder));
        theRecorder->kin=0;
        theRecorder->bzero=TRUE;
        theRecorder->recording = FALSE;
        theRecorder->running = FALSE;
        theRecorder->ptr_jt9com_ = &jt9com_;
        theOutputPath = gSettings.m_saveDir;
    }
    return self;
}

#pragma mark - utility functions -

// generic error handler - if error is nonzero, prints error message and exits program.
void CheckError  (OSStatus error , const char*  operation) {
	if (error == noErr) return;
	
	char errorString[20] = "                    ";
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else {
		// no, format it as an integer
		sprintf(errorString, "%d", (int)error);
	}
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
	
	exit(1);
}


// Copy a queue's encoder's magic cookie to an audio file.
-(void) MyCopyEncoderCookieToFile : (AudioQueueRef) queue : (AudioFileID) theFile
{
	UInt32 propertySize;
	
	// get the magic cookie, if any, from the queue's converter
	OSStatus result = AudioQueueGetPropertySize(queue,
												kAudioConverterCompressionMagicCookie, &propertySize);
	
	if (result == noErr && propertySize > 0)
	{
		// there is valid cookie data to be fetched;  get it
		Byte *magicCookie = (Byte *)malloc(propertySize);
		CheckError(AudioQueueGetProperty(myQueue, kAudioQueueProperty_MagicCookie, magicCookie,
										 &propertySize), "get audio queue's magic cookie");
		
		// now set the magic cookie on the output file
		CheckError(AudioFileSetProperty(theFile, kAudioFilePropertyMagicCookieData, propertySize, magicCookie),
				   "set audio file's magic cookie");
		free(magicCookie);
	}
}

#pragma mark - audio queue -

// Audio Queue callback function, called when an input buffer has been filled.

static  void MyAQInputCallback (void *inUserData,
                                AudioQueueRef inQueue,
                                AudioQueueBufferRef inBuffer,
                                const AudioTimeStamp* inStartTime,
                                UInt32 inNumPackets,
                                const AudioStreamPacketDescription* inPacketDesc)  {
    
    MyRecorder  *rPtr = (MyRecorder *)inUserData;
    
    if(rPtr->bzero) {           //Start of a new Rx sequence
        rPtr->kin=0;              //Reset buffer pointer
        rPtr->bzero=FALSE;
        //memset(&(jt9com_.d2),0,120*NTMAX*2);
    }
    
    if(!rPtr->running) return;
    if((rPtr->kin + (inNumPackets*2)) > (NTMAX*12000)) return;
    
    if (inNumPackets > 0) {
        
        jt9com_.kin = (int)rPtr->kin;
        memcpy(&((jt9com_.d2)[rPtr->kin]),inBuffer->mAudioData,inNumPackets*2);
        // if we're n(ot stopping, re-enqueue the buffer so that it gets filled again
        CheckError(AudioQueueEnqueueBuffer(inQueue, inBuffer,
                                           0, NULL), "AudioQueueEnqueueBuffer failed");
        
        
        
        if(rPtr->running && rPtr->recording && jt9com_.nsave ){
            // write packets to file
            CheckError(AudioFileWritePackets(rPtr->recordFile, FALSE, inBuffer->mAudioDataByteSize,
                                             inPacketDesc, rPtr->kin, &inNumPackets,
                                             inBuffer->mAudioData), "AudioFileWritePackets failed");
            
        }
        
         rPtr->kin += inNumPackets;
        
        
        
        //  NSLog(@"kin Recorder = %d",jt9c->kin);
        //    NSLog(@"kin rPtr = %lld",rPtr->kin);
        
    }
    
}


-(void) initializeRecorder {
    
    
    
    memset(&recordFormat, 0, sizeof(recordFormat));
    
    // Configure the output data format to be AAC
    recordFormat.mFormatID         = kAudioFormatLinearPCM;
    recordFormat.mChannelsPerFrame = 1;
    recordFormat.mSampleRate       = 12000.00f;
    recordFormat.mBitsPerChannel   = 16;
    recordFormat.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    
    // get the sample rate of the default input device
    // we use this to adapt the output data format to match hardware capabilities
    // [self MyGetDefaultInputDeviceSampleRate : &recordFormat.mSampleRate];
    //NSLog(@" sample rate is %f",recordFormat.mSampleRate);
    
    // ProTip: Use the AudioFormat API to trivialize ASBD creation.
    //         input: atleast the mFormatID, however, at this point we already have
    //                mSampleRate, mFormatID, and mChannelsPerFrame
    //         output: the remainder of the ASBD will be filled out as much as possible
    //                 given the information known about the format
    UInt32 propSize = sizeof(recordFormat);
    CheckError(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL,
                                      &propSize, &recordFormat), "AudioFormatGetProperty failed");
    
    // create a input (recording) queue
    
    
    CheckError(AudioQueueNewInput(&recordFormat, // ASBD
                                  MyAQInputCallback, // Callback
                                  theRecorder, // user data
                                  NULL, // run loop
                                  NULL, // run loop mode
                                  0, // flags (always 0)
                                  // &recorder.queue), // output: reference to AudioQueue object
                                  &myQueue),
               "AudioQueueNewInput failed");
    
    // since the queue is now initilized, we ask it's Audio Converter object
    // for the ASBD it has configured itself with. The file may require a more
    // specific stream description than was necessary to create the audio queue.
    //
    // for example: certain fields in an ASBD cannot possibly be known until it's
    // codec is instantiated (in this case, by the AudioQueue's Audio Converter object)
    UInt32 size = sizeof(recordFormat);
    CheckError(AudioQueueGetProperty(myQueue, kAudioConverterCurrentOutputStreamDescription,
                                     &recordFormat, &size), "couldn't get queue's format");
    
    // create the audio file
    
    //[self createAudioFile:theOutputFile];  //this will be created when recorder is started.
    
    // many encoded formats require a 'magic cookie'. we set the cookie first
    // to give the file object as much info as we can about the data it will be receiving
    
    // allocate and enqueue buffers
    
    int bufferByteSize = [self MyComputeRecordBufferSize : &recordFormat : myQueue : 0.5];	// enough bytes for half a second
	int bufferIndex;
    for (bufferIndex = 0; bufferIndex < kNumberRecordBuffers; ++bufferIndex)
    {
        AudioQueueBufferRef buffer;
        CheckError(AudioQueueAllocateBuffer(myQueue, bufferByteSize, &buffer),
                   "AudioQueueAllocateBuffer failed");
        CheckError(AudioQueueEnqueueBuffer(myQueue, buffer, 0, NULL),
                   "AudioQueueEnqueueBuffer failed");
    }
    
    // start the queue. this function return immedatly and begins
    // invoking the callback, as needed.
    theRecorder->running = TRUE;
    CheckError(AudioQueueStart(myQueue, NULL), "AudioQueueStart failed");
    
    // and wait
    // printf("Recording set up not running:\n");
    
    monitorQueue = dispatch_queue_create("com.owlhousetoys.wsjtx", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(monitorQueue, ^(void) {
        int ntr0 = 0;
        while(theRecorder->running){
            CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
            CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
            int ntr = floor(gd.second);
            if(ntr<ntr0){
                theRecorder->bzero = TRUE;
            }
            ntr0 = ntr;
            usleep(50000);
        }
        
    });
}


-(void) startRecording {
    
    int m_TRperiod = 60;
    
    CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
    CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
    
    int imin = gd.minute - (gd.minute%(m_TRperiod)/60);
    NSString *t2 = [[NSString alloc] initWithFormat:@"%d%2.2d%2.2d_%2.2d%2.2d.wav",gd.year, gd.month,gd.day,gd.hour,imin];
    NSString *outFile = [theOutputPath stringByAppendingString:t2];
    
    if(jt9com_.nsave)[self createAudioFile:outFile];
    
//    theRecorder->bzero = TRUE;
//    theRecorder->recording = TRUE;
//    theRecorder->running = TRUE;
    //NSLog(@"recording:");
}

-(void) killRecorder : (bool) killDead{
    
    theRecorder->recording = FALSE;
    if(jt9com_.nsave && (theRecorder->recordFile != nil)){
        [self MyCopyEncoderCookieToFile : myQueue : theRecorder->recordFile];
        CheckError(AudioFileClose(theRecorder->recordFile), "Audio File Close Failed");
    }
    if(killDead) {
        theRecorder->running = FALSE;
        //sleep(1);
        CheckError(AudioQueueStop(myQueue, TRUE), "AudioQueueStop failed");
        CheckError(AudioQueueDispose(myQueue, TRUE),"AudioQueueDispose failed");
        NSLog(@"recorder stopped & hopefully didn't just fail");
    }
    // a codec may update its magic cookie at the end of an encoding session
    // so reapply it to the file now
 
    return;
    
}


-(void) createAudioFile : (NSString*) theOutFile {
    
    
    const char* dFile = [theOutFile cStringUsingEncoding:NSUTF8StringEncoding]; // this all has to be explicit to prevent leaks
    
    CFStringRef deFile = CFStringCreateWithCString(NULL,dFile,kCFStringEncodingUTF8);
    
    CFURLRef myFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, deFile, kCFURLPOSIXPathStyle, false);
    CFShow (myFileURL);
    CheckError(AudioFileCreateWithURL(myFileURL, kAudioFileWAVEType, &recordFormat,
                                      kAudioFileFlags_EraseFile, &(theRecorder->recordFile)), "AudioFileCreateWithURL failed");
    CFRelease(myFileURL);
    CFRelease(deFile);
    [self MyCopyEncoderCookieToFile : myQueue : theRecorder->recordFile ];
    
}
//// get sample rate of the default input device
//-(OSStatus) MyGetDefaultInputDeviceSampleRate : (Float64*) outSampleRate
//{
//	OSStatus error;
//	AudioDeviceID deviceID = 0;
//
//	// get the default input device
//	AudioObjectPropertyAddress propertyAddress;
//	UInt32 propertySize;
//	propertyAddress.mSelector = kAudioHardwarePropertyDefaultInputDevice;
//	propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
//	propertyAddress.mElement = 0;
//	propertySize = sizeof(AudioDeviceID);
//	error = AudioHardwareServiceGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &propertySize, &deviceID);
//	if (error) return error;
//
//	// get its sample rate
//	propertyAddress.mSelector = kAudioDevicePropertyNominalSampleRate;
//	propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
//	propertyAddress.mElement = 0;
//	propertySize = sizeof(Float64);
//	error = AudioHardwareServiceGetPropertyData(deviceID, &propertyAddress, 0, NULL, &propertySize, outSampleRate);
//
//	return error;
//}
//
//
// Determine the size, in bytes, of a buffer necessary to represent the supplied number
// of seconds of audio data.
-(int) MyComputeRecordBufferSize : (const AudioStreamBasicDescription*) format : (AudioQueueRef) queue : (float) seconds
{
	int packets, frames, bytes;

	frames = (int)ceil(seconds * format->mSampleRate);

	if (format->mBytesPerFrame > 0)						// 1
		bytes = frames * format->mBytesPerFrame;
	else
	{
		UInt32 maxPacketSize;
		if (format->mBytesPerPacket > 0)				// 2
			maxPacketSize = format->mBytesPerPacket;
		else
		{
			// get the largest single packet size possible
			UInt32 propertySize = sizeof(maxPacketSize);	// 3
			CheckError(AudioQueueGetProperty(myQueue, kAudioConverterPropertyMaximumOutputPacketSize, &maxPacketSize,
											 &propertySize), "couldn't get queue's maximum output packet size");
		}
		if (format->mFramesPerPacket > 0)
			packets = frames / format->mFramesPerPacket;	 // 4
		else
			// worst-case scenario: 1 frame in a packet
			packets = frames;							// 5

		if (packets == 0)		// sanity check
			packets = 1;
		bytes = packets * maxPacketSize;				// 6
	}
	return bytes;
}


@end
