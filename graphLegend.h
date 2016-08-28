//
//  graphLegend.h
//  wsjtx
//
//  Created by Joe Mastroianni on 10/13/13.
//
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import <Cocoa/Cocoa.h>
#include "externSettings.h"

#define XMITBRACKET_H 10.0
#define MAXLEGENDS 50
#define LEGENDDISTANCE 200

@interface graphLegend : NSView {
    
    
    IBOutlet NSTextField *xmitFreq;
        
}

@property (retain)  NSGradient           *backgroundGradient;
@property (retain)  NSBezierPath         *xmitBounds;
@property (retain)  NSImage              *legendImage;
@property           NSRect                legendRect;
@property           NSDictionary         *callsignAttributes;
@property           NSMutableDictionary  *callsAndFreqs;
@property           NSTextField          *xmitFreq;



-(void) paintXmitFreq : (int) freq : (int) bandwidth;
-(void) drawQSOsAtFreqs : (NSMutableDictionary*) callsAndFreqs;
-(int)  XfromFreq: (float)f;
-(float)FreqfromX: (int)x;
-(void) mouseDown: (NSEvent *)theEvent;

@end
