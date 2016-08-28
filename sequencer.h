//
//  sequencer.h
//  wsjtx
//
//  Created by Joe Mastroianni on 10/16/13.
//  Copyright (c) 2013 Joe Mastroianni. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "externSettings.h"

@interface sequencer : NSObject {
    
}

@property    int                 sequenceCount;
@property    NSMutableArray     *sequenceLines;
@property    NSTextField        *theMessage;
@property    int                *qsoLocations;
@property    int                 sequenceMax;
@property    int                 transmissionFreq;
@property    NSTextField        *xmitFreq;


-(NSString*) toggleXmitSequence;
-(bool)determineIfThisIsOnMyFrequency: (NSString*)s;
//-(void)checkTest;

@end
