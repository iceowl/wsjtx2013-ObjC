//
//  wideGraph.m
//  wsjtx
//
//  Created by Joe Mastroianni on 9/13/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import "wideGraph.h"

//#include <complex.h>
//#include "fftw3.h"
#include <math.h>
#include <Accelerate/Accelerate.h>
#include "externSettings.h"

#define GRAPHSCALE 1

@implementation wideGraph


@synthesize backgroundGradient      = _backgroundGradient;
@synthesize colorTbl                = _colorTbl;
@synthesize gLegend                 = _gLegend;
@synthesize aPath                   = _aPath;
@synthesize spectrumImage           = _spectrumImage;
@synthesize waterfallImage          = _waterfallImage;
@synthesize waveViewRect            = _waveViewRect;
@synthesize waterfallRect           = _waterfallRect;
@synthesize waterfallInRect         = _waterfallInRect;
@synthesize waterfallGraph          = _waterfallGraph;
@synthesize waterfallIndex          = _waterfallIndex;
@synthesize splot                   = _splot;
@synthesize swide                   = _swide;
@synthesize s                       = _s;
@synthesize attributes              = _attributes;
@synthesize transform               = _transform;
@synthesize lineBuf                 = _lineBuf;

@synthesize ssum                    = _ssum;
@synthesize w3                      = _w3;
@synthesize scale                   = _scale;
@synthesize  nWaterfallIterations   = _nWaterfallIterations;
@synthesize ihsym                   = _ihsym;
@synthesize ntrperiod               = _ntrperiod;
@synthesize px                      = _px;
@synthesize df3                     = _df3;
@synthesize slope                   = _slope;
@synthesize nbpp                    = _nbpp;
@synthesize fftInput                = _fftInput;
@synthesize bandwidth               = _bandwidth;

@synthesize complexSplitA           = _complexSplitA;
@synthesize fftSetup                = _fftSetup;
@synthesize log2n                   = _log2n;
@synthesize wideGraphQueue          = _wideGraphQueue;

@synthesize maxScreensize           = _maxScreensize;
@synthesize ourHeight               = _ourHeight;
@synthesize ourWidth                = _ourWidth;
@synthesize masterClockSec          = _masterClockSec;


-(void)awakeFromNib {
    
    
    NSRect bounds = [self bounds];
    _ourWidth = bounds.size.width;
    _ourHeight = bounds.size.height;
    _maxScreensize = _ourWidth;
    
    
    
    [self setupBackgroundGradient];
    
    _bandwidth = 66.0*11025.0/_maxScreensize;
    gSettings.m_fftBinWidth = MAX_DISPLAY_FREQ/(gSettings.m_binsPerPixel*_maxScreensize);
    _nbpp = 1;
    gSettings.m_bCurrent = FALSE;
    gSettings.m_bCumulative = TRUE;
    gSettings.m_dataSinkBusy = FALSE;
    gSettings.m_needUTC = FALSE;
    gSettings.m_inGain = -1;
    _waterfallGraph = malloc(NSMAX*sizeof(uint8));
    _waterfallIndex = 0;
    gSettings.m_waterfallAvg = 3; // must never be < 1
    
    _attributes = [NSDictionary  dictionaryWithObjectsAndKeys:
                   [NSFont fontWithName:@"Times" size:18],NSFontAttributeName,
                   [NSColor whiteColor], NSForegroundColorAttributeName,
                   [[NSNumber alloc] initWithFloat:0.2],NSExpansionAttributeName,
                   nil];
    
    
    _transform = [[NSAffineTransform alloc] init];
    [_transform translateXBy:0.0 yBy:-1.01];
    
    
    _waveViewRect.origin = NSZeroPoint;
    _waveViewRect.size.height = _ourHeight - WATERFALL_HEIGHT;
    _waveViewRect.size.width = _maxScreensize;
    
    //_waterfallRect.size = [_waterfallImage size];
    _waterfallRect.size.width = _maxScreensize;
    _waterfallRect.size.height = WATERFALL_HEIGHT;
    _waterfallRect.origin = NSZeroPoint;
    
    _waterfallInRect.origin = NSMakePoint(0.0, _ourHeight - WATERFALL_HEIGHT);
    _waterfallInRect.size.width = _ourWidth;
    _waterfallInRect.size.height = WATERFALL_HEIGHT;
    
    
    _aPath = [NSBezierPath bezierPath];
    [_aPath setLineWidth:1.0];
    
    _lineBuf = malloc(NSMAX*sizeof(NSPoint));
    
    _spectrumImage  = [[NSImage alloc] initWithSize:_waveViewRect.size];
    _waterfallImage = [[NSImage alloc] initWithSize:_waterfallRect.size];
    [_waterfallImage setBackgroundColor:[NSColor blackColor]];
    // [self setUpFFT]; //needs to happen sooner than here or awakeFromNIB
    
    
    
}

-(id) initWithFrame:(NSRect)frame {
    
    // NSLog(@"init Widegraph with frame"); // make sure there is only one instance of this
    self = [super initWithFrame:frame];
    
    if(self) {
        [self setUpFFT];
    }
    
    
    return self;
}

-(void) setUpFFT {
    
    _s = malloc(NSMAX*sizeof(double));
    _swide = malloc(NSMAX*sizeof(double)); // should be _maxScreensize*sizeof(double)
    _splot = malloc(NSMAX*sizeof(double));
    
    
    //    _cx = fftw_malloc(sizeof(fftw_complex)*NSMALL);
    //    _xc = malloc(NSMALL*sizeof(double));
    _ssum = malloc(NSMAX*sizeof(double));
    //   _plan = NULL;
    _w3 = malloc(MAXFFT3*sizeof(double)) ;
    _scale = malloc(MAXFFT3*sizeof(double));
    memset(_ssum,0,NSMAX*sizeof(double));

    
    _fftInput = malloc(MAXFFT3*sizeof(float));
    //_fftOutput = malloc(MAXFFT3*sizeof(float));
    _complexSplitA.realp = malloc(MAXFFT3/2*sizeof(float));
    _complexSplitA.imagp = malloc(MAXFFT3/2*sizeof(float));
    _log2n = log2f((float)MAXFFT3);
    _fftSetup = vDSP_create_fftsetup(_log2n, FFT_RADIX2);
    _colorTbl = [[NSMutableArray alloc] initWithCapacity:300];
    [self setPalette:@"CuteSDR"];
    
    
}


- (void)setupBackgroundGradient
{
    // create a basic gradient for the background of the view
    
    CGFloat red1   = 0.0; //   0.0 / 255.0;
    CGFloat green1 = 0.0; // 72.0 / 255.0;
    CGFloat blue1  = 0.0; //127.0 / 255.0;
    
    CGFloat red2    =   0.0/255.0;
    CGFloat green2  =  20.0/255.0; //43.0 / 255.0;
    CGFloat blue2   =  50.0/255.0;//76.0 / 255.0;
    
    NSColor* gradientTop    = [NSColor colorWithCalibratedRed:red1 green:green1 blue:blue1 alpha:1.0];
    NSColor* gradientBottom = [NSColor colorWithCalibratedRed:red2 green:green2 blue:blue2 alpha:1.0];
    
    NSGradient* gradient;
    gradient = [[NSGradient alloc] initWithStartingColor:gradientBottom endingColor:gradientTop];
    
    _backgroundGradient = gradient;
    
}



-(void) dataSink2
{
    gSettings.m_dataSinkBusy = TRUE;
    jt9com_.ndiskdat=1;
    static int k;
    //   static int nzap=0;
    //static int ntr0;
    
    //   Input:
    //     k         pointer to the most recent new data
    //     ntrperiod T/R sequence length, minutes
    //     nsps      samples per symbol, at 12000 Hz
    //     ndiskdat  0/1 to indicate if data from disk
    //     nb        0/1 status of noise blanker (off/on)
    //     nbslider  NB setting, 0-100
    //
    //    Output:
    //      pxdb      power (0-60 dB)
    //      s()       current spectrum for waterfall display
    //      ihsym     index number of this half-symbol (1-184)
    //
    //     jt9com
    //      ss()      JT9 symbol spectra at half-symbol steps
    //      savg()    average spectra for waterfall display
    
    // Get power, spectrum, and ihsym
    _ntrperiod=1;
    _slope = gSettings.m_slope;
    
    gSettings.m_nsps = 6912;
    if(jt9com_.kin == k) {
        gSettings.m_dataSinkBusy = FALSE;
        return;
    }
    // symspec_(&(jt9com_.kin),&_ntrperiod,&_nsps,&_m_inGain,&_slope,&_px,_s,&_df3,&_ihsym,&(jt9com_.npts8));
    [self waterfallFFT2];
    
    k = jt9com_.kin;
 
    if(_nWaterfallIterations == 0){
        memset(_splot,0,NSMAX);
    }
    
    if( jt9com_.kin == 0){
        gSettings.m_dataSinkBusy = FALSE;
        return;
    }
    
    gSettings.m_fMax=[_gLegend FreqfromX: _maxScreensize];
    
    for (int i=0; i<NSMAX; i++){
        if(gSettings.m_waterfallAvg < 2) {
            _splot[i] = _s[i];
        } else {
            if(i<NSMAX) _splot[i] += _s[i];
            else _splot[i] = _s[i];
        }
    }
    _nWaterfallIterations++;
    
    if (_nWaterfallIterations>=gSettings.m_waterfallAvg) {
        for (int i=0; i<NSMAX; i++) {_splot[i] = _splot[i]/(float)gSettings.m_waterfallAvg;  }                     //Normalize the average
        _nWaterfallIterations=0;
        int i = -1;
        float sum = 0.0;
        
        int jz=_maxScreensize;
        for (int j=0; j<jz; j++) {
            sum = 0.0;
            if(gSettings.m_binsPerPixel == 1) {
                _swide[j] = _splot[j];
                _splot[j] *= PLOTFADE;
            } else {
                for (int k=0; k<gSettings.m_binsPerPixel; k++) {
                    i++;
                    if(i<NSMAX){
                        sum += _splot[i];
                        _splot[i] = _splot[i] * PLOTFADE; // reduce _splot samples on iteration, somehow
                    }
                }
                _swide[j] = sum;
            }
        }
        
        //        CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
        //        CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
        //        int ntr = floor(gd.second);
        if((_masterClockSec == 0) || (_masterClockSec < gSettings.m_ntr0)) {
            for(int i=0;i<_maxScreensize;i++){
                _swide[i] = 1.0e30;
            }
            gSettings.m_needUTC = TRUE;
        }
        gSettings.m_ntr0=_masterClockSec;
        gSettings.m_dataSinkBusy = FALSE;
        [self drawWaterfall];
    }
    gSettings.m_dataSinkBusy = FALSE;
}

-(void) drawWaterfall
{
    
    float y,sum;
    //    int m_i0=i0;
    NSPoint p;
    
    
    double gain = pow(10.0,0.05*(gSettings.m_plotGain+3));
    
    gSettings.m_fMax=[_gLegend FreqfromX: _maxScreensize];
    int iz = _maxScreensize;
    for(int i=0; i<iz; i++) {
        sum = 0.0;
        y   = 0.0;
        if(_swide[i]>0.0) y = 10.0*log10(_swide[i]);
        int y1 = 4.0*gain*y + 10*(gSettings.m_plotZero-10);
        if (y1<0) y1=0;
        if (y1>254) y1=254;
        if (_swide[i]>1.e29) y1=255;
        _waterfallGraph[i] = (uint8)y1;
        int y2=0;
        if(gSettings.m_bCurrent) y2 = 0.4*gain*y - 15;
        if(gSettings.m_bCumulative) {
            int j=gSettings.m_binsPerPixel*i;
            for(int k=0; k<gSettings.m_binsPerPixel; k++) {
                if(j < NSMAX) {
                    sum+=jt9com_.savg[j];
                    _ssum[j] = _ssum[j]*0.6; //if we don't reduce this sometime the signal lasts forever!
                    //jt9com_.savg[j] = 0.0;
                }
                j++;
            }
            if(sum == 0) {
                y2 = 0;
            } else {
                y2=gain*7.0*log10(sum/gSettings.m_binsPerPixel);
            }
        }
        
        if(y2 < -5.0) y2 = -5.0 ;
        y2 += gSettings.m_plotZero;
        
        
        if(i==iz-1) {
            [_aPath removeAllPoints];
            [_aPath moveToPoint:NSMakePoint(0.0,0.0)];
            [_aPath appendBezierPathWithPoints:_lineBuf count:i-1];
            
        } else{
            
            p = NSMakePoint((float)i,(float)y2+(0.2*_waveViewRect.size.height));
            _lineBuf[i] = p;
        }
        //        if(i>0) {
        //        if(_lineBuf[i].y > (_lineBuf[i-1].y)+20) NSLog(@" distortion at %d",i);
        //        }
    }
    
    // memset(_swide, 0, NSMAX*sizeof(double));
    // memset(_s,0,NSMAX*sizeof(double));
    [self paintTwoDWave];
    [self setNeedsDisplay:YES];
    
    
    
}

//-(void)scrollWaterfallGraph {
//    for (int i = 0;i< _waterfallIndex ;i++){
//        for(int j = 0; j < [self XfromFreq:MAX_DISPLAY_FREQ]-1;j++) {
//            _waterfallGraph[i+1][j]  = _waterfallGraph[i][j];
//        }
//    }
//    _waterfallIndex++;
//    if(_waterfallIndex > WATERFALL_HEIGHT-1) _waterfallIndex=WATERFALL_HEIGHT-1;
//
//
//}

-(void)scrollWaterfallImage {
    
    if(_waterfallImage){
        [_waterfallImage lockFocus];
        // [_transform translateXBy:0.0 yBy:-1.01];
        [_transform concat];
        [_waterfallImage drawInRect:_waterfallRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0 ];
        [_waterfallImage unlockFocus];
        
    }
    
}




-(void) paintTwoDWave  {
    
    int fiveHundredHertz = [_gLegend XfromFreq:(float)500];
    int xmitFreq         = [_gLegend XfromFreq:(float)gSettings.m_txFreq];
    _bandwidth           = [_gLegend XfromFreq:185.0];
    gSettings.m_bandwidth = _bandwidth;
    NSRect theLittleDot;
    [self scrollWaterfallImage];
    
    [_waterfallImage lockFocus];
    
    if(gSettings.m_needUTC){
        
        CFAbsoluteTime at  = CFAbsoluteTimeGetCurrent();
        CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
        NSString *t2       = [[NSString alloc] initWithFormat:@"%2.2d%2.2d",gd.hour,gd.minute];
        [[NSColor whiteColor]set];
        [t2 drawAtPoint:NSMakePoint(2.0, _waterfallRect.size.height-24.0) withAttributes:_attributes];
        gSettings.m_needUTC = FALSE;
        
    }
    
    for(int i=0;i<_maxScreensize;i++){
        
        if((!(i%fiveHundredHertz))&& (i!=0)) {
            [[NSColor whiteColor] set];
            theLittleDot.origin = NSMakePoint((float)i*GRAPHSCALE, _waterfallRect.size.height-5.0);
            theLittleDot.size.height = 2.5;
            theLittleDot.size.width  = 2.0;
        } else {
            [(NSColor*)[_colorTbl objectAtIndex:_waterfallGraph[i]] set];
            theLittleDot.origin = NSMakePoint((float)i*GRAPHSCALE, _waterfallRect.size.height-5.0);
            theLittleDot.size.height = 1.0;
            theLittleDot.size.width  = 1.0;
        }
        
        NSRectFill(theLittleDot);
        
    }
    
    //[NSBezierPath strokeRect:waterfallRect];
    [_waterfallImage unlockFocus];
    [_spectrumImage lockFocus];
    [_backgroundGradient drawInRect:_waveViewRect angle:90.0];
    [[NSColor greenColor] set];
    [_aPath stroke];
    [_spectrumImage unlockFocus];
    [_gLegend paintXmitFreq: xmitFreq :_bandwidth];
    
    return;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if(_spectrumImage && _waterfallImage){
        [_backgroundGradient drawInRect:_waveViewRect angle:90.0];
        [_spectrumImage drawInRect:_waveViewRect fromRect:NSZeroRect   operation:NSCompositeSourceOver fraction:1.0];
        [_waterfallImage drawInRect:_waterfallInRect fromRect:NSZeroRect  operation:NSCompositeCopy fraction:1.0];
        if(!aTimer){
            [self myCreateTimer];
        }
    }
    
}

-(void)setPalette : (NSString*) palette   {                   //setPalette()
    int i1,i2,i3,i4,i5;
    i1 = 43; //43;
    i2 = 87; //87;
    i3 = 120;
    i4 = 154;
    i5 = 217;
    CGFloat myAlpha = 1.0;
    if([palette  isEqualToString:@"Linrad"]) {
        float twopi=6.2831853;
        float r,g,b,phi,x;
        for(int i = 0; i < 256 ; i++) {
            r = 0.0;
            if((i > 105) && (i <= 198)) {
                phi = (twopi/4.0) * (i-105.0)/(198.0-105.0);
                r = sin(phi);
            } else if(i >= 198) {
                r = 1.0;
            }
            
            g = 0.0;
            if((i > 35) && (i < 198)) {
                phi = (twopi/4.0) * (i-35.0)/(122.5-35.0);
                g = 0.625*sin(phi);
            } else if(i >= 198) {
                x = (i-186.0);
                g = - 0.014 + (0.0144*x) - (0.00007*x*x) +(0.000002*x*x*x);
                if(g > 1.0) g = 1.0;
            }
            
            b = 0.0;
            if(i <= 117) {
                phi = (twopi/2.0) * i/117.0;
                b = 0.4531*sin(phi);
            } else if(i > 186) {
                x = (i-186.0);
                b = - 0.014 + (0.0144*x) - (0.00007*x*x) + (0.000002*x*x*x);
                if(b > 1.0) b = 1.0;
            }
            NSColor *c = [NSColor colorWithSRGBRed:((255.0*r)/255.0) green:((255.0*g)/255.0) blue:((255.0*b)/255.0) alpha:myAlpha];
            [_colorTbl insertObject:c atIndex:i];
        }
        NSColor *c = [NSColor colorWithSRGBRed:1.0 green:1.0 blue:(100.0/255.0) alpha:myAlpha];
        [_colorTbl addObject:c];
        
    }
    
    if([palette  isEqualToString:@"CuteSDR"]) {
        
        for( int i = 0; i < 256; i++) {
            NSColor *c;
            if( i < i1 ) {
                c = [NSColor colorWithSRGBRed: 0.0 green: 0.0 blue: (255.0*(i)/(255.0 *(float)i1)) alpha:myAlpha];
            }
            if( (i >= i1) && (i < i2) ) {
                c = [NSColor colorWithSRGBRed: 0.0 green:((255.0*(i-i1)/i1)/255.0) blue:1.0  alpha: myAlpha];
            }
            if( (i >= i2) && (i < i3) ) {
                c = [NSColor colorWithSRGBRed: 0.0 green:1.0 blue: ((255.0-(255.0*(i-i2)/32.0))/255.0) alpha:myAlpha ];
            }
            if( (i >= i3) && (i < i4) ) {
                c = [NSColor colorWithSRGBRed: ((255.0*(i-i3)/33.0)/255.0) green: 1.0 blue: 0.0 alpha :myAlpha];
            }
            if( (i >= i4) && (i < i5) ) {
                c = [NSColor colorWithSRGBRed:1.0 green: 1.0  blue: ((255.0*(i-i4)/62.0)/255.0) alpha:myAlpha];
            }
            if( i >= i5  ){
                c = [NSColor colorWithSRGBRed: 1.0 green: 0.0 blue: ((128.0*(i-i5)/38.0)/255.0) alpha:myAlpha];
            }
            [_colorTbl insertObject:c atIndex:i];
            
        }
        NSColor *c = [NSColor colorWithSRGBRed:1.0 green:1.0 blue:(100.0/255.0) alpha:myAlpha];
        [_colorTbl addObject:c];
        ////NSLog(@"initialized CuteSDR");
    }
    
    
}

-(dispatch_source_t) CreateDispatchTimer :(uint64_t) interval
                                         :(uint64_t) leeway
                                         :(dispatch_queue_t) queue
                                         :(dispatch_block_t) block {
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, queue);
    
    if (timer)    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    
    return timer;
    
}


//  This timer runs a lot better than creating a continuous loop.  I think the fact the little procedure dies every so many microseconds
// frees up the memory via ARC.  If you run the continuous loop, the memory increases monotonically.  I would have to restructure the memory
// allocation in this whole class to fix that (it's doable) but I just don't feel like it right now... and anyway, with the exception of this
// warning, there's no problem. There isn't a retain cycle problem like there apparently is when running the loop.


-(void) myCreateTimer

{
    
    __block wideGraph* bSelf = self; // capture so as to not have compiler complain about ARC retain cycles...dunno if this is going to be a problem.
    
    aTimer = [self  CreateDispatchTimer :100ull * NSEC_PER_MSEC
                                        :10ull * NSEC_PER_MSEC
                                        :dispatch_queue_create("com.owlhousetoys.wsjtx2", DISPATCH_QUEUE_SERIAL)
              // :dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                        :gBlock = ^{
                                            if(!gSettings.m_dataSinkBusy){
                                                [bSelf dataSink2];
                                            }
                                            //usleep(10000);
                                        }];
    
    [gBlock copy]; // copy to heap so not sitting on stack with all those self vars...
    
    
}


-(void)killWaterfallTimer {
    if(aTimer) dispatch_source_cancel(aTimer);
    //    m_waterfallRunning = FALSE;
    //    usleep(20000);
}


-(void) waterfallFFT2 {
    
    
    
    //    double rms = 999.0;
    static int k0     = 6000;
    static int nfft3z = 0;
    static int ja     = 0;
    static double slope0 = 0.0;
    //   double ssq;
    double fac0;
    double fac;
    double sx;
    double gain;
    int kin;
    
    int iz;
    
    kin = jt9com_.kin;
    if(kin < 2048) return;
    
    if(kin <= k0) {
        // NSLog(@"kin reset kin = %d",kin);
        _ihsym = 0;
        //  memset(&(jt9com_.d2[kin+1]),0,(12000*NTMAX*2)-kin+1); // will this prevent ghosting?? who knows.
        ja = 0;
        k0 = kin ;
    }
    
    // int nfft3 = 16384;
    int nfft3 = MAXFFT3;
    
    if((nfft3 != nfft3z) || (_slope != slope0)) {
        // double pi = 4.0*atan(1.0);
        for(int i=0;i<nfft3;i++){
            //_w3[i] = 2.0*pow((sin(i*pi/nfft3)),2); // window that was here originally
            _w3[i] = (0.54 - (0.46 * cos(2.0 * M_PI * (double)i/nfft3))); //hamming window
            //_w3[i] = (0.5 - 0.5 * cos(2.0 * M_PI * (double)i / (double)nfft3)); //hanning window
            //_w3[i] = ((0.42 - 0.5 * cos(2.0 * M_PI * (double)i / (double)nfft3)) + (0.08 * cos(4.0 * M_PI * (double)i / (double)nfft3))); // blackman window
        }
        
        for(int ii = 0;ii < MAXFFT3;ii++){
            float xx = _slope * (float)ii / (float)(MAXFFT3/2);// - 1.0 + 2.6;
            _scale[ii] = pow(10,xx);
        }
        
        nfft3z = nfft3;
        slope0 = _slope;
    }
    
    
    
    
    gain = pow(10,(0.05*gSettings.m_inGain));
    fac0 = 0.1;
    k0 = kin;
    
    for(int i = 0;i < (nfft3-1);i++){
        //int j = ja+i-(nfft3-1);
        int j = kin - nfft3 - 1 + i;
        _fftInput[i]=0.0;
        if(j>=0) {
            _fftInput[i] = fac0*jt9com_.d2[j];
        }
    }
    
    //if(ihsym.lt.184) ihsym=ihsym+1
    
    
    // better to time _ihsym to system clock - it's not being called regularly on time boundries
    
    CFAbsoluteTime  at = CFAbsoluteTimeGetCurrent();
    CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
    _masterClockSec    = floor(gd.second);
    if (_masterClockSec <= 48) {
        _ihsym = floor(gd.second * (184.0/48.0));
    }
    
    //
    //xc(0:nfft3-1)=w3(1:nfft3)*xc(0:nfft3-1)    !Apply window w3
    
    //    for(int i=0;i<nfft3-1;i++) {
    //        _fftInput[i] = _w3[i+1]*_fftInput[i];
    //    }
    
    for(int i = 0;i < nfft3;i++) {  // my guess is that we don't have to do the index -1 thing as in the fortran
        _fftInput[i] = _w3[i]*_fftInput[i];
    }
    
    
    vDSP_ctoz((COMPLEX *) _fftInput, 2, &_complexSplitA, 1, MAXFFT3/2);
    vDSP_fft_zrip(_fftSetup, &_complexSplitA,1, _log2n, FFT_FORWARD);
    
    
    int nn = MIN(184,_ihsym);
    _df3 = 12000.0/nfft3;
    iz = MIN(NSMAX, floor(5000.0/_df3));
    //iz = NSMAX;
    fac = pow((1.0/nfft3),2);
    
    sx = fac*_complexSplitA.realp[0];
    jt9com_.ss[nn] = sx;
    _ssum[0] += sx;
    _s[0] = gain*sx;
    
    for(int i = 2;i < iz;i++){
        
        sx = fac*((_complexSplitA.realp[i]*_complexSplitA.realp[i]) + (_complexSplitA.imagp[i] * _complexSplitA.imagp[i]));
        jt9com_.ss[nn*(i-1)] = sx;
        _ssum[i-1] += sx;
        _s[i-1]=gain*sx;
        
        
    }
    
    for(int i = 0;i < iz;i++){
        _s[i] = _scale[i] * _s[i];
        //NSLog(@"%f",_s[i]);
        if(_ihsym>0)jt9com_.savg[i] = _scale[i]*_ssum[i]/_ihsym;
    }
    
    // memset(_complexSplitA.realp,0,(MAXFFT3/2)*sizeof(double));
    // memset(_complexSplitA.imagp,0,(MAXFFT3/2)*sizeof(double));
    
}
- (void)mouseDown:(NSEvent*) theEvent{
    [_gLegend mouseDown:theEvent];
    return;
}


@end
