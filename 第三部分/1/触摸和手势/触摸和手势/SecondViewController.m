//
//  SecondViewController.m
//  触摸和手势
//
//  Created by Kermit Mei on 10/9/14.
//  Copyright (c) 2014 Kermit Mei. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *text_label;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //单击
    UITapGestureRecognizer *singleTap       = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired          = 1;
    [self.view addGestureRecognizer:singleTap];

    //双击
    UITapGestureRecognizer *doubleTap       = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired          = 2;
    [self.view addGestureRecognizer:doubleTap];

    //当双击失败再触发单击
    [singleTap requireGestureRecognizerToFail:doubleTap];

    //旋转
    UIRotationGestureRecognizer *rotation   = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotation:)];
    [self.view addGestureRecognizer:rotation];

    //移动
    UIPanGestureRecognizer *pan             = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];

    //捏合
    UIPinchGestureRecognizer *pinch         = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.view addGestureRecognizer:pinch];

    //滑动
    UISwipeGestureRecognizer *swipeLeft     = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeLeft.numberOfTouchesRequired       = 1;
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];

    UISwipeGestureRecognizer *swipeRight    = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeRight.numberOfTouchesRequired      = 1;
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];

    UISwipeGestureRecognizer *swipeUp       = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeUp.numberOfTouchesRequired         = 1;
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeUp];

    UISwipeGestureRecognizer *swipeDown     = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeDown.numberOfTouchesRequired       = 1;
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];

    //pan手势和swipe手势冲突
    [pan requireGestureRecognizerToFail:swipeLeft];
    [pan requireGestureRecognizerToFail:swipeRight];
    [pan requireGestureRecognizerToFail:swipeUp];
    [pan requireGestureRecognizerToFail:swipeDown];

    //长按
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longPress];
    
    
    
}

- (void)singleTap:(UITapGestureRecognizer*) tap
{
    CGPoint point = [tap locationInView:self.view];
    [self showGesture:tap message:@"单击" point:point];
}

- (void)doubleTap:(UITapGestureRecognizer*) tap
{
    CGPoint point = [tap locationInView:self.view];
    [self showGesture:tap message:@"双击" point:point];
}

- (void)pinch:(UIPinchGestureRecognizer *)pinch
{
    self.text_label.alpha = 1.0;
    if(pinch.scale > 1.0){
        _text_label.text = @"放大";
    }else if(pinch.scale < 1.0){
        _text_label.text = @"缩小";
    }
    CGPoint point          = [pinch locationInView:self.view];
    self.text_label.center = point;
    pinch.view.transform   = CGAffineTransformScale(pinch.view.transform, pinch.scale, pinch.scale);
    
    NSLog(@"scan           = %f, velocity = %f", pinch.scale, pinch.velocity);
    pinch.scale            = 1;
}

- (void)swipe:(UISwipeGestureRecognizer *)swipe
{
    CGPoint point = [swipe locationInView:self.view];
    NSString *message = nil;
    switch (swipe.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            message = @"向左";
            break;
        case UISwipeGestureRecognizerDirectionRight:
            message = @"向右";
            break;
        case UISwipeGestureRecognizerDirectionUp:
            message = @"向上";
            break;
        case UISwipeGestureRecognizerDirectionDown:
            message = @"向下";
            break;
        default:
            break;
    }
    [self showGesture:swipe message:message point:point];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress
{
    CGPoint point = [longPress locationInView:self.view];
    [self showGesture:longPress message:@"长按" point:point];
}

- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self.view];
    [self showGesture:pan message:@"移动" point:point];
}

- (void)rotation:(UIRotationGestureRecognizer *)rotation
{
    self.text_label.alpha = 1.0;
    CGPoint point               = [rotation locationInView:self.view];

    CGAffineTransform transform = CGAffineTransformMakeRotation([rotation rotation]);
    self.text_label.transform   = transform;
    self.text_label.text        = @"旋转";
    self.text_label.center      = point;
    
    if (([rotation state] == UIGestureRecognizerStateEnded) || ([rotation state] == UIGestureRecognizerStateCancelled)) {
        [UIView animateWithDuration:0.5 animations:^{
            self.text_label.alpha = 0.0;
            self.text_label.transform = CGAffineTransformIdentity;
        }];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showGesture:(id)sender message:(NSString *)message point:(CGPoint)point
{
    //self.text_label.text = [NSString stringWithFormat:@"%@ :(%d,%d)", message, (int)point.x, (int)point.y];
    self.text_label.text = message;
    self.text_label.center = point;
    self.text_label.alpha = 1.0;
    NSLog(@"frame = %@, point(%f,%f)", NSStringFromCGRect(_text_label.frame), point.x, point.y);
    [UIView animateWithDuration:0.5 animations:^{
        self.text_label.alpha = 0.0;
        if([message  isEqual: @"向上"]){
            CGPoint new_point = CGPointMake(point.x, point.y - 200.0);
            self.text_label.center = new_point;
        }else if([message  isEqual: @"向下"]){
            CGPoint new_point = CGPointMake(point.x, point.y + 200.0);
            self.text_label.center = new_point;
        }else if([message  isEqual: @"向左"]){
            CGPoint new_point = CGPointMake(point.x - 200.0, point.y );
            self.text_label.center = new_point;
        }else if([message  isEqual: @"向右"]){
            CGPoint new_point = CGPointMake(point.x + 200.0, point.y );
            self.text_label.center = new_point;
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
