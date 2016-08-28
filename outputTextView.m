//
//  outputTextView.m
//  wsjtx
//
//  Created by Joe Mastroianni on 10/5/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import "outputTextView.h"

@implementation outputTextView

@synthesize qManager = _qManager;


// so far I  only get clicks out of the text view when a "cell" is clicked.  The cells are the little dot pictures I insert
// that indicate either a CQ (blue dot) or a transmission to or from me (red dot)
// could probably handle general mouseDown:(NSEvent*) calls but let's start with this...

- (void)textView:(NSTextView *)aTextView clickedOnCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex
{
 // NSLog(@"Did Click on cell location= %lu length = %lu  charIndex = %lu",[aTextView selectedRange].location,(unsigned long)[aTextView selectedRange].length,charIndex);
    NSTextStorage *ts = [aTextView textStorage];
    NSRange r;
    r.location  = charIndex;
    r.length    = 36;
    NSString *s = [NSString stringWithString:[[ts string] substringWithRange:r]];
    
    [_qManager startQSOWithThisGuy:s];
    
}
//-(void)textViewDidChangeSelection:(NSNotification *)notification {
//   
//   // NSLog(@"textview selection did change ");
//}
//
//-(void) textDidChange:(NSNotification *)notification {
//  //  NSLog(@"text did Change");
//}

@end
