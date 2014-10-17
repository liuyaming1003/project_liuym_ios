//
//  SocketClient.c
//  socket
//
//  Created by Kermit Mei on 10/13/14.
//  Copyright (c) 2014 Kermit Mei. All rights reserved.
//

#include "SocketClient.h"
#include "CToObjc.h"

int connectHost(const char *ip, const char *port, int timeOut)
{
    return LYMConnect(ip, port, timeOut);
}
