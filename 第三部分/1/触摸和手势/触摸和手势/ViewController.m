//
//  ViewController.m
//  触摸和手势
//
//  Created by Kermit Mei on 10/9/14.
//  Copyright (c) 2014 Kermit Mei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UILabel *point_label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    //触摸开始
    NSLog(@"触摸开始");
    NSUInteger count = touches.count;
    if(count == 1){
        NSSet *allTouches    = [event allTouches];//返回与当前接收者有关的所有的触摸对象
        UITouch *touch       = [allTouches anyObject];//视图中的所有对象
        CGPoint point        = [touch locationInView:[touch view]];//返回触摸点在视图中的当前坐标
        int x                = point.x;
        int y                = point.y;
        NSString *point_text = [NSString stringWithFormat:@"触摸开始(%d,%d)", x, y];
        [_point_label setText:point_text];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    //触摸移动
    NSLog(@"触摸移动");
    NSInteger count = touches.count;
    if(count == 1){
        NSSet *allTouches    = [event allTouches];//返回与当前接收者有关的所有的触摸对象
        UITouch *touch       = [allTouches anyObject];//视图中的所有对象
        CGPoint point        = [touch locationInView:[touch view]];//返回触摸点在视图中的当前坐标
        int x                = point.x;
        int y                = point.y;
        NSString *point_text = [NSString stringWithFormat:@"触摸移动(%d,%d)", x, y];
        [_point_label setText:point_text];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    //触摸结束
    NSLog(@"触摸结束");
    NSInteger count = touches.count;
    if(count == 1){
        NSSet *allTouches    = [event allTouches];//返回与当前接收者有关的所有的触摸对象
        UITouch *touch       = [allTouches anyObject];//视图中的所有对象
        CGPoint point        = [touch locationInView:[touch view]];//返回触摸点在视图中的当前坐标
        int x                = point.x;
        int y                = point.y;
        NSString *point_text = [NSString stringWithFormat:@"触摸结束(%d,%d)", x, y];
        [_point_label setText:point_text];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    //触摸取消
    NSLog(@"触摸取消");
    NSInteger count = touches.count;
    if(count == 1){
        NSSet *allTouches    = [event allTouches];//返回与当前接收者有关的所有的触摸对象
        UITouch *touch       = [allTouches anyObject];//视图中的所有对象
        CGPoint point        = [touch locationInView:[touch view]];//返回触摸点在视图中的当前坐标
        int x                = point.x;
        int y                = point.y;
        NSString *point_text = [NSString stringWithFormat:@"触摸取消(%d,%d)", x, y];
        [_point_label setText:point_text];
    }
}

@end
