//
//  waterfallWinDelegate.m
//  wsjtx
//
//  Created by Joe Mastroianni on 10/12/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import "waterfallWinDelegate.h"

@implementation waterfallWinDelegate

@synthesize theWaterfall  = _theWaterfall;
@synthesize window        = _window;
@synthesize gLegend       = _gLegend;

-(void) awakeFromNib   {
    NSButton *b = [_window standardWindowButton:NSWindowCloseButton];  //closing the window doesn't actually free the memory...
    [b setTarget:self];
    [b setAction:@selector(closeButtonClicked)];
    [self setupWaterfallControllers];

}


-(void) closeButtonClicked {  //was trying to use this to kill the waterfall graph and free memory but closing the window doesn't free anything...just makes it invisible
    //[_theWaterfall killWaterfallTimer];
    [_window close];
}

-(void)setupWaterfallControllers {
    // wide graph view initialize
    
    [self setValue:[NSNumber numberWithInt:14] forKey:@"m_inGain"];
    [self valueForKey:@"m_inGain"];
    //NSLog(@"m_inGain = %@",numBer1);
    
    [self setValue:[NSNumber numberWithInt:2] forKey:@"m_plotGain"];
    [self valueForKey:@"m_plotGain"];
    //NSLog(@"m_plotGain = %@",numBer2);
    
    [self setValue:[NSNumber numberWithInt:3] forKey:@"m_binsPerPixel"];
    [self valueForKey:@"m_binsPerPixel"];
    //NSLog(@"m_binsPerPixel = %@",numBer3);
    
    [self setValue:[NSNumber numberWithInt:2] forKey:@"m_plotZero"];
    [self valueForKey:@"m_plotZero"];
    
    [self setValue:[NSNumber numberWithDouble:-0.5] forKey:@"m_slope"];
    [self valueForKey:@"m_slope"];
    
}



-(int32_t)m_inGain{
    return gSettings.m_inGain;
}
-(int32_t)m_plotGain{
    return gSettings.m_plotGain;
}

-(int32_t)m_binsPerPixel {
    return gSettings.m_binsPerPixel;
}

-(int32_t)m_plotZero {
    return gSettings.m_plotZero;
}

-(double) m_slope {
    return gSettings.m_slope;
}

-(void)setM_slope :(double)x {
    gSettings.m_slope = x;
}

-(void)setM_plotZero : (int32_t)x {
    gSettings.m_plotZero = x;
}

-(void)setM_inGain :(int)x {
    gSettings.m_inGain = (int32_t)x;
}
-(void)setM_plotGain : (int)x{
    gSettings.m_plotGain = x;
}

-(void)setM_binsPerPixel : (int32_t)x {
    gSettings.m_binsPerPixel = x;
    //[_theWaterfall resetBinsPerPixel];
}


@end
