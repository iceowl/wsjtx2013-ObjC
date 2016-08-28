//
//  qsoTextView.m
//  wsjtx
//
//  Created by Joe Mastroianni on 10/6/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import "qsoTextView.h"

@implementation qsoTextView

@synthesize qManager = _qManager;

- (void)textView:(NSTextView *)aTextView clickedOnCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex
{
//    NSLog(@"Did Click on cell location= %lu length = %lu  charIndex = %lu",[aTextView selectedRange].location,(unsigned long)[aTextView selectedRange].length,charIndex);
    NSTextStorage *ts = [aTextView textStorage];
    long length       = [ts length];
    NSRange r;
    
    r.location              = charIndex+1; // have to add 1 to get past the /xfc character that represents the dot
    if(length > 21)r.length = 21; // 21 is length of 1 line with nothing else taken into consideration
    else r.length           = length; // maybe it's shorter
    
    NSString  *s = [[NSString alloc] initWithString:[[ts string] substringWithRange:r]];
    NSRange r2   = [s rangeOfString:@"\n"];

    if(r2.location == NSNotFound) {
        [_qManager chooseThisThingToSay:s : charIndex];
    } else {
        NSRange r3;
        r3.location = 0;
        r3.length = r2.location - 1;
        NSString *s2 = [s substringWithRange:r3];
        [_qManager chooseThisThingToSay:s2 : charIndex];
    }
}

@end
