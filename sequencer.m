//
//  sequencer.m
//  wsjtx
//
//  Created by Joe Mastroianni on 10/16/13.
//  Copyright (c) 2013 Joe Mastroianni. All rights reserved.
//

#import "sequencer.h"

@implementation sequencer

@synthesize sequenceCount       = _sequenceCount;
@synthesize sequenceLines       = _sequenceLines;
@synthesize theMessage          = _theMessage;
@synthesize qsoLocations        = _qsoLocations;
@synthesize sequenceMax         = _sequenceMax;
@synthesize transmissionFreq    = _transmissionFreq;
@synthesize xmitFreq            = _xmitFreq;

-(id) init {
    
    self = [super init];
    if(self) {
        
        _sequenceCount = 0;
        _sequenceMax   = 0;
        
    }
    
    return self;
}

-(NSString*) toggleXmitSequence {
    
    _sequenceCount++;
    if(_sequenceCount <= _sequenceMax) {
    NSString *s = [_sequenceLines objectAtIndex:_sequenceCount];
    [_theMessage setStringValue:s];
    return s;
    }
    
    return nil;
    
}

//-(void) checkTest {
//    _sequenceCount = 1;
//    return;
//}

-(bool) determineIfThisIsOnMyFrequency : (NSString*) s {
    
    _transmissionFreq = (int)[_xmitFreq integerValue];
    
    NSArray *words = [s componentsSeparatedByString:@" "];
    int k = 0;
    for(int i = 1; i<[words count];i++){
        if(![[words objectAtIndex:i] isEqualToString:@""]) {
            if(k == FREQINDEX) {
                NSString *ss = [words objectAtIndex:i];
                float kk = [ss floatValue];
                if((kk >= (_transmissionFreq-gSettings.m_receiveTolerance)) && (kk<= (_transmissionFreq+gSettings.m_receiveTolerance))) {
                    return true;
                } else {
                    return false;
                }
                
            }
            k++;
        }
        
    }
    return false;
}



@end
