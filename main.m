//
//  main.m
//  wsjtx
//
//  Created by Joe Mastroianni on 8/22/13.
//  Copyright (c) 2013 Joe Mastroianni. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "globalSettings.h"

globalSettings *gSettings;

int main(int argc, char *argv[])
{
    gSettings = [[globalSettings alloc] init]; // initialize global vars
    return NSApplicationMain(argc, (const char **)argv);
}
