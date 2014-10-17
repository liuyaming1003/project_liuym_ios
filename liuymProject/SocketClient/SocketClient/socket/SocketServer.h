//
//  SocketServer.h
//  SocketClient
//
//  Created by Kermit Mei on 10/14/14.
//  Copyright (c) 2014 Liuym. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketServer : NSObject

- (int)listen:(int)port;

/**
 *    连接服务端
 *
 *    @param ip      连接IP
 *    @param port    连接端口号
 *    @param timeOut 超时时间,秒
 *
 *    @return ＝ 0 成功, < 0 参考错误码
 */
- (int)connect:(NSString *)ip port:(int )port timeOut:(int )timeOut;

/**
 *    断开连接
 *
 *    @return ＝ 0 成功, < 0 参考错误码
 */
- (int)close;

/**
 *    发送数据
 *
 *    @param data 发送数据
 *
 *    @return ＝ 0 成功, < 0 参考错误码
 */
- (int)sendData:(NSData *)data;

/**
 *    接受数据
 *
 *    @param expectedLength 接收长度数据
 *    @param tiemOut        超时时间,秒
 *
 *    @return 成功返回数据，失败返回nil
 */
- (NSData *)receiveData:(int)expectedLength timeOut:(int )timeOut;

/**
 *    接口返回值
 *
 *    @return ＝ 0 成功, < 0 参考错误码
 */
- (int)getLastRet;

@end
