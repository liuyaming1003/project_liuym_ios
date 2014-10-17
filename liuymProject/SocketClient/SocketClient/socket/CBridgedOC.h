//
//  CBridgedOC.h
//  SocketClient
//
//  Created by Kermit Mei on 10/14/14.
//  Copyright (c) 2014 Liuym. All rights reserved.
//

#ifndef __CBridgedOC__
#define __CBridgedOC__

#include <stdio.h>

int client_connect_lym(const char *ip, int port, int timeOut);

int client_write_lym(const char *sendBuff);

int client_read_lym(char *recvBuff, int readLength, int timeOut);

int client_close_lym();

#endif
