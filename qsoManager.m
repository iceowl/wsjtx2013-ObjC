//
//  qsoManager.m
//  wsjtx
//
//  Created by Joe Mastroianni on 9/23/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import "qsoManager.h"

@implementation qsoManager

@synthesize lineIn           = _lineIn;
@synthesize ts               = _ts;
@synthesize greenBackDict    = _greenBackDict;
@synthesize whiteBackDict    = _whiteBackDict;
@synthesize redBackDict      = _redBackDict;
@synthesize heardStationDict = _heardStationDict;
@synthesize dot              = _dot;
@synthesize ac               = _ac;
@synthesize at               = _at;
@synthesize qV               = _qV;
@synthesize qsoWords         = _qsoWords;
@synthesize wPlayer          = _wPlayer;
@synthesize theMessage       = _theMessage;
@synthesize messageString    = _messageString;
@synthesize s2               = _s2;
@synthesize transmittedLines = _transmittedLines;
@synthesize transmittedBackground = _transmittedBackground;
@synthesize heardBackground  = _heardBackground;
@synthesize xmitFreq         = _xmitFreq;
@synthesize xmittedLineView  = _xmittedLineView;
@synthesize xmitStorage      = _xmitStorage;
@synthesize qsoLocations     = _qsoLocations;
@synthesize qsoSequence      = _qsoSequence;
@synthesize callsAndFreqs    = _callsAndFreqs;
@synthesize gLegend          = _gLegend;
@synthesize qsoLines         = _qsoLines;
@synthesize theSequencer     = _theSequencer;
@synthesize heardStations    = _heardStations;


- (id)init
{
    self = [super init];
    if (self) {
        // something
        
        _fontName = @"Arial";
        _fontSize = 12;
        
        _transmittedBackground = [NSColor colorWithCalibratedRed:1.0 green:0.5 blue:0.5 alpha:1.0];
        _heardBackground = [NSColor colorWithCalibratedRed:0.9 green:0.5 blue:0.9 alpha:1.0];
        
        _greenBackDict =    [NSDictionary  dictionaryWithObjectsAndKeys:
                             [NSFont fontWithName:_fontName size:_fontSize],NSFontAttributeName,
                             [NSColor blackColor], NSForegroundColorAttributeName,
                             //[[NSNumber alloc] initWithFloat:0.2],NSExpansionAttributeName,
                             [NSColor greenColor], NSBackgroundColorAttributeName,
                             nil];
        
        _whiteBackDict =    [NSDictionary  dictionaryWithObjectsAndKeys:
                             [NSFont fontWithName:_fontName size:_fontSize],NSFontAttributeName,
                             [NSColor blackColor], NSForegroundColorAttributeName,
                             //[[NSNumber alloc] initWithFloat:0.2],NSExpansionAttributeName,
                             [NSColor whiteColor], NSBackgroundColorAttributeName,
                             nil];
        _redBackDict =      [NSDictionary  dictionaryWithObjectsAndKeys:
                             [NSFont fontWithName:_fontName size:_fontSize],NSFontAttributeName,
                             [NSColor blackColor], NSForegroundColorAttributeName,
                             //[[NSNumber alloc] initWithFloat:0.2],NSExpansionAttributeName,
                             _transmittedBackground, NSBackgroundColorAttributeName,
                             nil];
        _heardStationDict =      [NSDictionary  dictionaryWithObjectsAndKeys:
                                  [NSFont fontWithName:_fontName size:_fontSize],NSFontAttributeName,
                                  [NSColor blackColor], NSForegroundColorAttributeName,
                                  //[[NSNumber alloc] initWithFloat:0.2],NSExpansionAttributeName,
                                  _heardBackground, NSBackgroundColorAttributeName,
                                  nil];
        
        
        _CQ = @"CQ";
        
        
        _dot = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"red-dot" ofType:@"png"]];
        _ac = [[NSTextAttachmentCell alloc] initImageCell:_dot];
        _at = [[NSTextAttachment alloc] init];
        [_at setAttachmentCell: _ac ];
        _s2 = [NSAttributedString attributedStringWithAttachment:_at];
        //        NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment: attachment];
        //        [[textView textStorage] appendAttributedString:attributedString];
        
        _qsoWords = [[NSMutableArray alloc] initWithCapacity:20];
        
        [self setValue:[NSNumber numberWithInt:0] forKey:@"m_qsoInProgress"];
        [self valueForKey:@"m_qsoInProgress"];
        
        _transmittedLines = [[NSMutableArray alloc] initWithCapacity:20];
        _qsoLocations     = malloc(10*sizeof(int));
        _qsoLines         = [[NSMutableArray alloc] initWithCapacity:25];
        _qsoSequence      = 0;
        
        _callsAndFreqs = [NSMutableDictionary dictionary];
        
    }
    return self;
}

-(void) awakeFromNib {
    NSString *s = @"CQ AL3A CM94";
    [_theMessage setStringValue:s];
    _ts = [_qV textStorage];
    _theSequencer               = [[sequencer alloc] init];
    _theSequencer.theMessage    = _theMessage;
    _theSequencer.sequenceLines = _qsoLines;
    _theSequencer.qsoLocations  = _qsoLocations;
    _theSequencer.xmitFreq      = _xmitFreq;
    
}

-(void) generateTonesForMessage {
    
    [[_theMessage window] makeFirstResponder:[_theMessage window]]; // validate the contents of the message and transmit freq NSTextViews...hopefully negates crashes
    //[_theMessage validateEditing];
    [_theMessage setSelectable:NO];
    
    // [_xmitFreq validateEditing];
    [_xmitFreq setSelectable:NO];
    
    if(_xmitFreq != nil) {
        gSettings.m_txFreq = (int)[_xmitFreq integerValue];
    }
    
    _wPlayer.thePlayer->imDone = FALSE;
    
    //  NSString *sm = [[NSString alloc] initWithFormat:@"%@",[_theMessage stringValue]];// make sure we get a NEW string not just pointer copy
    NSString *ss = [[NSString alloc] initWithFormat:@"%@",[_wPlayer generateTones:[_theMessage stringValue]]];
    NSAttributedString *message = [[NSAttributedString alloc] initWithString:ss attributes:_redBackDict];
    
    [_theMessage setAttributedStringValue:message];
    [_theMessage validateEditing];
    
    [_transmittedLines addObject:message];
    
    [self checkFor73:ss];
    
    
}

-(void)testLine {
    
    [[_theMessage window] makeFirstResponder:[_theMessage window]]; // validate the contents of the message and transmit freq
    NSString *ss = [[NSString alloc] initWithFormat:@"%@",[_wPlayer generateTones:[_theMessage stringValue]]];
    NSAttributedString *message = [[NSAttributedString alloc] initWithString:ss attributes:_redBackDict];
    [_theMessage setAttributedStringValue:message];
    [_theMessage validateEditing];
    
}

- (void)appendData:(NSData *)d
{
    
    
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    
    [_ts replaceCharactersInRange:NSMakeRange([_ts length], 0)
                       withString:s];
    
    
    // NSLog(@"%@",[ts string]);
    
}

-(void)abortTransmit {
    [_xmitFreq  setSelectable:YES];
    [_xmitFreq  setEditable:YES];
    [_theMessage setSelectable:YES];
    [_theMessage setEditable:YES];
    NSString *sm = [[NSString alloc] initWithFormat:@"%@",[_theMessage stringValue]];// make sure we get a NEW string not just
    NSAttributedString *message = [[NSAttributedString alloc] initWithString:sm attributes:_whiteBackDict];
    [_theMessage setAttributedStringValue:message];
    [_theMessage validateEditing];
    
}


-(void)startQSOWithThisGuy : (NSString*) s{
    
    // NSArray *words = [s componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *words = [s componentsSeparatedByString:@" "];
    //  int k = 0;
    for(int i = 1; i<[words count];i++){
        if(![[words objectAtIndex:i] isEqualToString:@""]) {
            [_qsoWords addObject:[words objectAtIndex:i]];
            //  NSLog(@" %d = %@",k++,[words objectAtIndex:i]);
        }
        
    }
    
    gSettings.m_txFreq = (int)[[_qsoWords objectAtIndex:FREQINDEX] integerValue];
    gSettings.m_hisCall = [_qsoWords objectAtIndex:HISCALLINDEX];
    
    
    [_xmitFreq setStringValue:[[NSString alloc] initWithFormat:@"%d",gSettings.m_txFreq]];
    
    [self manufactureQSOExchange];
    
    [_qsoWords removeAllObjects];
    //  NSLog(@"message string = %@",_messageString);
    
    
}




-(void)setTransmitFrequency : (int) xFreq {
    
    gSettings.m_txFreq = xFreq;
    [_xmitFreq setStringValue:[[NSString alloc] initWithFormat:@"%d",gSettings.m_txFreq]];
    
}


-(void)appendTheString:(NSMutableString*)s {
    
    
    NSAttributedString *s1;
    NSRange r = [s rangeOfString:_CQ];
    NSRange r1 = [s rangeOfString:gSettings.m_myCall];
    // NSLog(@"location = %ld",r.location);
    if((r.location == NSNotFound) && (r1.location == NSNotFound)){
        s1 = [[NSAttributedString alloc] initWithString:s attributes: _whiteBackDict];
    } else if(r1.location != NSNotFound) {
        s1 = [[NSAttributedString alloc] initWithString:s attributes:_redBackDict];
    } else if(r.location != NSNotFound) {
        //NSAttributedString *s2 = [NSAttributedString attributedStringWithAttachment:_at];
        [_ts replaceCharactersInRange:NSMakeRange([_ts length], 0)
                 withAttributedString:_s2];
        s1 = [[NSAttributedString alloc] initWithString:s attributes:_greenBackDict];
        
    }
    [_ts replaceCharactersInRange:NSMakeRange([_ts length], 0)
             withAttributedString:s1];
    
    
    
}

-(void) parseAllInputLinesAndBuildDictionary : (NSMutableArray*) inputLines {
    
    [_qsoWords removeAllObjects];
    [_callsAndFreqs removeAllObjects];
    
    
    for(int i=0;i < [inputLines count]; i++){
        NSArray *words = [[inputLines objectAtIndex:i] componentsSeparatedByString:@" "];;
        for(int j = 1; j<[words count];j++){
            if(![[words objectAtIndex:j] isEqualToString:@""]) {
                [_qsoWords addObject:[words objectAtIndex:j]];
                //  NSLog(@" %d = %@",k++,[words objectAtIndex:i]);
            }
            
        }
        NSString *hisCall1 = [_qsoWords objectAtIndex:HISCALLINDEX];
        NSMutableString *hisCall2 = [[NSMutableString alloc] initWithString:[_qsoWords objectAtIndex:HISCALLINDEX2]];
        [hisCall2 appendString:@" "];
        [hisCall2 appendString:hisCall1];
        NSString *qFreq  = [[NSString alloc] initWithString:[_qsoWords objectAtIndex:FREQINDEX]];
        [_callsAndFreqs setObject:hisCall2 forKey:qFreq];
        [_qsoWords removeAllObjects];
    }
    
    
    [_gLegend drawQSOsAtFreqs:_callsAndFreqs];
    
}

-(void) processLineOfWords:(NSArray *)words {
    
    
    
    //   NSMutableArray *words2 = [[NSMutableArray alloc]initWithCapacity:20];
    NSMutableString *words2 = [[NSMutableString alloc] initWithCapacity:40];
    for( int i = 0;i<[words count];i++) {
        if ([[words objectAtIndex:i] length]) {
            [words2 appendString:[words objectAtIndex:i]];
            [words2 appendString:@" "];
            
        }
    }
    // NSLog(@"words 2 = %@",words2);
    [self appendTheString:words2];
    
}

-(void)postTransmittedLines {
    _xmitStorage = [_xmittedLineView textStorage];
    NSRange r1;
    r1.length = [_xmitStorage length];
    r1.location = 0;
    [_xmitStorage deleteCharactersInRange:r1];
    
    if([_transmittedLines count] > 0){
        for(int i=0;i<[_transmittedLines count];i++){
            if([_transmittedLines objectAtIndex:i] != nil) {
                [_xmitStorage replaceCharactersInRange:NSMakeRange([_xmitStorage length], 0)
                                  withAttributedString:[_transmittedLines objectAtIndex:i]];
                [_xmitStorage replaceCharactersInRange:NSMakeRange([_xmitStorage length], 0)
                                            withString:@"\n"];
            }
        }
    }
    
    [_xmitFreq  setSelectable:YES];
    [_xmitFreq  setEditable:YES];
    [_theMessage setSelectable:YES];
    [_theMessage setEditable:YES];
}

-(void)addReceivedQSOLine : (NSString*) sIn {
    
    _ts = [_qV textStorage];
    NSMutableString *s = [_ts mutableString];
    NSAttributedString *sInAttributed = [[NSAttributedString alloc] initWithString:sIn attributes:_greenBackDict];
    NSRange r = [s rangeOfString:@"\n - - \n"];
    if(r.location != NSNotFound) {
        long index = ++r.location;
        r.length = 4;
        [_ts deleteCharactersInRange:r];
        [_ts insertAttributedString:sInAttributed atIndex:index];
    }
    [self setM_qsoInProgress:TRUE];
}

-(void)toggleXmitSequence {
    [_theSequencer toggleXmitSequence];
}



-(void)manufactureQSOExchange {
    
    [_qsoLines removeAllObjects];
    // [self postTransmittedLines];
    _ts = [_qV textStorage];
    NSRange r1;
    r1.length = [_ts length];
    r1.location = 0;
    [_ts deleteCharactersInRange:r1];
    
    _theSequencer.sequenceCount = 0;
    _qsoSequence = 0;
    
    
    NSRange r;
    
    _messageString = [[NSMutableString alloc]init];
    [_messageString appendString:gSettings.m_hisCall];
    [_messageString appendString:@" "];
    [_messageString appendString:gSettings.m_myCall];
    [_messageString appendString:@" "];
    r.location  = (int)[_messageString length];
    r.length = (int)[gSettings.m_myGrid length];
    [_messageString appendString:gSettings.m_myGrid];
    
    [self addQSOLine];
    
    if(![self haveIAlreadyHadaQSOWithThisGuy]) [_theMessage setStringValue:_messageString];
    else {
        NSAttributedString *heardThisGuy = [[NSAttributedString alloc] initWithString:_messageString  attributes:_heardStationDict];
        [_theMessage setAttributedStringValue:heardThisGuy];
    }
    
    [_theMessage validateEditing];
    
    [_messageString deleteCharactersInRange:r];
    
    [_messageString appendString:[_qsoWords objectAtIndex:STRENGTHINDEX]];
    
    [self addQSOLine];
    
    r.length = (int)[[_qsoWords objectAtIndex:STRENGTHINDEX] length];
    [_messageString deleteCharactersInRange:r];
    [_messageString appendString:@"RRR"];
    
    [self addQSOLine];
    
    r.length = 3;
    [_messageString deleteCharactersInRange:r];
    [_messageString appendString:@"73"];
    
    [self addQSOLine];
    
    [_messageString stringByAppendingString:@""];
    _theSequencer.sequenceCount = 0;
    //[_theSequencer checkTest];
    
    
}

-(void) informLog : (bool) dupe {
    
    if(dupe) {
        NSMutableString *informString = [[NSMutableString alloc] initWithString:gSettings.m_hisCall];
        [informString appendString:@" is a duplicate QSO \n"];
        [_ts replaceCharactersInRange:NSMakeRange([_ts length], 0) withString:informString];
        [_qV setNeedsDisplay:YES];
        return;
    }
    
    
    if(gSettings.m_hisCall) {
        NSMutableString *informString = [[NSMutableString alloc] initWithString:@" logging QSO with:"];
        [informString appendString:gSettings.m_hisCall];
        [informString appendString:@"\n"];
        [_ts replaceCharactersInRange:NSMakeRange([_ts length], 0) withString:informString];
        [_qV setNeedsDisplay:YES];
    }
    
    return;
    
}

-(void) informSign {
    _xmitStorage = [_xmittedLineView textStorage];
    [_xmitStorage replaceCharactersInRange:NSMakeRange([_xmitStorage length], 0) withString:@"signing after next transmission\n"];
    
}

-(void)addQSOLine {
    
    int location;
    
    [_ts replaceCharactersInRange:NSMakeRange([_ts length], 0)
             withAttributedString:_s2];
    [_ts replaceCharactersInRange:NSMakeRange([_ts length], 0)
                       withString:_messageString];
    location = (int)[_ts length];
    [_ts replaceCharactersInRange:NSMakeRange([_ts length], 0)
                       withString:@" \n - - \n"];
    _qsoLocations[_qsoSequence] = location;
    NSString *s = [[NSString alloc]initWithString:_messageString];
    [_qsoLines insertObject:s  atIndex:_qsoSequence];
    _theSequencer.sequenceMax = _qsoSequence;
    _qsoSequence++;
    
}

-(void)chooseThisThingToSay : (NSString*) s : (long)location{
    
    
    
    for(int i=0;i<[_qsoLines count];i++) {
        if([s isEqualToString:[_qsoLines objectAtIndex:i]]){
            _theSequencer.sequenceCount = i;
            //  NSLog(@" chose line #  %d input Location = %lu",i,location);
            break;
        }
    }
    if(![self haveIAlreadyHadaQSOWithThisGuy]) [_theMessage setStringValue:s];
    else {
        NSAttributedString *heardThisGuy = [[NSAttributedString alloc] initWithString:s  attributes:_heardStationDict];
        [_theMessage setAttributedStringValue:heardThisGuy];
    }
    [self setM_qsoInProgress:TRUE];
    [self checkFor73:s];
}

-(bool)haveIAlreadyHadaQSOWithThisGuy {
    
    bool alreadyHeard = FALSE;
    for(int i = 0;i<[_heardStations count];i++) {
        if( [[_heardStations objectAtIndex:i] isEqualToString:gSettings.m_hisCall]){
            alreadyHeard = TRUE;
            break;
        }
    }
    return alreadyHeard;
    
}

-(void)checkFor73: (NSString*) s{
    NSRange r = [s rangeOfString:@"73"];
    if(r.location != NSNotFound){
        gSettings.m_sent73 = TRUE;
    } else {
        gSettings.m_sent73 = FALSE;
    }
    
}


-(bool)m_qsoInProgress {
    return gSettings.m_qsoInProgress;
}

-(void)setM_qsoInProgress : (bool) x {
    gSettings.m_qsoInProgress = x;
    
    [self valueForKey:@"m_qsoInProgress"];
    
}


@end
