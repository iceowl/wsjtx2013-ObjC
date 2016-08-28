//
//  settings.h
//  wsjtx
//
//  Created by Joe Mastroianni on 9/22/13.
//  Copyright (c) 2013 Joe Mastroianni. All rights reserved.
//

#ifndef wsjtx_settings_h
#define wsjtx_settings_h





 double  m_fftBinWidth;
 double  m_slope;

 int m_nsps;
 int m_plotGain;
 int m_inGain;
 int m_binsPerPixel;
 int m_plotZero;

 int m_nsps;

 int m_TRperiod;
 int m_rxFreq;
 int m_txFreq;

 int m_ntr0;
 int m_ntr;
 int m_npts8;

 int m_waterfallAvg;

 int m_ntx;
 int m_rxFreq;
 int m_txFreq;

 int m_ndepth;

 int m_hsym;


 int m_hsymStop;
 int m_len1;
 int m_inGain;
 int m_nsave;
 int m_catPortIndex;
 int m_rig;
 int m_rigIndex;
 int m_serialRate;
 int m_serialRateIndex;
 int m_dataBits;
 int m_dataBitsIndex;
 int m_stopBits;
 int m_stopBitsIndex;
 int m_handshakeIndex;
 int m_ncw;
 int m_secID;
 int m_band;
 int m_repeatMsg;
 int m_watchdogLimit;
 int m_poll;
 int m_fMin;
 int m_fMax;
 int m_bad;
 int m_mode;
 int m_modeTx;
 int m_bandwidth;


 bool    m_Running;
 bool    m_paint;
 bool    m_dataFromDisk;
 bool    m_bCurrent;
 bool    m_bCumulative;
 bool    m_lockTxFreq;
 bool    m_needUTC;
 bool    m_dataSinkBusy;
 bool    m_monitoring;
 bool    m_transmitting;
 bool    m_diskData;
 bool    m_loopall;
 bool    m_decoderBusy;
 bool    m_txFirst;
 bool    m_auto;
 bool    m_restart;
 bool    m_startAnother;
 bool    m_saveDecoded;
 bool    m_saveAll;
 bool    m_widebandDecode;
 bool    m_call3Modified;
 bool    m_dataAvailable;
 bool    m_killAll;
 bool    m_bdecoded;
 bool    m_monitorStartOFF;
 bool    m_pskReporter;
 bool    m_pskReporterInit;
 bool    m_noSuffix;
 bool    m_toRTTY;
 bool    m_dBtoComments;
 bool    m_catEnabled;
 bool    m_After73;
 bool    m_promptToLog;
 bool    m_blankLine;
 bool    m_insertBlank;
 bool    m_clearCallGrid;
 bool    m_bMiles;
 bool    m_decodedText2;
 bool    m_freeText;
 bool    m_quickCall;
 bool    m_73TxDisable;
 bool    m_sent73;
 bool    m_runaway;
 bool    m_tune;
 bool    m_bRigOpen;
 bool    m_bMultipleOK;
 bool    m_bDTR;
 bool    m_bRTS;
 bool    m_pttData;
 bool    m_dontReadFreq;
 bool    m_lockTxFreq;
 bool    m_test;
 bool    m_PTTData;
 bool    m_saveComments;
 bool    m_tx2QSO;
 bool    m_CATerror;
 bool    m_bSplit;
 bool    m_bXIT;
 bool    m_plus2kHz;
 bool    m_qsoInProgress;
 bool    m_waterfallRunning;

 char    m_decoded[80];



 NSString* m_path;

 NSString* m_myCall;
 NSString* m_myGrid;
 NSString* m_baseCall;
 NSString* m_hisCall;
 NSString* m_hisGrid;
 NSString* m_appDir;
 NSString* m_saveDir;
 NSString* m_dxccPfx;
 NSString* m_palette;
 NSString* m_dateTime;
 NSString* m_fname;
 NSString* m_rpt;
 NSString* m_rptSent;
 NSString* m_rptRcvd;
 NSString* m_qsoStart;
 NSString* m_qsoStop;
 NSString* m_catPort;
 NSString* m_handshake;
 NSString* m_cmnd;
 NSString* m_msgSent0;
 NSString* m_fileToSave;
 NSString* m_QSOmsg;
 NSString* m_txPower;
 NSString* m_logComments;


#endif
