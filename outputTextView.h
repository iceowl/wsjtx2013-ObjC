//
//  outputTextView.h
//  wsjtx
//
//  Created by Joe Mastroianni on 10/5/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import <Foundation/Foundation.h>
#import "qsoManager.h"

@interface outputTextView : NSObject <NSTextViewDelegate> {
    
    IBOutlet qsoManager  *qManager;
    
}

@property (retain)  qsoManager  *qManager;

- (void)textView:(NSTextView *)aTextView clickedOnCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex;
//-(void) textDidChange:(NSNotification *)notification;
//-(void) textViewDidChangeSelection:(NSNotification *)notification;

@end
