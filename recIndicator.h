//
//  recIndicator.h
//  wsjtx
//
//  Created by Joe Mastroianni on 9/21/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import <Cocoa/Cocoa.h>

//I don't remember what these globals are for... I think I put them here before I made the gSettings object, which has all this stuff in other forms...

bool recording;
bool active;
bool transmitting;

@interface recIndicator : NSBox

@property bool recording;
@property bool active;
@property bool transmitting;

-(void)setRecording:(bool)recording;
-(void)setActive:(bool)active;

@end
