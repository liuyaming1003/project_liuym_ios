//
//  ViewController.m
//  SocketServer
//
//  Created by Kermit Mei on 10/14/14.
//  Copyright (c) 2014 Liuym. All rights reserved.
//

#import "ViewController.h"
#import "SocketServer.h"

@interface ViewController ()<SocketServerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *port;

@property (strong, nonatomic) SocketServer *server;

@property (strong, nonatomic) IBOutlet UITextView *logView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _server = [[SocketServer alloc] init];
    _server.delegate = self;
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
    if([_logView.text isEqualToString:@""]){
        _logView.text = string;
    }else{
        [_logView setText:[NSString stringWithFormat:@"%@\n%@", _logView.text, string]];
    }
    NSLog(@"%@", string);
    CGPoint p = [_logView contentOffset];
    [_logView setContentOffset:p animated:NO];
    [_logView scrollRangeToVisible:NSMakeRange([_logView.text length], 0)];
   // [_logView scrollRectToVisible:CGRectMake(0, _logView.contentSize.height, _logView.contentSize.width, 1) animated:YES];
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

- (IBAction)listen:(id)sender {
    int ret = [_server listen:[[_port text] intValue]];
    if(ret == 0){
        [self addLog:@"开始等待连接"];
    }else if(ret == -1){
        [self addLog:@"已经开始监听"];
    }else{
        [self addLog:@"监听失败"];
    }
    
}
- (IBAction)disListen:(id)sender {
    [_server disListen];
    [self addLog:@"停止监听"];
}
- (IBAction)claerLog:(id)sender {
    _logView.text = @"";
}
- (IBAction)connectCount:(id)sender {
    [self addLog:[NSString stringWithFormat:@"连接数: %d", [_server connectCount]]];
}

- (void)acceptConnect:(AsyncSocket *)socket
{
    [self addLog:[NSString stringWithFormat:@"收到连接 ip:%@", socket.connectedHost]];
    int ret = [_server receiveData:socket length:2 timeOut:-1 tag:1];
    if(ret == 0){
        [self addLog:@"开始读数据..."];
    }else{
        [self addLog:@"已经断开连接"];
    }
}

- (NSString *)sendStr
{
    NSMutableString *str = [[NSMutableString alloc] init];
    for(int i = 0; i < 256; i++){
        [str appendFormat:@"%02X", i];
    }
    
    for(int i = 0; i < 255; i++){
        [str appendFormat:@"%02X", 255 - i];
    }
    NSString *retStr = [NSString stringWithFormat:@"%02X%02x%@",  (int)str.length/512, (int)str.length%512/2, str];
    return retStr;
}

- (void)readData:(AsyncSocket *)socket data:(NSData *)data tag:(long)tag
{
    if(tag == 1){
        const char *tmp = [data bytes];
        int length = tmp[0] * 256 + tmp[1];
        
        [self addLog:[NSString stringWithFormat:@"收到数据tag %ld, 长度 %d, 数据 %@", tag, data.length, [self oneTwoData:data]]];

        int ret = [_server receiveData:socket length:length timeOut:-1 tag:2];
        if(ret == 0){
            [self addLog:@"等待收数据..."];
        }else{
            [self addLog:@"已经断开连接"];
        }
        
    }else if(tag == 2){
        [self addLog:[NSString stringWithFormat:@"收到数据tag %ld, 长度 %lu, 数据 %@", tag, (unsigned long)data.length, [self oneTwoData:data]]];
        NSString *sendStr = [self sendStr];
        
        NSData *sendData = [self twoOneData:sendStr];
        int ret = [_server sendData:socket data:sendData tag:1];
        if(ret == 0){
            [self addLog:[NSString stringWithFormat:@"开始发送数据%d, %@",ret, sendData]];
        }else{
            [self addLog:@"已经断开连接"];
        }
    }
}

- (void)writeData:(AsyncSocket *)socket tag:(long)tag
{
    NSLog(@"tag = %ld", tag);
    /*if(tag == 1){
        NSData *sendData = [self twoOneData:[self sendStr]];
        NSData *twoData = [NSData dataWithBytesNoCopy:sendData.bytes + sendData.length/2 length:sendData.length - sendData.length/2];
     //   int ret = [_server sendData:socket data:twoData tag:2];
      //  [self addLog:[NSString stringWithFormat:@"开始发送数据%d, %@",ret, twoData]];
    }else */
    if(tag == 2){
        [self addLog:@"发送完成"];
        int ret = 0;[_server receiveData:socket length:2 timeOut:-1 tag:1];
        if(ret == 0){
            [self addLog:@"等待收数据..."];
        }else{
            [self addLog:@"已经断开连接"];
        }
    }
    //[_server disConnect:socket];
}

- (void)fail:(AsyncSocket *)socket error:(NSString *)error
{
    if(socket.isConnected){
        [_server disConnect:socket];
    }
    [self addLog:[NSString stringWithFormat:@"结果: %@", error]];
    NSLog(@"error msg = %@", error);
}


@end
