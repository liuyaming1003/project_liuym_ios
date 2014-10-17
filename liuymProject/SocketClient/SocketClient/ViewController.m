//
//  ViewController.m
//  SocketClient
//
//  Created by Kermit Mei on 10/14/14.
//  Copyright (c) 2014 Liuym. All rights reserved.
//

#import "ViewController.h"
#import "SocketClient.h"
#import "SocketServer.h"
#import "sockcomm.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *connectIp;
@property (strong, nonatomic) IBOutlet UITextField *connectPort;

@property (strong, nonatomic) SocketClient *client;
@property (strong, nonatomic) SocketServer *server;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _client = [[SocketClient alloc] init];
    
    _server = [[SocketServer alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connectHost:(NSThread *)thread
{
    NSString *ip = [_connectIp text];
    int port = [[_connectPort text] intValue];
    int ret = client_connect([ip cStringUsingEncoding:NSUTF8StringEncoding], port, 5);
    NSLog(@"ret = %d", ret);
}


- (IBAction)socketTest:(UIButton *)sender {
    if(sender.tag == 101){
        NSString *ip = [_connectIp text];
        int port = [[_connectPort text] intValue];
       // NSThread* myThread = [[NSThread alloc] initWithTarget:self selector:@selector(connectHost:) object:nil];
       // [myThread start];
       // return;
        int ret = client_connect([ip cStringUsingEncoding:NSUTF8StringEncoding], port, 5);//[_client connect:ip port:port timeOut:3];
        /*if(ret == 0){
            char buff[512];
            memset(buff, 0, sizeof(buff));
            int ret = client_read(buff, 2, 2);
            if(ret == 2){
                NSString *read = [NSString stringWithCString:buff length:2];
                NSLog(@"data length = %@", read);
                int length = buff[0] * 256 + buff[1];
                ret = client_read(buff, length, 10);
                if(ret == length){
                    NSString *readStr = [NSString stringWithCString:buff length:length];
                    NSLog(@"read buff = %@", readStr);
                }else{
                    NSLog(@"buff ret = %d", ret);
                }
            }else{
                NSLog(@"length ret = %d", ret);
            }
           // client_close();
        }*/
        NSLog(@"ret = %d", ret);
    }else if(sender.tag == 102){
        int ret = client_write([@"1233123132" cStringUsingEncoding:NSUTF8StringEncoding]);
        //int ret = [_client sendData:[@"1231414" dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"ret = %d", ret);
    }else if(sender.tag == 103){
        //NSData *data = [_client receiveData:10 timeOut:3];
        char buff[30];
        int ret = client_read(buff, 10, 10);
        if(ret > 0){
            NSLog(@"read data = %d,%@", ret, [NSString stringWithCString:buff encoding:NSUTF8StringEncoding]);
        }
        NSLog(@"ret = %d", ret);
        //NSLog(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }else if(sender.tag == 104){
        //int ret = [_client close];
        int ret = client_close();
        NSLog(@"ret = %d", ret);
    }else if(sender.tag == 105){
        int ret = [_server listen:9000];
        NSLog(@"ret = %d", ret);
    }
}
@end
