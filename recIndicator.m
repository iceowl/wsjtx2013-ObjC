//
//  recIndicator.m
//  wsjtx
//
//  Created by Joe Mastroianni on 9/21/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import "recIndicator.h"



@implementation recIndicator

@dynamic recording;
@dynamic active;
@dynamic transmitting;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        recording = FALSE;
        // Initialization code here.
    }
    return self;
}


-(void)setTransmitting:(bool)inTr{
    transmitting = inTr;
    [self setNeedsDisplay:YES];
    
}
-(void) setRecording:(bool)inR{
    recording = inR;
    [self setNeedsDisplay:YES];
}

-(void)setActive:(bool)inA {
    active = inA;
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
   // NSBezierPath *aPath = [NSBezierPath bezierPathWithRect:[self bounds]];
   // [aPath setLineWidth:4.0];
    if(!active) {
        [[NSColor clearColor]set];
        
    } else if(recording && !transmitting){
        [[NSColor yellowColor] set];
        
    } else if(transmitting){
        [[NSColor redColor] set];
        
    } else {
        [[NSColor blueColor] set];
    }
  //  [aPath stroke];
    NSRectFill([self bounds]);
    [self setNeedsDisplay:YES];
}

@end
