//
//  qsoManager.h
//  wsjtx
//
//  Created by Joe Mastroianni on 9/23/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import <Cocoa/Cocoa.h>
#import "externSettings.h"
#import "wjPlayer.h"
#import "graphLegend.h"
#import "sequencer.h"



@interface qsoManager : NSObject{
    
    
    NSString             *_CQ;
    NSString             *_fontName;
    NSInteger            _fontSize;
    NSAttributedString   *_s2;
    
}

@property (retain)  IBOutlet NSTextView           *qV;
@property (retain)  IBOutlet NSTextField          *theMessage;
@property (retain)  IBOutlet NSTextField          *xmitFreq;
@property (retain)  IBOutlet NSTextView           *xmittedLineView;
@property (retain)  IBOutlet graphLegend          *gLegend;

@property (retain)  NSString             *lineIn;
@property (retain)  NSTextStorage        *ts;
@property (retain)  NSDictionary         *greenBackDict;
@property (retain)  NSDictionary         *whiteBackDict;
@property (retain)  NSDictionary         *redBackDict;
@property (retain)  NSDictionary         *heardStationDict;
@property (retain)  NSImage              *dot;
@property (retain)  NSTextAttachmentCell *ac;
@property (retain)  NSTextAttachment     *at;
@property (retain)  NSMutableArray       *qsoWords;
@property (retain)  NSMutableArray       *transmittedLines;
@property (retain)  wjPlayer             *wPlayer;

@property (retain)  NSMutableString      *messageString;
@property (retain)  NSAttributedString   *s2;
@property (retain)  NSColor              *transmittedBackground;
@property (retain)  NSColor              *heardBackground;

@property (retain)  NSTextStorage        *xmitStorage;
@property (retain)  NSMutableDictionary  *callsAndFreqs;
@property (retain)  NSMutableArray       *qsoLines;
@property (retain)  NSMutableArray       *heardStations;
@property           int                  *qsoLocations;
@property           int                  qsoSequence;
@property           sequencer            *theSequencer;


-(void) appendData : (NSData*) d;
-(void) processLineOfWords:(NSArray *)words;
-(void) startQSOWithThisGuy: (NSString*)s;
-(void) generateTonesForMessage;
-(void) chooseThisThingToSay: (NSString*)s : (long)location;
-(void) setM_qsoInProgress:(bool)x;
-(void) postTransmittedLines;
-(void) abortTransmit;
-(void) addReceivedQSOLine : (NSString*) s;
-(void) testLine;
-(void) parseAllInputLinesAndBuildDictionary : (NSMutableArray*)inputLines;
-(void) setTransmitFrequency : (int)x;
-(void) toggleXmitSequence;
-(void) informLog : (bool) dupe;
-(void) informSign;


@end