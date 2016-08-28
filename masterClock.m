//
//  masterClock.m
//  wsjtx
//
//  Created by Joe Mastroianni on 10/19/13.
//  Copyright (c) 2013 Joe Mastroianni. All rights reserved.
//

#import "masterClock.h"

@implementation masterClock


@synthesize backgroundGradientTransmit   = _backgroundGradientTransmit;
@synthesize backgroundGradient = _backgroundGradient;
@synthesize timeImage          = _timeImage;
@synthesize timeTextAttributes = _timeTextAttributes;
@synthesize utcTextAttributes  = _utcTextAttributes;
@synthesize timeViewRect       = _timeViewRect;
@synthesize timeString         = _timeString;
@synthesize utcTimeString      = _utcTimeString;
@synthesize dFormat            = _dFormat;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBackgroundGradient];
        
        _timeTextAttributes =   [NSDictionary  dictionaryWithObjectsAndKeys:
                                [NSFont fontWithName:@"Times" size:16],NSFontAttributeName,
                                [NSColor whiteColor], NSForegroundColorAttributeName,
                                // [[NSNumber alloc] initWithFloat:0.2],NSExpansionAttributeName,
                                nil];
        _utcTextAttributes =    [NSDictionary  dictionaryWithObjectsAndKeys:
                                [NSFont fontWithName:@"Times" size:20],NSFontAttributeName,
                                [NSColor whiteColor], NSForegroundColorAttributeName,
                                 //[[NSNumber alloc] initWithFloat:0.2],NSExpansionAttributeName,
                                nil];

        _timeString    = [[NSMutableString alloc] init];
        _utcTimeString = [[NSMutableString alloc] init];
        _dFormat       = [[NSDateFormatter alloc] init];
        [_dFormat setDateFormat:@"hh:mm:ss"];
        [self myCreateTimer];
        
    }
    return self;
}


- (void)awakeFromNib {
    _timeViewRect = [self bounds];
    _timeImage    = [[NSImage alloc] initWithSize:_timeViewRect.size];
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
	if(!cTimer ) {
        [self myCreateTimer];
    }
    
    //[_backgroundGradient drawInRect:_timeViewRect angle:90.0];
    if(_timeImage) {
        [_timeImage drawInRect:_timeViewRect fromRect:NSZeroRect   operation:NSCompositeSourceOver fraction:1.0];
    }
}

-(void) drawTime {
    if(_timeString) {
        [_timeString deleteCharactersInRange:NSMakeRange(0, [_timeString length])];
        [_timeString appendString:[_dFormat stringFromDate:[NSDate date]]];
    }
    if(_utcTimeString) {
        [_utcTimeString deleteCharactersInRange:NSMakeRange(0, [_utcTimeString length])];
        CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
        CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(at, NULL);
        [_utcTimeString appendString:[NSString stringWithFormat:@"%2.2d:%2.2d:%2.2d",gd.hour,gd.minute,(int)floor(gd.second)]];
    }
    if(_timeImage) {
        [_timeImage lockFocus];
        if(gSettings.m_transmitting)[_backgroundGradientTransmit drawInRect:_timeViewRect angle:90.0];
        else [_backgroundGradient drawInRect:_timeViewRect angle:90.0];
        [_timeString drawAtPoint:NSMakePoint(47.0, 5.0) withAttributes:_timeTextAttributes];
        [_utcTimeString drawAtPoint:NSMakePoint(40.0, _timeViewRect.size.height - 30.0) withAttributes:_utcTextAttributes];
        [_timeImage unlockFocus];
        [self setNeedsDisplay:YES];
    }
    
    
}


- (void)setupBackgroundGradient
{
    // create a basic gradient for the background of the view
    
    CGFloat red1   = 0.0; //   0.0 / 255.0;
    CGFloat green1 = 0.0; // 72.0 / 255.0;
    CGFloat blue1  = 0.0; //127.0 / 255.0;
    
    CGFloat red2    =  0.0/255.0;
    CGFloat green2  = 20.0/255.0; //43.0 / 255.0;
    CGFloat blue2   = 80.0/255.0;//76.0 / 255.0;
    
    NSColor* gradientTop    = [NSColor colorWithCalibratedRed:red1 green:green1 blue:blue1 alpha:1.0];
    NSColor* gradientBottom = [NSColor colorWithCalibratedRed:red2 green:green2 blue:blue2 alpha:1.0];
    
    NSGradient* gradient;
    gradient = [[NSGradient alloc] initWithStartingColor:gradientBottom endingColor:gradientTop];
    
    _backgroundGradient = gradient;
    
    
    CGFloat red4    = 130.0/255.0;
    CGFloat green4  =   0.0/255.0; //43.0 / 255.0;
    CGFloat blue4   =  20.0/255.0;//76.0 / 255.0;
    
    NSColor* gradientTop1    = [NSColor colorWithCalibratedRed:red1 green:green1 blue:blue1 alpha:1.0];
    NSColor* gradientBottom1 = [NSColor colorWithCalibratedRed:red4 green:green4 blue:blue4 alpha:1.0];
    
    NSGradient* gradient2;
    gradient2 = [[NSGradient alloc] initWithStartingColor:gradientBottom1 endingColor:gradientTop1];
    
    _backgroundGradientTransmit = gradient2;

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
     __block masterClock* bSelf = self; // capture  so as to not have compiler complain about ARC retain cycles...dunno if this is going to be a problem.
    
    cTimer = [self  CreateDispatchTimer :500ull * NSEC_PER_MSEC
                                        :10ull * NSEC_PER_MSEC
                                        :dispatch_queue_create("com.owlhousetoys.wsjtx2", DISPATCH_QUEUE_SERIAL)
                                        :_tBlock = ^{
                                            [bSelf drawTime];
                                            usleep(100000);
                                        }];
    
    [_tBlock copy]; // copy to heap so not sitting on stack with all those self vars...
    
    
}


-(void)killClockTimer {
    if(cTimer) dispatch_source_cancel(cTimer);
}



@end
