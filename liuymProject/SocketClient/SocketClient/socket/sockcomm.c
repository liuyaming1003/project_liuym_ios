//
//  sockcomm.c
//  SocketClient
//
//  Created by Kermit Mei on 10/14/14.
//  Copyright (c) 2014 Liuym. All rights reserved.
//

#include "sockcomm.h"
#include "CBridgedOC.h"

int client_connect(const char *ip, int port, int timeOut)
{
    return client_connect_lym(ip, port, timeOut);
}

int client_write(const char *sendBuff)
{
    return client_write_lym(sendBuff);
}

int client_read(char *recvBuff, int readLength, int timeOut)
{
    return client_read_lym(recvBuff, readLength, timeOut);
}

int client_close()
{
    return client_close_lym();
}
