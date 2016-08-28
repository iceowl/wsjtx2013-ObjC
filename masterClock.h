//
//  masterClock.h
//  wsjtx
//
//  Created by Joe Mastroianni on 10/19/13.
//  Copyright (c) 2013 Joe Mastroianni. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "externSettings.h"

extern dispatch_source_t cTimer;

typedef void (^TimeBlock)(void);

@interface masterClock : NSView {
    
//    NSGradient        *backgroundGradient;
//    NSGradient        *backgroundGradientTransmit;
//    NSImage           *timeImage;
//    NSDictionary      *timeTextAttributes;
//    NSDictionary      *utcTextAttributes;
//    NSRect             timeViewRect;
//    NSMutableString   *timeString;
//    NSMutableString   *utcTimeString;
//    NSDateFormatter   *dFormat;
    TimeBlock          _tBlock;
    
}

@property (retain) NSGradient      *backgroundGradient;
@property (retain) NSGradient      *backgroundGradientTransmit;
@property (retain) NSImage         *timeImage;
@property (retain) NSDictionary    *timeTextAttributes;
@property (retain) NSDictionary    *utcTextAttributes;
@property (retain) NSMutableString *timeString;
@property (retain) NSDateFormatter *dFormat;
@property (retain) NSMutableString *utcTimeString;
@property          NSRect           timeViewRect;


-(void)killClockTimer;

@end
