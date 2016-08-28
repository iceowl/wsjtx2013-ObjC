//
//  jt9.m
//  wsjtx
//
//  Created by Joe Mastroianni on 9/3/13.
//  Copyright (c) 2013 Joe Mastroianni. All rights reserved.
//

#import "jt9.h"
#include "common.h"


@implementation jt9

-(id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
    
}

-(void)decoder (void ) {
    
    
    /*
     subroutine decoder(ss,id2)
     
     // Decoder for JT9.
     
     include 'constants.f90'
     this is jt9com_.ss real ss(184,NSMAX)
     
     */
    
    NSString *dFile = @"decoded.txt";
    NSString *kFile = @"kvasd.dat";
    
    char msg [22]; //character*22 msg
    char datetime [20]; // character*20 datetime
    float ccfred[NSMAX]; // real*4 ccfred(NSMAX)
    float red2[NSMAX]; // real*4 red2(NSMAX)
    bool ccfok[NSMAX];// logical ccfok(NSMAX)
    bool done[NSMAX]; // logical done(NSMAX)
    bool done65 = false;     // logical done65
    // this is jtcom_d2 integer*2 id2(NTMAX*12000)
    float dd[NTMAX*1200];// real*4 dd(NTMAX*12000)
    unsigned char i1SoftSymbols[207];
    
    int nfreqs0=0;
    int nfreqs1=0;
    int ndecodes0=0;
    int ndecodes1=0;
    int npts65=52*12000;
    int ntol65=20;
    // this is all _jt9com_
    //
    // integer*1 i1SoftSymbols(207)
    // common/npar/nutc,ndiskdat,ntrperiod,nfqso,newdat,npts8,nfa,nfb,ntol,  &
    // kin,nzhsym,nsave,nagain,ndepth,ntxmode,nmode,datetime
    // common/tracer/limtrace,lu
    // save
    
    
    FILE* decodedFile = fopen([dFile cStringUsingEncoding:NSASCIIStringEncoding],"r+");
    FILE* kvasdFile   = fopen([kFile cStringUsingEncoding:NSASCIIStringEncoding],"r");
    NSDate *iclock0 = [[NSDate alloc] initWithTimeIntervalSince1970:NSTimeIntervalSince1970];
    // call system_clock(iclock0,iclock_rate,iclock_max)           //###
    
    
    //open(13,file='decoded.txt',status='unknown')
    //open(22,file='kvasd.dat',access='direct',recl=1024,status='unknown')
    
    
    /*
     if((nmode >=65) && (ntxmode == 65)){
     if(newdat//=0) {
     
     memcpy(&dd,&jt9com_,npts65); //dd(1:npts65)=id2(1:npts65)
     [self jt65a] ;// call jt65a(dd,npts65,newdat,nutc,nfa,nfqso,ntol65,nagain,ndecoded)
     done65=.true.
     }
     
     if(nmode //= 65) {
     
     nsynced=0
     ndecoded=0
     nsps=0
     
     nsps=6912                                   //Params for JT9-1
     df3=1500.0/2048.0
     
     tstep=0.5*nsps/12000.0                      //Half-symbol step (seconds)
     done=.false.
     
     nf0=0
     ia=max(1,nint((nfa-nf0)/df3))
     ib=min(NSMAX,nint((nfb-nf0)/df3))
     lag1=-(2.5/tstep + 0.9999)
     lag2=5.0/tstep + 0.9999
     if(newdat.ne.0) then
     call timer('sync9   ',0)
     call sync9(ss,nzhsym,lag1,lag2,ia,ib,ccfred,red2,ipk)
     call timer('sync9   ',1)
     }
     
     jt9com_.nsps8/=8;  //nsps8=nsps/8
     df8=1500.0/nsps8
     dblim=db(864.0/nsps8) - 26.2
     
     do nqd=1,0,-1
     limit=1000
     ccflim=4.0
     red2lim=1.6
     schklim=2.2
     if(ndepth.eq.2) then
     limit=10000
     ccflim=3.5
     endif
     if(ndepth.ge.3 .or. nqd.eq.1) then
     limit=100000
     ccflim=2.5
     endif
     ccfok=.false.
     
     if(nqd.eq.1) then
     nfa1=nfqso-ntol
     nfb1=nfqso+ntol
     ia=max(1,nint((nfa1-nf0)/df3))
     ib=min(NSMAX,nint((nfb1-nf0)/df3))
     ccfok(ia:ib)=(ccfred(ia:ib).gt.(ccflim-2.0)) .and.               &
     (red2(ia:ib).gt.(red2lim-1.0))
     ia1=ia
     ib1=ib
     else
     nfa1=nfa
     nfb1=nfb
     ia=max(1,nint((nfa1-nf0)/df3))
     ib=min(NSMAX,nint((nfb1-nf0)/df3))
     do i=ia,ib
     ccfok(i)=ccfred(i).gt.ccflim .and. red2(i).gt.red2lim
     enddo
     ccfok(ia1:ib1)=.false.
     endif
     
     fgood=0.
     do i=ia,ib
     if(done(i) .or. (.not.ccfok(i))) cycle
     f=(i-1)*df3
     if(nqd.eq.1 .or.                                                   &
     (ccfred(i).ge.ccflim .and. abs(f-fgood).gt.10.0*df8)) then
     
     if(nqd.eq.0) nfreqs0=nfreqs0+1
     if(nqd.eq.1) nfreqs1=nfreqs1+1
     
     call timer('softsym ',0)
     fpk=nf0 + df3*(i-1)
     
     call softsym(id2,npts8,nsps8,newdat,fpk,syncpk,snrdb,xdt,    &
     freq,drift,schk,i1SoftSymbols)
     call timer('softsym ',1)
     
     //           write(71,3001) nqd,i,f,fpk,ccfred(i),red2(i),schk
     //3001       format(2i6,2f8.1,3f6.1)
     //           call flush(71)
     
     if(schk.lt.schklim) cycle
     
     call timer('decode9 ',0)
     call decode9(i1SoftSymbols,limit,nlim,msg)
     call timer('decode9 ',1)
     
     sync=(syncpk+1)/4.0
     if(sync.lt.0.0 .or. snrdb.lt.dblim-2.0) sync=0.0
     nsync=sync
     if(nsync.gt.10) nsync=10
     nsnr=nint(snrdb)
     ndrift=nint(drift/df3)
     
     if(msg.ne.'                      ') then
     if(nqd.eq.0) ndecodes0=ndecodes0+1
     if(nqd.eq.1) ndecodes1=ndecodes1+1
     
     write(*,1000) nutc,nsnr,xdt,nint(freq),msg
     1000          format(i4.4,i4,f5.1,i5,1x,'@',1x,a22)
     write(13,1002) nutc,nsync,nsnr,xdt,freq,ndrift,msg
     1002          format(i4.4,i4,i5,f6.1,f8.0,i4,3x,a22,' JT9')
     
     iaa=max(1,i-1)
     ibb=min(NSMAX,i+22)
     fgood=f
     nsynced=1
     ndecoded=1
     ccfok(iaa:ibb)=.false.
     done(iaa:ibb)=.true.
     call flush(6)
     endif
     endif
     enddo
     call flush(6)
     if(nagain.ne.0) exit
     enddo
     
     if(nmode.ge.65 .and. (.not.done65)) then
     if(newdat.ne.0) dd(1:npts65)=id2(1:npts65)
     call jt65a(dd,npts65,newdat,nutc,nfa,nfqso,ntol65,nagain,ndecoded)
     endif
     
     //### JT65 is not yet producing info for nsynced, ndecoded.
     800 write(*,1010) nsynced,ndecoded,nutc,nmode
     1010 format('<DecodeFinished>',4i4)
     call flush(6)
     close(13)
     close(22)
     
     return
     end subroutine decoder
     
     */
}

-(void)jt65a {
    
    /*
     subroutine jt65a(dd,npts,newdat,nutc,nfa,nfqso,ntol,nagain,ndecoded)
     
     //  Process dd() data to find and decode JT65 signals.
     
     parameter (NSZ=3413)
     parameter (NZMAX=60*12000)
     parameter (NFFT=8192)
     real dd(NZMAX)
     real*4 ss(322,NSZ)
     real*4 savg(NSZ)
     logical done(NSZ)
     real a(5)
     character decoded*22
     save
     
     if(newdat.ne.0) then
     call timer('symsp65 ',0)
     call symspec65(dd,npts,ss,nhsym,savg)    //Get normalized symbol spectra
     call timer('symsp65 ',1)
     endif
     
     df=12000.0/NFFT                     //df = 12000.0/16384 = 0.732 Hz
     ftol=16.0                           //Frequency tolerance (Hz)
     mode65=1                            //Decoding JT65A only, for now.
     done=.false.
     freq0=-999.
     
     do nqd=1,0,-1
     if(nqd.eq.1) then                //Quick decode, at fQSO
     fa=nfqso - ntol
     fb=nfqso + ntol
     else                             //Wideband decode at all freqs
     fa=200
     fb=nfa
     endif
     ia=max(51,nint(fa/df))
     ib=min(NSZ-51,nint(fb/df))
     
     thresh0=1.5
     
     do i=ia,ib                               //Search over freq range
     freq=i*df
     if(savg(i).lt.thresh0 .or. done(i)) cycle
     
     call timer('ccf65   ',0)
     call ccf65(ss(1,i),nhsym,savg(i),sync1,dt,flipk,syncshort,snr2,dt2)
     call timer('ccf65   ',1)
     
     ftest=abs(freq-freq0)
     thresh1=1.0
     if(nqd.eq.1 .and. ntol.le.100) thresh1=0.
     if(sync1.lt.thresh1 .or. ftest.lt.ftol) cycle
     
     nflip=nint(flipk)
     call timer('decod65a',0)
     call decode65a(dd,npts,newdat,freq,nflip,mode65,sync2,a,dt,   &
     nbmkv,nhist,decoded)
     call timer('decod65a',1)
     
     ftest=abs(freq+a(1)-freq0)
     if(ftest.lt.ftol) cycle
     
     if(decoded.ne.'                      ') then
     ndecoded=1
     nfreq=nint(freq+a(1))
     ndrift=nint(2.0*a(2))
     s2db=10.0*log10(sync2) - 32             //### empirical (was 40) ###
     nsnr=nint(s2db)
     if(nsnr.lt.-30) nsnr=-30
     if(nsnr.gt.-1) nsnr=-1
     write(*,1010) nutc,nsnr,dt,nfreq,decoded
     1010       format(i4.4,i4,f5.1,i5,1x,'#',1x,a22)
     write(13,1012) nutc,nint(sync1),nsnr,dt,float(nfreq),ndrift,  &
     decoded,nbmkv
     1012       format(i4.4,i4,i5,f6.1,f8.0,i4,3x,a22,' JT65',i4)
     freq0=freq+a(1)
     i2=min(NSZ,i+15)                //### ??? ###
     done(i:i2)=.true.
     endif
     enddo
     if(nagain.eq.1) exit
     enddo
     
     return
     end subroutine jt65a
     
     */
    
}

-(void)timer : (char*)dname : (int)k {
    //subroutine timer(dname,k)
    
    //Times procedure number n between a call with k=0 (tstart) and with
    // k=1 (tstop). Accumulates sums of these times in array ut (user time).
    // Also traces all calls (for debugging purposes) if limtrace.gt.0
    NSDate *time;
    char name[8][50];
    char space[8] = {' ',' ',' ',' ',' ',' ',' ',' '};
    char ename[8]; //character*8 dname,name(50),space,ename
    char sname[16]; //character*16 sname
    bool on[50];   //logical on(50)
    float ut[50], ut0[50], dut[50]; //real ut(50),ut0(50),dut(50)
    int ncall[50], nlevel[50], nparent[50]; //integer ncall(50),nlevel(50),nparent(50)
    int onlevel[11]; //integer onlevel(0:10)
    
    // common/tracer/ limtrace,lu
    float eps = 0.000001;
    int ntrace = 0; //data eps/0.000001/,ntrace/0/
    int level = 0;
    int nmax = 0;
    // data level/0/,nmax/0/,space/'        '/
    trace.limtrace = 0;
    trace.lu = -1;     //data limtrace/0/,lu/-1/
    
    //save
     time = [[NSDate alloc] initWithTimeIntervalSince1970:NSTimeIntervalSince1970];
     //  this never happens - we just set limtrace to 0 if(limtrace.lt.0) go to 999
     if(trace.lu < 1) {trace.lu=6;}  //if(lu.lt.1) lu=6
    if(k>1){
        [self writeOutTimerStatistics];
    }//if(k.gt.1) go to 40                        //Check for "all done" (k>1)
   
    onlevel[0]=0;
     
//for (int i=1;i<nmax;i++) {// do n=1,nmax                                //Check for existing name
//       if(name(i) == dname) {  //if(name(n).eq.dname) go to 20
//       ;
//      } //enddo
//     }
    
      
     nmax=nmax+1;                              //This is a new one
     int n=nmax;
     ncall[n]=0;
     on[n]=FALSE;
     ut[n]=eps;
     strncpy(&name[n],dname,50);
    
    if(k==0) {                               //Get start times (k=0)
        if(on[n]){
            NSLog(@"Error in timer: %s already on.",dname);
        }
     level=level+1;                                //Increment the level
        on[n]=TRUE;
       
     //call system_clock(icount,irate)
     ut0[n]=(float) [time timeIntervalSince1970];  //  /irate
        ncall[n]=ncall[n]+1;
        if((ncall[n]>1) && (nlevel[n] !=level)) {
            nlevel[n]=-1;
        } else {
            nlevel[n]=level;
        }
     
        nparent[n]=onlevel[level-1];
        onlevel[level]=n;
     
    } else if(k ==1) {        //Get stop times and accumulate sums. (k=1)
        if(on[n]) {
            on[n]=FALSE;
     //call system_clock(icount,irate)
            float ut1=(float)[time timeIntervalSince1970];//(icount)/irate
            ut[n] = ut[n]+ut1-ut0[n];
        }
        level=level-1;
    }
    
     ntrace=ntrace+1;
    if(ntrace < trace.limtrace) {
        NSLog(@"trace=%d  dname=%s   k=%d  level=%d  parent[n]=%d",ntrace,dname,k,level,nparent[n]);
    }//ntrace,dname,k,level,nparent(n)
    // 1020 format(i8,': ',a8,3i5)
    // go to 998
     
     // Write out the timer statistics
     
 
     
     //998 flush(lu)
     
    // 999 return
    // end subroutine timer

return; 
}


-(void)writeTimerStatistics{
    /*
   // 40 write(lu,1040)
   // 1040 format(/'     name                 time  frac     dtime',       &
                ' dfrac  calls level parent'/73('-'))
    printf("  name)
    if(k.gt.100) then
        ndiv=k-100
        do i=1,nmax
            ncall(i)=ncall(i)/ndiv
            ut(i)=ut(i)/ndiv
            enddo
            endif
            
            total=ut(1)
            sum=0.
            sumf=0.
            do i=1,nmax
                dut(i)=ut(i)
                do j=i,nmax
                    if(nparent(j).eq.i) dut(i)=dut(i)-ut(j)
                        enddo
                        utf=ut(i)/total
                        dutf=dut(i)/total
                        sum=sum+dut(i)
                        sumf=sumf+dutf
                        kk=nlevel(i)
                        sname=space(1:kk)//name(i)//space(1:8-kk)
                        ename=space
                        if(i.ge.2) ename=name(nparent(i))
                            write(lu,1060) float(i),sname,ut(i),utf,dut(i),dutf,           &
                            ncall(i),nlevel(i),ename
                            1060 format(f4.0,a16,2(f10.2,f6.2),i7,i5,2x,a8)
                            enddo
                            
                            write(lu,1070) sum,sumf
                            1070 format(/36x,f10.2,f6.2)
                            nmax=0
                            eps=0.000001
                            ntrace=0
                            level=0
                            space='        '
                            onlevel(0)=0
    */
}

@end
