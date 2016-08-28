//
//  ipcomm_link.cpp
//  wsjtx
//
//  Created by Joe Mastroianni on 8/27/13.
//  A native Obj-C implementation of wsjtx  developed for Joe Taylor and John Nelson
//  for no reason other than the fun of it
//  source copied liberally from wsjtx C++ QT version
//  any copyright is owned by Joe Taylor and John Nelson  and the wsjtx developer community et. al.
//
//





#include "ipcomm_link.h"
#import "ipcommMac.h"



ipcomm_link::ipcomm_link()
{
    wrapped = [[ipcommMac alloc] init];
    
}

ipcomm_link::~ipcomm_link(){
}

bool    ipcomm_link::create(){
    return [(ipcommMac*)wrapped create];
}

bool ipcomm_link::attach(void){
    mem_jt9 = [(ipcommMac*)wrapped attach];
    if(mem_jt9 == NULL){
        return FALSE;
    }
    return TRUE;
    
}
bool ipcomm_link::detach(void){
    return [(ipcommMac*)wrapped detach];
    
}
void* ipcomm_link::address(void){
    return mem_jt9;
    
}
int ipcomm_link::size(void){
    return [(ipcommMac*)wrapped size];
    
}
bool ipcomm_link::setMyKey(char* mykey, int mykey_len){
    return [(ipcommMac*)wrapped setMyKey :mykey :mykey_len];
    
}




