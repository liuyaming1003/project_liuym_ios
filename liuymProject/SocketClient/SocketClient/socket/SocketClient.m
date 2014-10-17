//
//  SocketClient.m
//  SocketClient
//
//  Created by Kermit Mei on 10/14/14.
//  Copyright (c) 2014 Liuym. All rights reserved.
//

#import "SocketClient.h"

#import "AsyncSocket.h"

#define SOCKET_OK                     0 //socket 访问成功
#define SOCKET_ERROR_GENERIC          -1//
#define SOCKET_ERROR_TIMEOUT          -2//socket 超时
#define SOCKET_ERROR_UNKNOW_HOST      -3//socket 找不到服务
#define SOCKET_ERROR_UNCONNECTED      -4//socket 连接失败
#define SOCKET_ERROR_DISCONNECT       -5//socket 未连接或者已经断开连接
#define SOCKET_ERROR_ALREADYCONNECTED -6//socket 已经连接

@interface SocketClient()<AsyncSocketDelegate>

@property (nonatomic) int lastRet;

@property (atomic, strong) AsyncSocket *client;

@property (nonatomic, strong) NSData *recvData;

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSTimer *timer;
@property (atomic) BOOL isFinishSocket;


@end

@implementation SocketClient

- (id)init
{
    self = [super init];
    if(self){
        _client = [[AsyncSocket alloc] initWithDelegate:self];
    }
    return self;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    _isFinishSocket = YES;
    NSLog(@"connect success");
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    _isFinishSocket = YES;
    NSLog(@"error = %@", err);
    switch (err.code) {
        case 61:
            _lastRet = SOCKET_ERROR_UNKNOW_HOST;
            NSLog(@"无法连接");
            break;
        case AsyncSocketCFSocketError:
            NSLog(@"请求被拒绝");
            break;
        case AsyncSocketNoError:
            NSLog(@"AsyncSocketNoError");
            break;
        case AsyncSocketCanceledError:
            NSLog(@"AsyncSocketCanceledError");
            break;
        case AsyncSocketConnectTimeoutError:
            NSLog(@"连接超时");
            _lastRet = SOCKET_ERROR_TIMEOUT;
            break;
        case AsyncSocketReadMaxedOutError:
            NSLog(@"AsyncSocketReadMaxedOutError");
            break;
        case AsyncSocketReadTimeoutError:
            NSLog(@"读数据超时");
            _lastRet = SOCKET_ERROR_TIMEOUT;
            break;
        case AsyncSocketWriteTimeoutError:
            NSLog(@"写数据超时");
            _lastRet = SOCKET_ERROR_TIMEOUT;
            break;
        default:
            break;
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"didReadData");
    if(tag == 2 && data != nil){
        NSLog(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        _recvData = data;
        _isFinishSocket = YES;
    }
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"didWriteDataWithTag %lu", tag);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sockonsocket
{
    NSLog(@"onSocketDidDisconnect");
}

-(void)connectThread
{
    NSLog(@"connectThread");
    NSError *error = nil;
    [_client setDelegate:self];
    BOOL flag = [_client connectToHost:@"192.168.2.116" onPort:9000 withTimeout:3 error:&error];
    if(flag == NO){
        _isFinishSocket = YES;
        _lastRet = SOCKET_ERROR_UNCONNECTED;
    }else{
        
    }
    //等带异步函数返回
    NSDate *startTime = [NSDate date];
    while(true){
        NSLog(@"线程测试");
        //控制超时时间
        NSTimeInterval interval = [[NSDate date]timeIntervalSinceDate:startTime];
        if (interval > 6) {
            break;
        }
        usleep(100*1000);
    }
    
}
/**
 *    连接服务端
 *
 *    @param ip      连接IP
 *    @param port    连接端口号
 *    @param timeOut 超时时间,秒
 *
 *    @return ＝ 0 成功, < 0 参考错误码
 */
- (int)connect:(NSString *)ip port:(int )port timeOut:(int )timeOut
{
    
    
    _lastRet = SOCKET_OK;
    
    if(_client.isConnected == YES){
        _lastRet = SOCKET_ERROR_ALREADYCONNECTED;
    }else{
        [NSThread detachNewThreadSelector:@selector(connectThread) toTarget:self withObject:nil];
        
        _isFinishSocket = NO;
        
        //等带异步函数返回
        NSDate *startTime = [NSDate date];
        while ( YES) {
            
            NSLog(@"_isFinsih flag = %d", _isFinishSocket);
            if(_isFinishSocket){
                break;
            }
            
            NSLog(@"测试超时时间");
            //控制超时时间
            NSTimeInterval interval = [[NSDate date]timeIntervalSinceDate:startTime];
            if (interval > timeOut + 1) {
                break;
            }
            usleep(100*1000);
        }
    }
    
    return _lastRet;
}

- (void)timeOut
{
    _isFinishSocket = YES;
    if([_timer isValid]){
        [_timer invalidate];
    }
}

/**
 *    断开连接
 *
 *    @return ＝ 0 成功, < 0 参考错误码
 */
- (int)close
{
    if(_client.isConnected){
        [_client disconnect];
    }
    return 0;
}

/**
 *    发送数据
 *
 *    @param data 发送数据
 *
 *    @return ＝ 0 成功, < 0 参考错误码
 */
- (int)sendData:(NSData *)data
{
    _lastRet = SOCKET_OK;
    if(!_client.isConnected){
        _lastRet =  SOCKET_ERROR_DISCONNECT;
    }
    
    [_client writeData:data withTimeout:-1 tag:1];
    return _lastRet;
}

/**
 *    接受数据
 *
 *    @param expectedLength 接收长度数据
 *    @param tiemOut        超时时间,秒
 *
 *    @return 成功返回数据，失败返回nil
 */
- (NSData *)receiveData:(int)expectedLength timeOut:(int )timeOut
{
    _lastRet        = SOCKET_OK;
    _recvData       = nil;
    _isFinishSocket = NO;
    
    if(_client.isConnected){
        [_client readDataToLength:expectedLength withTimeout:-1 tag:2];
        _timer = [NSTimer scheduledTimerWithTimeInterval:timeOut + 1 target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
        while ( YES ) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
            if(_isFinishSocket){
                if([_timer isValid]){
                    [_timer invalidate];
                }
                break;
            }
            
            NSLog(@"测试超时时间");
            usleep(100 * 1000);
        }
    }else{
        _lastRet = SOCKET_ERROR_DISCONNECT;
    }
    
    if(_lastRet == SOCKET_OK){
        return _recvData;
    }
    return nil;
}

/**
 *    接口返回值
 *
 *    @return ＝ 0 成功, < 0 参考错误码
 */
- (int)getLastRet
{
    return _lastRet;
}

@end
