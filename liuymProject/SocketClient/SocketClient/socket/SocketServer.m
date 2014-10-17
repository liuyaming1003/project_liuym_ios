//
//  SocketServer.m
//  SocketClient
//
//  Created by Kermit Mei on 10/14/14.
//  Copyright (c) 2014 Liuym. All rights reserved.
//

#import "SocketServer.h"
#import "AsyncSocket.h"

@interface SocketServer()<AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket *server;
@end

@implementation SocketServer

- (id)init
{
    self = [super init];
    if(self){
        _server = [[AsyncSocket alloc] initWithDelegate:self];
    }
    return self;
}

- (int)listen:(int)port
{
    NSError *error = nil;
    
    //未知
    [_server disconnect];

    BOOL flag = [_server acceptOnPort:port error:&error];
    if(!flag){
        return -1;
    }
    return 0;
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
    NSLog(@"onSocketWillConnect");
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"获取连接");
    dispatch_async(dispatch_get_main_queue(), ^{
        [newSocket writeData:[@"09987654321" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:3 tag:1];
        [newSocket disconnectAfterWriting];
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新UI
        });
    });
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"error = %@", err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"onSocketDidDisconnect");
}

@end
