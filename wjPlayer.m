//
//  wjPlayer.m
//  wsjtx
//
//  Created by Joe Mastroianni on 9/27/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//




#import "wjPlayer.h"
#import "globalSettings.h"

@implementation wjPlayer


@synthesize thePlayer   = _thePlayer;
@synthesize inputData   = _inputData;
@synthesize hdr         = _hdr;
@synthesize generatedTones = _generatedTones;
@synthesize msgSent     = _msgSent;
@synthesize s3          = _s3;
@synthesize cwChars     = _cwChars;
@synthesize cwDat       = _cwDat;
@synthesize cwMax       = _cwMax;



- (id) init {
    self = [super init];
    if(self ) {
        
        
        _msgSent = malloc(50);
        memset(_msgSent,0,50);
        
        _thePlayer                      = malloc(sizeof(MyWavePlayer));
        _inputData                      = malloc(sizeof(short) * INPUTDATASIZE);
        _thePlayer->inputData           = _inputData;
        _thePlayer->startingFrameCount  = 0;
        _thePlayer->totalDataPoints     = 0;
        _thePlayer->imDone              = FALSE;
        _thePlayer->cwTime              = FALSE;
        _thePlayer->xit                 = 0;
        _thePlayer->ntxFreq             = gSettings.m_txFreq;
        _thePlayer->running             = FALSE;
        _hdr                            = malloc(sizeof(char) * 54);
        [self initCWChars];
        _generatedTones                 = malloc(200*sizeof(int));
        _thePlayer->generatedTones      = _generatedTones;
        _thePlayer->cwDat               = _cwDat;
        _thePlayer->cwMax               = 0;
        
        _s3                             = [[NSMutableString alloc] init];
        
        
        
        
        
    }
    return self;
    
    
}

-(void)initCWChars {
    
    const uint8 a[38][21] = {
        {1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,20},
        {1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,0,18},
        {1,0,1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,0,16},
        {1,0,1,0,1,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,14},
        {1,0,1,0,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,12},
        {1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,10},
        {1,1,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,12},
        {1,1,1,0,1,1,1,0,1,0,1,0,1,0,0,0,0,0,0,0,14},
        {1,1,1,0,1,1,1,0,1,1,1,0,1,0,1,0,0,0,0,0,16},
        {1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,0,0,0,18},
        {1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 6},
        {1,1,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,10},
        {1,1,1,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,12},
        {1,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0, 8},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 2},
        {1,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,10},
        {1,1,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,10},
        {1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0, 8},
        {1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 4},
        {1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,14},
        {1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,10},
        {1,0,1,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,10},
        {1,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0, 8},
        {1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 6},
        {1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,12},
        {1,0,1,1,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,12},
        {1,1,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,14},
        {1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0, 8},
        {1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 6},
        {1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 4},
        {1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0, 8},
        {1,0,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,10},
        {1,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,10},
        {1,1,1,0,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,12},
        {1,1,1,0,1,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,14},
        {1,1,1,0,1,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,12},
        {1,1,1,0,1,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,14},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 2}};  //   !Incremental word space
    
    
    _cwChars = malloc(38*sizeof(uint8*));
    for(int i=0;i<38;i++) {
        _cwChars[i] = malloc(21);
    }
    _cwDat = malloc(250);
    memset(_cwDat,0,250);
    
    for(int i = 0;i<38;i++) {
        for(int j = 0;j < 21;j++){
            _cwChars[i][j] = a[i][j];
            // NSLog(@" %d %d %d ",i,j,_cwChars[i][j]);
        }
    }
    
}



#pragma mark - callback function -
OSStatus WavFileRenderProc(void *inRefCon,
                           AudioUnitRenderActionFlags *ioActionFlags,
                           const AudioTimeStamp *inTimeStamp,
                           UInt32 inBusNumber,
                           UInt32 inNumberFrames,
                           AudioBufferList * ioData)
{
	//	printf ("SineWaveRenderProc needs %ld frames at %f\n", inNumberFrames, CFAbsoluteTimeGetCurrent());
	
    
    
	MyWavePlayer *player = (MyWavePlayer*)inRefCon;
    short *data = ioData->mBuffers[0].mData;
    int inputCount = player->startingFrameCount;
    if((inputCount >= player->totalDataPoints) || player->imDone) {
        player->imDone = TRUE;
        (data)[0] = 0;
    }
    
    
	
    //	//	double cycleLength = 44100. / 2200./*frequency*/;
    //	double cycleLength = 44100. / sineFrequency;
    //    double cycleLength2 = 44100.0 / (sineFrequency * 1.2);
    
	
	for (int frame = 0; frame < inNumberFrames; ++frame)
	{
        
        if(!player->imDone) (data)[frame] = player->inputData[inputCount];
        else (data)[frame] = 0;
        
        inputCount++;
        if(inputCount >= player->totalDataPoints) {
            player->imDone = TRUE;
            (data)[frame] = 0;
            break;
        }
        
    }
    
	player->startingFrameCount = inputCount;
    
    
	return noErr;
}

#pragma mark - utility functions -


-(void) CreateAndConnectOutputUnit : (BOOL) fileOrSymbol {
    
    _audioFormat.mSampleRate = 12000.0;
    
    if(!fileOrSymbol) {
        _audioFormat.mSampleRate = 48000.0;
        _thePlayer->dnsps=gSettings.m_nsps;
        _thePlayer->nsym=85;
        if(gSettings.m_modeTx==65) {
            _thePlayer->dnsps=4096.0*12000.0/11025.0;
            _thePlayer->nsym=126;
        }
        _thePlayer->ntxFreq= gSettings.m_txFreq;  //m_txFreq;
        
    }
    
    _audioFormat.mFormatID= kAudioFormatLinearPCM;
    _audioFormat.mFormatFlags= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    _audioFormat.mFramesPerPacket= 1;
    _audioFormat.mChannelsPerFrame= 1;
    _audioFormat.mBitsPerChannel= 16;
    _audioFormat.mBytesPerPacket= 2;
    _audioFormat.mBytesPerFrame= 2;
    
	//  10.6 and later: generate description that will match out output device (speakers)
	AudioComponentDescription outputcd = {0}; // 10.6 version
	outputcd.componentType = kAudioUnitType_Output;
	outputcd.componentSubType = kAudioUnitSubType_DefaultOutput;
	outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	AudioComponent comp = AudioComponentFindNext (NULL, &outputcd);
	if (comp == NULL) {
		printf ("can't get output unit");
		exit (-1);
	}
	CheckError (AudioComponentInstanceNew(comp, &(_thePlayer->outputUnit)),
				"Couldn't open component for outputUnit");
	
	// register render callback
	AURenderCallbackStruct input;
    
    if(fileOrSymbol) input.inputProc = WavFileRenderProc;
    else input.inputProc = JTWaveRenderProc;
    
	input.inputProcRefCon = _thePlayer;
	CheckError(AudioUnitSetProperty(_thePlayer->outputUnit,
									kAudioUnitProperty_SetRenderCallback,
									kAudioUnitScope_Input,
									0,
									&input,
									sizeof(input)),
			   "AudioUnitSetProperty failed");
    
    
    CheckError(AudioUnitSetProperty(_thePlayer->outputUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    0, // kOutputBus?
                                    &_audioFormat,
                                    sizeof(_audioFormat)), "Audio Unit set AudioFormat Failed");
    
	// initialize unit
    usleep(1000);
	CheckError (AudioUnitInitialize(_thePlayer->outputUnit),
				"Couldn't initialize output unit");
	
}

- (bool) readFile : (NSString*) inputWavFile {
    
    int npts = 12000*50;
    FILE* myFile = fopen([inputWavFile cStringUsingEncoding:NSASCIIStringEncoding],"rb");
    if(myFile == NULL){
        NSLog(@"error opening file %@\n", inputWavFile);
        return FALSE;
    }
    
    size_t n = fread(&_hdr,1,44,myFile);
    
    if( n  == -1){
        printf("failure to read 44 bytes from file\n");
        return FALSE;
    }
    
    n = fread(_inputData,2,npts,myFile);
    
    if(n == -1 ) {
        printf("failure to read %d points from file\n", npts);
        return FALSE;
    }
    if(fclose(myFile) == -1) {
        NSLog(@"Error closing file %@\n",inputWavFile);
        return FALSE;
    }
    _thePlayer->totalDataPoints = (int)n;
    printf("Sound file opened and read %ld points \n",n);
    
    
    return TRUE;
    
}


#pragma mark main

-(void) initializePlayer : (NSString*) inputWavFile : (BOOL) fileOrSymbol
{
    
    if(_thePlayer->running) return;
    
    if(inputWavFile != NULL && fileOrSymbol){
        
        if(![self readFile: inputWavFile]) return;
        
    }
    
    [self CreateAndConnectOutputUnit : fileOrSymbol];
    
    // start playing
    CheckError (AudioOutputUnitStart(_thePlayer->outputUnit), "Couldn't start output unit");
    
    // NSLog(@"playing...");
    if(playQueue == nil) {
        playQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
    }
    
    dispatch_async(playQueue, ^(void) {
        while(1) {
            if(_thePlayer->imDone) {
                break;
            }
            usleep(10000);
        }
        if(_thePlayer->running) {
            _thePlayer->running = FALSE;
            if(_thePlayer->outputUnit) AudioOutputUnitStop(_thePlayer->outputUnit);
            if(_thePlayer->outputUnit) AudioUnitUninitialize(_thePlayer->outputUnit);
            if(_thePlayer->outputUnit) AudioComponentInstanceDispose(_thePlayer->outputUnit);
        }
        
    });
    _thePlayer->running = TRUE;
    _thePlayer->imDone = FALSE;
   	return;
}




-(void) quitPlayer {
    
    
    if(_thePlayer->running){
        _thePlayer->running = FALSE;
        
        if(!_thePlayer->imDone && _thePlayer->outputUnit){
            if(_thePlayer->outputUnit)AudioOutputUnitStop(_thePlayer->outputUnit);
            if(_thePlayer->outputUnit)AudioUnitUninitialize(_thePlayer->outputUnit);
            if(_thePlayer->outputUnit)AudioComponentInstanceDispose(_thePlayer->outputUnit);
        }
        _thePlayer->imDone = TRUE;
    }
    if(_thePlayer->inputData) memset(_thePlayer->inputData,0,sizeof(short) * INPUTDATASIZE);
    
    _thePlayer->startingFrameCount = 0;
    _thePlayer->totalDataPoints = 0;
    // NSLog(@"player stopped");
    
    
}

-(NSString*) generateTones : (NSString*) message{
    
    int len1 = 0;
    int ichk = 0;
    int itext = 0;
    char b[25];
    
    [_s3 appendString:message];
    len1 = (int)[_s3 length];
    if(len1 < 22) {
        for(int i=len1;i<22;i++){
            [_s3 appendString:@" "];
        }
    }
    len1 = (int)[_s3 length];
    for(int i=0;i<len1;i++){
        b[i] = [_s3 characterAtIndex:i];
    }
    
    if(gSettings.m_modeTx == 9) genjt9_(b,&ichk,_msgSent,_generatedTones,&itext,len1,len1);
    if(gSettings.m_modeTx == 65) gen65_(b,&ichk,_msgSent,_generatedTones,&itext,len1,len1);
    //NSLog(@" msgSent %s",_msgSent);
    // for(int i =0;i<126;i++) NSLog(@" iTone %d = %d",i,iTone[i]);
    NSString *ss = [NSString stringWithFormat:@"%s",_msgSent];
    [_s3 deleteCharactersInRange:NSMakeRange(0, [_s3 length])];
    return ss;
    
}



OSStatus JTWaveRenderProc(void *inRefCon,
                          AudioUnitRenderActionFlags *ioActionFlags,
                          const AudioTimeStamp *inTimeStamp,
                          UInt32 inBusNumber,
                          UInt32 inNumberFrames,
                          AudioBufferList * ioData)
{
    
    static double freq  = 0.0;
    static double dphi  = 0.0;
    static double phi   = 0.0;
    static double amp   = 0.0;
    static int    isym0 = 0;
    static short  i2    = 0;
    static int    ic    = 0;
    static int    ic2   = 0;
    static int    ic0   = 0;
    static int    ntr0  = 0;
    static int    cwC   = 0;
    
    MyWavePlayer *player = (MyWavePlayer*)inRefCon;
    short *data = (short*)ioData->mBuffers[0].mData;
    CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
    CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
    
    
    ic = (int)(floor(gd.second * 1000.0));
    ic %= 48000;
    ic = (ic-1000) * 48;
    
    if(player->cwTime){
        ic2 = (int)(floor(gd.second*20.0));
        //ic0 = -1;
        
    }
    int ntr = floor(gd.second);
    if(ntr > 48 && !player->running && !player->cwTime){
        player->imDone = TRUE;
        //  NSLog(@"player done");
    } else if(ntr > 48 && ntr < 60 && player->running && !player->cwTime){
        if(ntr != ntr0) {
            //NSLog(@"ntr = %d",ntr);
            ntr0 = ntr;
        }
        ic = -1;
    } else if (!player->running) {
        player->imDone = TRUE;
        //  NSLog(@"player done");
    }
    
    
    
    double baud=12000.0/player->dnsps;
    amp=32767.0;
    int i0=(player->nsym-0.017)*4.0*player->dnsps;
    int i1=player->nsym*4.0*player->dnsps;
    
    if(ntr > 48 && ntr < 60 && player->cwTime && (cwC <= player->cwMax) && !player->imDone) {
    //if(TRUE) {
        ntr0 = ntr;
        freq = player->ntxFreq;
        if(freq == 0) freq = 1000;
        dphi = 2.0*M_PI*freq/48000.0;
        
        //int nspd = 2048 + 512;
        for(int frame=0 ; frame<inNumberFrames; frame++ )  {
            phi += dphi;
            if(phi>2.0*M_PI) phi -= 2.0*M_PI;
            i2=amp*sin(phi);
            if(ic2 != ic0){
                cwC++;
                ic0 = ic2;
            }
            if(cwC <= player->cwMax){
                if(player->cwDat[cwC] == 1 ) {
                    (data)[frame] = i2;
                }else (data)[frame] = 0;
            }else {
                (data)[frame] = 0;
                cwC = 0;
                player->cwTime        = FALSE;
                player->imDone        = TRUE;
                gSettings.m_morseNext = FALSE; // can I do this from here? maybe not.
                gSettings.m_sendCall  = FALSE;
            }
        }
        if(ntr >= 59){
            player->cwTime = FALSE;
            cwC = 0;
            ic0 = -1;
            player->imDone = TRUE;
        }
    }
    
    
    else {
        for(int frame=0 ; frame<inNumberFrames; frame++ )  {
            if(player->running && !player->imDone) {
                if(ic > 0) {
                    int isym = ic /(4.0*player->dnsps);//Actual fsample=48000
                    if(isym > 126) isym = 126;
                    if(isym!=isym0) {
                        freq=player->ntxFreq + (((player->generatedTones)[isym]) * baud) - player->xit;
                        dphi=2.0*M_PI*freq/48000.0;
                        isym0=isym;
                        // NSLog(@" isym = %d  ntr = %d", isym, ntr);
                    }
                    phi += dphi;
                    if(phi>2.0*M_PI) phi -= 2.0*M_PI;
                    if(ic>i0) amp=0.98*amp;
                    if(ic>i1) amp=0.0;
                    i2=amp*sin(phi);
                    
                    (data)[frame] = i2;
                } else (data)[frame] = 0;
            } else (data)[frame] = 0;
        }
    }
    return noErr;
}

-(void) morse : (NSString*)msg  {
    
    int n = 6;
    memset(_cwDat,0,250);
    for(int k=0;k<[msg length];k++){
        int j = 0;
        uint8 jj = [msg characterAtIndex:k];
        if((jj >= 97) && (jj <= 122)) jj -= 32;
        if((jj >= 48) && (jj <= 57)) j = jj - 48;
        if((jj >= 65) && (jj <= 90)) j = jj - 55;
        if(jj == 47) j = 36;
        if(jj == 32) j = 37;
        int cwM = _cwChars[j][20];
        for(int i = 0; i < cwM;i++) {
            n++;
            _cwDat[n] = _cwChars[j][i];
        }
        _cwDat[n++]= 0;
        // _cwDat[n++]= 0;
        
    }
    _cwDat[n++]= 0;
    _cwDat[n++]= 0;
    _cwMax = n;
    _thePlayer->cwMax = n;
    gSettings.m_morseNext = TRUE;
    _thePlayer->cwTime = TRUE;
    return;
    
}
@end
