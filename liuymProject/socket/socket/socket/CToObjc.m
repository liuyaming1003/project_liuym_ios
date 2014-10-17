//
//  CToObjc.m
//  socket
//
//  Created by Kermit Mei on 10/13/14.
//  Copyright (c) 2014 Kermit Mei. All rights reserved.
//

#import "CToObjc.h"



#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface CToObjc : NSObject<GCDAsyncSocketDelegate>

- (void)connect:(NSString *)ip port:(NSString *)port timeOut:(int) timeOut;

@property (nonatomic, strong) GCDAsyncSocket *gcdAsyncSocket;

@end
@implementation CToObjc

- (id)init
{
    self = [super init];
    if(self){
        _gcdAsyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)connect:(NSString *)ip port:(NSString *)port timeOut:(int) timeOut
{
    NSError *error = nil;
    BOOL flag = [_gcdAsyncSocket connectToHost:@"192.168.2.116" onPort:9000  error:&error];
    if(flag == NO){
        NSLog(@"error");
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"host = %@,%d", host, port);
    [_gcdAsyncSocket writeData:[@"ceshi" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:10 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"err = %@", err);
}

int LYMConnect(const char *ip, const char *port, int timeOut)
{
    [[[CToObjc alloc] init] connect:[NSString stringWithCString:ip encoding:NSUTF8StringEncoding] port:[NSString stringWithCString:port encoding:NSUTF8StringEncoding] timeOut:timeOut];
    return -1;
}

@end


