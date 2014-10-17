//
//  SocketServer.h
//  SocketClient
//
//  Created by Kermit Mei on 10/14/14.
//  Copyright (c) 2014 Liuym. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@protocol SocketServerDelegate <NSObject>

- (void)acceptConnect:(AsyncSocket *)socket;

- (void)fail:(AsyncSocket *)socket error:(NSString *)error;

- (void)readData:(AsyncSocket *)socket data:(NSData *)data tag:(long)tag;

- (void)writeData:(AsyncSocket *)socket tag:(long)tag;
@end

@interface SocketServer : NSObject

@property (nonatomic, weak) id<SocketServerDelegate> delegate;

- (int)listen:(int)port;

- (void)disListen;

- (void)disConnect:(AsyncSocket *)socket;

- (int)sendData:(AsyncSocket *)socket data:(NSData *)data tag:(long)tag;

- (int)receiveData:(AsyncSocket *)socket length:(int)expectedLength timeOut:(int )timeOut tag:(long) tag;

- (int)connectCount;


@end
