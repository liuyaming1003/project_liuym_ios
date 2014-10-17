//
//  sockcomm.h
//  SocketClient
//
//  Created by Kermit Mei on 10/14/14.
//  Copyright (c) 2014 Liuym. All rights reserved.
//

#ifndef __SocketClient__sockcomm__
#define __SocketClient__sockcomm__

#include <stdio.h>

int client_connect(const char *ip, int port, int timeOut);

int client_write(const char *sendBuff);

int client_read(char *recvBuff, int readLength, int timeOut);

int client_close();

#endif /* defined(__SocketClient__sockcomm__) */
