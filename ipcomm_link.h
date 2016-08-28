//
//  ipcomm_link.h
//  wsjtx
//
//  Created by Joe Mastroianni on 8/27/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#ifndef __wsjtx__ipcomm_link__
#define __wsjtx__ipcomm_link__

#include <iostream>
#include <objc/objc-runtime.h>

    class ipcomm_link{
    
        
    public:
        ipcomm_link(void);
        ~ipcomm_link(void);
        void  init(void);
        bool  create(void);
        bool  attach(void);
        bool  detach(void);
        void* address(void);
        int   size(void);
        // Multiple instances:  wrapper for QSharedMemory::setKey()
        bool  setMyKey(char* mykey, int mykey_len);
     private:
        ipcomm_link* _impl;
        id          wrapped;
        void*       mem_jt9;
    

        
        
    };
#endif /* defined(__wsjtx__ipcomm_link__) */
