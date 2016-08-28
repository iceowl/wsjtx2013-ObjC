//
//  wideGraph.h
//  wsjtx
//
//  Created by Joe Mastroianni on 9/13/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//







#import <Cocoa/Cocoa.h>
#include "externSettings.h"
#import <QuartzCore/QuartzCore.h>
#import "graphLegend.h"
#include <Accelerate/Accelerate.h>
#include "common.h"


#define WATERFALL_HEIGHT 250.0 // arbitrary...
#define MAX_DISPLAY_FREQ 5000.0 //utterly arbitrary...
#define PLOTFADE 0.4
#define NPMAX 100
#define NSMALL 16384 // constant from the fortran side of things...obviously related to number of taps/samples/etc of the FFT.  I need to (re)learn the math.  Havent done this stuff since college in 1980.  Ask Jt or Johm.



//extern void symspec_(int* k, int* ntrperiod, int* nsps, int* ingain, double* slope,
 //                    double* px, double s[], double* df3, int* nhsym, int* npts8);
// this fortran routine is  overkill for a simple waterfall...  It has other purposes we're not using
// replaced with short native Mac rouine below.

typedef void (^GraphBlock)(void);

extern  dispatch_source_t aTimer;

@interface wideGraph : NSView  {
    
    GraphBlock         gBlock;
    
    IBOutlet graphLegend       *gLegend;
             bool               _first;

    
    
}
@property (retain) NSMutableArray   *colorTbl;
@property (retain) NSGradient       *backgroundGradient;
@property (retain) NSImage          *spectrumImage;
@property (retain) NSImage          *waterfallImage;
@property (retain) NSBezierPath     *aPath;
@property          NSRect           waveViewRect;
@property          NSRect           waterfallRect;
@property          NSRect           waterfallInRect;
@property          NSDictionary     *attributes;
@property          NSPoint          *lineBuf;

@property          uint8_t          *waterfallGraph;

@property          dispatch_queue_t  wideGraphQueue;
@property (retain) NSAffineTransform *transform;

@property          graphLegend       *gLegend;

@property float   *fftInput;
@property COMPLEX_SPLIT complexSplitA;
@property FFTSetup fftSetup;
@property uint32_t log2n;

@property double  *ssum;
@property double  *w3;
@property double  *scale;
@property double  *s;
@property double  *splot; //splot[NSMAX];
@property double  *swide; //swide[2048];
@property double  px;
@property double  df3;
@property double  slope;
@property double  ourHeight;
@property double  ourWidth;
@property double  maxScreensize;
@property double  bandwidth;
@property int     nbpp;
@property int     nWaterfallIterations;
@property int     ihsym;
@property int     ntrperiod;
@property int     waterfallIndex;
@property int     masterClockSec;






-(void) dataSink2;
-(void) drawWaterfall;
-(void) setPalette : (NSString*) palette;
-(void) drawRect:(NSRect)dirtyRect;
-(id)   initWithFrame:(NSRect)frame;
//-(void) initSharedMem : (void*)mem_jt9;
//-(void) scrollWaterfallGraph;
-(void) scrollWaterfallImage;
-(void) paintTwoDWave;
-(void) myCreateTimer;
//-(void) resetBinsPerPixel;
//-(void) waterfallFFT ;
//-(void) fftw3  : (int)nfft ;
-(void) waterfallFFT2;
-(void) setUpFFT;


-(dispatch_source_t) CreateDispatchTimer :(uint64_t) interval
                                         :(uint64_t) leeway
                                         :(dispatch_queue_t) queue
                                         :(dispatch_block_t) block ;
-(void)killWaterfallTimer;
-(void)mouseDown:(NSEvent *)theEvent;


@end
