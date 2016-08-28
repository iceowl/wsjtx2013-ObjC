//
//  waterfallWinDelegate.h
//  wsjtx
//
//  Created by Joe Mastroianni on 10/12/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#import <Foundation/Foundation.h>
#import "wideGraph.h"
#import "graphLegend.h"
#import "externSettings.h"

@interface waterfallWinDelegate : NSObject <NSWindowDelegate> {
    
}

@property           IBOutlet wideGraph   *theWaterfall;
@property (retain)  IBOutlet NSWindow    *window;
@property           IBOutlet graphLegend *gLegend;

- (void)closeButtonClicked;


@end
