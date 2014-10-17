//
//  ViewController.m
//  socket
//
//  Created by Kermit Mei on 10/10/14.
//  Copyright (c) 2014 Kermit Mei. All rights reserved.
//

#import "ViewController.h"
#import "sockcomm.h"
#import "socket_c.h"
#include "SocketClient.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
CFSocketRef _socket = NULL;
@interface ViewController (){
    
}


@property (nonatomic) int socketfd;
@property (nonatomic) int listenSocketFd;

@property (strong, nonatomic) IBOutlet UITextField *serverIp;

@property (strong, nonatomic) IBOutlet UITextField *serverPort;


@property (strong, nonatomic) IBOutlet UITextField *sendMsg;

@property (strong, nonatomic) IBOutlet UITextView *logTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setUpForDismissKeyboard];
}

#pragma -mark dismiss keyboard
- (void)setUpForDismissKeyboard {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGR =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
    NSOperationQueue *mainQuene =[NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [self.view addGestureRecognizer:singleTapGR];
                }];
    [nc addObserverForName:UIKeyboardWillHideNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [self.view removeGestureRecognizer:singleTapGR];
                }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    //此method会将self.view里所有的subview的first responder都resign掉
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addLog:(NSString *)string
{
    if([_logTextView.text isEqual:@""]){
        _logTextView.text = string;
    }else{
        [_logTextView setText:[NSString stringWithFormat:@"%@\n%@", _logTextView.text, string]];
    }
    CGPoint p = [_logTextView contentOffset];
    [_logTextView setContentOffset:p animated:NO];
    [_logTextView scrollRangeToVisible:NSMakeRange([_logTextView.text length], 0)];

}

- (IBAction)socketHandle:(UIButton *)sender {
    switch (sender.tag) {
        case 101:
        {
            const char *ip   = [[_serverIp text] cStringUsingEncoding:NSASCIIStringEncoding];
            const char *port = [[_serverPort text] cStringUsingEncoding:NSASCIIStringEncoding];
            //_socketfd = connectHost(ip, port, 10);

            [self addLog:@"开始连接"];
            _socketfd = SocketConnect(ip, port, "tcp", 10);
            if(_socketfd >= 0 ){
                NSLog(@"连接成功 %d", _socketfd);
                [self addLog:[NSString stringWithFormat:@"连接成功 %d", _socketfd]];
            }else{
                [self addLog:[NSString stringWithFormat:@"连接失败 %d", _socketfd]];
            }
        }
            break;
        case 102:
            if(_socketfd >= 0){
                DisSocketConnect(_socketfd);
                [self addLog:@"断开连接"];
            }
            break;
        case 103:
        {
            NSString *msg = _sendMsg.text;
            NSString *sendStr = @"001001020304050607080900";
            NSData *sendData = [self twoOneData:sendStr];
            char * pMsg = "\x00\x0A\x01\x02\x03\x04\x05\x06\x07\x08\x09\x00";//[sendData bytes];//(char *)[msg cStringUsingEncoding:NSUTF8StringEncoding];
            int ret = SocketWrite(_socketfd, "\x00\x0A\x01\x02\x03\x04\x05\x06\x07\x08\x09\x00", 12, 10);
            if(ret >= 0){
                [self addLog:[NSString stringWithFormat:@"发送数据 %d", ret]];
            }else{
                [self addLog:[NSString stringWithFormat:@"发送失败 %d", ret]];
            }
        }
            break;
        case 104:
        {
            char readBuf[100];
            memset(readBuf, 0, sizeof(readBuf));
            int ret = SocketReadLength(_socketfd, readBuf, 2, 10);
            NSString *retStr;
            if(ret > 0){
                NSString *readStr = [NSString stringWithCString:readBuf length:2];
                NSData * readData = [self twoOneData:readStr];
                char *tmp = [readData bytes];
                int length = readBuf[0] * 256 + readBuf[1];
                retStr = [NSString stringWithCString:readBuf length:ret];
                [self addLog:[NSString stringWithFormat:@"读数据 %d,%@", ret, retStr]];
                int ret = SocketReadLength(_socketfd, readBuf, length, 10);
                retStr = [NSString stringWithCString:readBuf length:ret];
                retStr = [self oneTwoData:[NSData dataWithBytes:readBuf length:length]];
                [self addLog:[NSString stringWithFormat:@"读数据 %d,%@", ret, retStr]];
            }else{
                [self addLog:[NSString stringWithFormat:@"读数据失败 %d", ret]];
            }
        }
            break;
        case 105:
        {
            [_logTextView setText:@""];
            //int listenSocketFd = SocketListen("9000", "tcp", 10);
            //if(listenSocketFd > 0){
            //        [self addLog:@"监听成功"];
            //}
        }
            break;
        case 106:
        {
            char ip[20];
            int ret = SocketAccept(_listenSocketFd, ip);
            [self addLog:[NSString stringWithFormat:@"连接 IP : %d, %s", ret, ip]];
            ret = SocketWrite(ret, "1234145415145", 13, 10);
            [self addLog:[NSString stringWithFormat:@"发送 : %d", ret]];
        }
        default:
            break;
    }
    
}


int connectServer(const char *ip, const char *port, int timeOut)
{
    _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack, NULL, NULL);
    
    if (_socket != nil) {
        struct sockaddr_in addr4;   // IPV4
        memset(&addr4, 0, sizeof(addr4));
        addr4.sin_len         = sizeof(addr4);
        addr4.sin_family      = AF_INET;
        addr4.sin_port        = htons(atoi(port));
        addr4.sin_addr.s_addr = inet_addr(ip);// 把字符串的地址转换为机器可识别的网络地址
        
        // 把sockaddr_in结构体中的地址转换为Data
        CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr4, sizeof(addr4));
        CFSocketError sock_error = CFSocketConnectToAddress(_socket, address, 10);
        if(sock_error == kCFSocketSuccess){
            return 0;
        }else if(sock_error == kCFSocketTimeout){
            return -1;
        }else if(sock_error == kCFSocketError){
            return -2;
        }else{
            return -3;
        }
    }
    return -4;
}

int sendData(const char *data, int timeOut){
    if(CFSocketGetNative(_socket)){
        
    }
    NSLog(@"count = %d", CFSocketGetNative(_socket));
    
    int ret = (int)send(CFSocketGetNative(_socket), data, strlen(data), 0);
    printf("ret = %d\n", ret);
    return ret;
}

int recvData(char *buff, int readLength, int timeOut){
    int ret = (int)recv(CFSocketGetNative(_socket), buff, readLength, timeOut);
    printf("ret = %d\n", ret);
    return ret;
}

-(NSString *)oneTwoData:(NSData *)sourceData
{
    Byte *inBytes = (Byte *)[sourceData bytes];
    NSMutableString *resultData = [[NSMutableString alloc] init];
    
    for(NSInteger counter = 0; counter < [sourceData length]; counter++)
        [resultData appendFormat:@"%02X",inBytes[counter]];
    
    return resultData;
}

-(NSData *)twoOneData:(NSString *)sourceString
{
    Byte tmp, result;
    Byte *sourceBytes = (Byte *)[sourceString UTF8String];
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    
    for(NSInteger i=0; i<strlen((char*)sourceBytes); i+=2) {
        tmp = sourceBytes[i];
        if(tmp > '9')
            tmp = toupper(tmp) - 'A' + 0x0a;
        else
            tmp &= 0x0f;
        
        result = tmp <<= 4;
        
        tmp = sourceBytes[i+1];
        if(tmp > '9')
            tmp = toupper(tmp) - 'A' + 0x0a;
        else
            tmp &= 0x0f;
        result += tmp;
        [resultData appendBytes:&result length:1];
    }
    
    return resultData;
}

@end
