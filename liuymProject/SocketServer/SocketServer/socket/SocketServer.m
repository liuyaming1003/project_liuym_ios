//
//  SocketServer.m
//  SocketClient
//
//  Created by Kermit Mei on 10/14/14.
//  Copyright (c) 2014 Liuym. All rights reserved.
//

#import "SocketServer.h"
#import "AsyncSocket.h"

#define SOCKET_OK     0
#define SOCKET_ERROR_ALREADYLISTEN -1
#define SOCKET_ERROR_LISTEN        -2
#define SOCKET_ERROR_DISCONNECT    -3

@interface SocketServer()<AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket *server;
@property (nonatomic, strong) NSMutableArray *accpetSocket;

@property (nonatomic) BOOL isListen;
@end

@implementation SocketServer

- (id)init
{
    self = [super init];
    if(self){
        _server       = [[AsyncSocket alloc] initWithDelegate:self];
        _accpetSocket = [[NSMutableArray alloc] initWithCapacity:1];
        _isListen     = NO;
    }
    return self;
}

- (int)listen:(int)port
{
    NSError *error = nil;

    if(_isListen){
        return SOCKET_ERROR_ALREADYLISTEN;
    }
    BOOL flag = [_server acceptOnPort:port error:&error];
    if(!flag){
        return SOCKET_ERROR_LISTEN;
    }
    _isListen = YES;
    return SOCKET_OK;
}

- (void)disListen
{
    for(int i = 0; i < _accpetSocket.count; i++){
        [[_accpetSocket objectAtIndex:i] disconnect];
    }
    
    [_accpetSocket removeAllObjects];
    
    if(_isListen){
        [_server disconnect];
        _isListen = NO;
    }
}

- (void)disConnect:(AsyncSocket *)socket
{
    if(socket.isConnected){
        [socket disconnect];
    }
}

- (int)connectCount
{
    return (int)_accpetSocket.count;
}

- (int)sendData:(AsyncSocket *)socket data:(NSData *)data tag:(long)tag
{
    if(socket.isConnected){
        NSData *one = [NSData dataWithBytes:data.bytes length:data.length/2];
        NSData *two = [NSData dataWithBytes:data.bytes + data.length/2 length:data.length - data.length/2];
        [socket writeData:one withTimeout:-1 tag:tag];
         NSDate *startTime = [NSDate date];
        while (YES) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
            NSTimeInterval interval = [[NSDate date]timeIntervalSinceDate:startTime];
            if (interval  > 5) {
                break;
            }
            NSLog(@"等待操作");
            usleep(1000 * 1000);
        }
        [socket writeData:two withTimeout:-1 tag:2];
    }else{
        return SOCKET_ERROR_DISCONNECT;
    }
    return SOCKET_OK;
}

- (int)receiveData:(AsyncSocket *)socket length:(int)expectedLength timeOut:(int )timeOut tag:(long) tag
{
    if(socket.isConnected){
        [socket readDataToLength:expectedLength withTimeout:timeOut tag:tag];
    }else{
        return SOCKET_ERROR_DISCONNECT;
    }
    
    
    
    return SOCKET_OK;
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
    NSLog(@"onSocketWillConnect");
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"获取连接");
    [_accpetSocket addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    if([self.delegate respondsToSelector:@selector(acceptConnect:)]){
        [self.delegate acceptConnect:sock];
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if([self.delegate respondsToSelector:@selector(readData:data:tag:)]){
        [self.delegate readData:sock data:data tag:tag];
    }
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if([self.delegate respondsToSelector:@selector(writeData:tag:)]){
        [self.delegate writeData:sock tag:tag];
    }
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"error12 = %@", err);
    NSString *errorStr = @"";
    switch (err.code) {
        case AsyncSocketCanceledError:
            errorStr = @"AsyncSocketCanceledError";
            break;
        case AsyncSocketCFSocketError:
            errorStr = @"AsyncSocketCFSocketError";
            break;
        case AsyncSocketReadTimeoutError:
            errorStr = @"AsyncSocketReadTimeoutError";
            break;
        case AsyncSocketWriteTimeoutError:
            errorStr = @"AsyncSocketWriteTimeoutError";
            break;
        case AsyncSocketReadMaxedOutError:
            errorStr = @"AsyncSocketReadMaxedOutError";
            break;
        case AsyncSocketNoError:
            errorStr = @"断开连接";
            break;
        default:
            errorStr = [NSString stringWithFormat:@"未知错误 %ld", (long)err.code];
            break;
    }
    if([self.delegate respondsToSelector:@selector(fail:error:)]){
        [self.delegate fail:sock error:errorStr];
    }
    [_accpetSocket removeObject:sock];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    //[_accpetSocket removeObject:sock];
    NSLog(@"onSocketDidDisconnect");
}

@end
