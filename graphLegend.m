//
//  graphLegend.m
//  wsjtx
//
//  Created by Joe Mastroianni on 10/13/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import "graphLegend.h"

@implementation graphLegend

@synthesize backgroundGradient   = _backgroundGradient;
@synthesize legendImage          = _legendImage;
@synthesize legendRect           = _legendRect;
@synthesize xmitBounds           = _xmitBounds;
@synthesize callsignAttributes   = _callsignAttributes;
@synthesize callsAndFreqs        = _callsAndFreqs;
@synthesize xmitFreq             = _xmitFreq;



-(void)awakeFromNib {
    _legendRect  = [self bounds];
    _legendImage = [[NSImage alloc] initWithSize:_legendRect.size];
    [self setupBackgroundGradient];
    
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _xmitBounds = [NSBezierPath bezierPath];
        [_xmitBounds setLineWidth:4.0];
        _callsignAttributes =  [NSDictionary  dictionaryWithObjectsAndKeys:
                                [NSFont fontWithName:@"Times" size:10],NSFontAttributeName,
                                [NSColor whiteColor], NSForegroundColorAttributeName,
                                [[NSNumber alloc] initWithFloat:0.2],NSExpansionAttributeName,
                                nil];
        
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    if(_callsAndFreqs) {
        [self drawQSOsAtFreqs:_callsAndFreqs];
    }
	[_backgroundGradient drawInRect:_legendRect angle:90.0];
    if(_legendImage) {
        [_legendImage drawInRect:_legendRect fromRect:NSZeroRect   operation:NSCompositeSourceOver fraction:1.0];
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
    CGFloat blue2   = 50.0/255.0;//76.0 / 255.0;
    
    NSColor* gradientTop    = [NSColor colorWithCalibratedRed:red1 green:green1 blue:blue1 alpha:1.0];
    NSColor* gradientBottom = [NSColor colorWithCalibratedRed:red2 green:green2 blue:blue2 alpha:1.0];
    
    NSGradient* gradient;
    gradient = [[NSGradient alloc] initWithStartingColor:gradientBottom endingColor:gradientTop];
    
    _backgroundGradient = gradient;
    
}

-(void) paintXmitFreq : (int) freq : (int) bandwidth {
    
    
    [_xmitBounds removeAllPoints];
    [_xmitBounds moveToPoint:NSMakePoint((float)freq,2.0)];
    [_xmitBounds lineToPoint:NSMakePoint((float)freq,XMITBRACKET_H)];
    [_xmitBounds lineToPoint:NSMakePoint((float)(freq+bandwidth),XMITBRACKET_H)];
    [_xmitBounds lineToPoint:NSMakePoint((float)(freq+bandwidth), 2.0)];
    [_legendImage lockFocus];
    [_backgroundGradient drawInRect:_legendRect angle:90.0];
    [[NSColor redColor] set];
    [_xmitBounds stroke];
    [_legendImage unlockFocus];
    [self setNeedsDisplay:YES];
    
}

-(int) XfromFreq:(float) f                               //XfromFreq()
{
    float y;
    int x;
    switch (gSettings.m_binsPerPixel){
        case 1:  y = 600.0/440.0;
            break;
        case 2:  y = 300.0/440.0;
            break;
        case 3:  y = 200.0/440.0;
            break;
        default: y = 150.0/440.0;
    }
    
    x = (int)(y * f);
    //    m_fftBinWidth = MAX_DISPLAY_FREQ/(_maxScreensize*m_binsPerPixel);
    //    int x = f/(m_binsPerPixel*m_fftBinWidth);
    return x;
}
-(float) FreqfromX:(int) x                               //FreqfromX()
{
    float y;
    
    switch (gSettings.m_binsPerPixel){
        case 1:  y = 600.0/440.0;
            break;
        case 2:  y = 300.0/440.0;
            break;
        case 3:  y = 200.0/440.0;
            break;
        default: y = 150.0/440.0;
    }
    
    //  return float(1000.0 + x*m_binsPerPixel*m_fftBinWidth);
    //  m_fftBinWidth = MAX_DISPLAY_FREQ/(m_binsPerPixel*_maxScreensize);
    // return (float) x*m_binsPerPixel*m_fftBinWidth;
    return x/y;
}



-(void) drawQSOsAtFreqs : (NSMutableDictionary*) cAndF {
    
    _callsAndFreqs = cAndF;
    
    NSArray *a = [_callsAndFreqs allKeys];
    [_legendImage lockFocus];
    [[NSColor whiteColor] set];
    if([a count] != 0) {
        
        double d[MAXLEGENDS];
        int position[MAXLEGENDS];
        for(int i = 0; i< MAXLEGENDS;i++){
            d[i] = 0.0;
            position[i] = 0;
        }
       
        
        for(int i = 0; i<[a count] ;i++){  // lets implement a quick placement algorithm for the text so it doesn't all just run into each other...shall we?
            NSString *value = [_callsAndFreqs objectForKey:[a objectAtIndex:i]];
            //NSLog(@" draw qsos key:value  %@: %@", [a objectAtIndex:i], value);
            position[i] = 1;
            d[i] = [self XfromFreq:[[a objectAtIndex:i] doubleValue]];
            if(i != 0){
                for(int j=0;j<[a count];j++){
                    d[j] = [self XfromFreq:[[a objectAtIndex:j]doubleValue]];
                    if( (abs(d[i] - d[j]) < LEGENDDISTANCE) && (i != j) && (position[i] == position[j])){
                        position[i] = position[j]+1;
                        if(position[i] > 3) position[i]=3;
                        
                    } 
                }
            }
            
            float u = 0.0;
            if(position[i] == 1) u = 0.0;
            else u = 5.0;
            
            [value drawAtPoint:NSMakePoint(d[i],u*position[i]) withAttributes:_callsignAttributes];
            
        }
    }
    [_legendImage unlockFocus];
    
}
- (void)mouseDown:(NSEvent*) theEvent{
    
    if([theEvent clickCount] == 2) {  // only handle double clicks
        
        NSPoint p = [theEvent locationInWindow];
        NSPoint local_point = [self convertPoint:p fromView:nil];
        float freq = [self FreqfromX:(int)local_point.x];
        //NSLog(@" freq at x = %f  is %f",local_point.x, freq);
        gSettings.m_txFreq = (int)freq;
        [_xmitFreq setStringValue:[[NSString alloc] initWithFormat:@"%d",gSettings.m_txFreq]];
        [self paintXmitFreq: (int)local_point.x : gSettings.m_bandwidth];
        
    }
    
    return;
}



@end
