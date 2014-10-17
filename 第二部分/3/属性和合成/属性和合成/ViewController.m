//
//  ViewController.m
//  属性和合成
//
//  Created by Kermit Mei on 10/8/14.
//  Copyright (c) 2014 Kermit Mei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UILabel *text_label;

@property (strong, nonatomic) NSString *text;

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

- (IBAction)buttonPress:(id)sender {
    static int pressCount = 0;
    
    self.text = [NSString stringWithFormat:@"按下: %d 次", ++pressCount];
    
    [_text_label setText:self.text];
}
@end
