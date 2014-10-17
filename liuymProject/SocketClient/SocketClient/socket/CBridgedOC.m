//
//  CBridgedOC.m
//  SocketClient
//
//  Created by Kermit Mei on 10/14/14.
//  Copyright (c) 2014 Liuym. All rights reserved.
//

#import "CBridgedOC.h"

#import <Foundation/Foundation.h>
#import "SocketClient.h"

static SocketClient *client = nil;

@interface CBridgedOC : NSObject


@end

@implementation CBridgedOC

+ (SocketClient *)getClient
{
    if(client == nil){
        client = [[SocketClient alloc] init];
    }
    return client;
}

int client_connect_lym(const char *ip, int port, int timeOut)
{
    return [[CBridgedOC getClient] connect:[NSString stringWithCString:ip encoding:NSUTF8StringEncoding] port:port timeOut:timeOut];
}

int client_write_lym(const char *sendBuff)
{
    return [[CBridgedOC getClient] sendData:[@"41412341234" dataUsingEncoding:NSUTF8StringEncoding]];
}

int client_read_lym(char *recvBuff, int readLength, int timeOut)
{
    NSData *data = [[CBridgedOC getClient] receiveData:readLength timeOut:timeOut];
    if(data){
        const char *buff = [data bytes];
        memcpy(recvBuff, buff, data.length);
        return (int)data.length;
    }
    return [[CBridgedOC getClient] getLastRet];
}

int client_close_lym()
{
    return [[CBridgedOC getClient] close];
}

@end


