//
//  jt9.h
//  wsjtx
//
//  Created by Joe Mastroianni on 9/3/13.
//  Copyright (c) 2013 Joe Mastroianni. All rights reserved.
//
//#define NSMAX 1365
#define NSMAX 6827 //Max length of saved spectra
#define NTMAX 120
#define NMAX NTMAX*12000       //Total sample intervals per 30 minutes
#define NDMAX NTMAX*1500    //Sample intervals at 1500 Hz rate
#define MAXFFT3 16384
#define NSZ 3413
#define NZMAX 60*12000
#define NFFT 8192


#import <Foundation/Foundation.h>
#import "common.h"



@interface jt9 : NSObject {
    
    struct jt9Common jt9com_;
    struct tracer trace;
    struct commHdr hdr;
}

-(void)decoder;
-(void)writeOutTimerStatistics;
-(void)timer: (char*)dname : (int)k;

@end
