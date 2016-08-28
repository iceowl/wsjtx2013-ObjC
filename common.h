//
//  common.h
//  wsjtx
//
//  Created by Joe Mastroianni on 8/30/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#ifndef wsjtx_common_h
#define wsjtx_common_h


//#define NSMAX 1365
#define NSMAX 6827 //Max length of saved spectra
#define NTMAX 120
#define NMAX NTMAX*12000       //Total sample intervals per 30 minutes
#define NDMAX NTMAX*1500    //Sample intervals at 1500 Hz rate
#define MAXFFT3  16384
#define NSZ 3413
#define NZMAX 60*12000
#define NFFT 8192 


extern struct jt9Common {
        
        Float32 ss[184*NSMAX];              //This is "common/jt9com/..." in fortran
        Float32 savg[NSMAX];
        int16_t d2[NTMAX*12000];
        int32_t nutc;                         //UTC as integer, HHMM
        int32_t ndiskdat;                     //1 ==> data read from *.wav file
        int32_t ntrperiod;                    //TR period (seconds)
        int32_t nfqso;                        //User-selected QSO freq (kHz)
        int32_t newdat;                       //1 ==> new data, must do long FFT
        int32_t nfa;                          //Low decode limit (Hz)
        int32_t nfb;                          //High decode limit (Hz)
        int32_t ntol;                         //+/- decoding range around fQSO (Hz)
        int32_t kin;
        int32_t nzhsym;
        int32_t npts8;                        //npts for c0() array
        int32_t nsave;
        int32_t nagain;
        int32_t ndepth;
        int32_t ntxmode;
        int32_t nmode;
    
        char datetime[20]; }jt9com_;




#endif
