//
//  TableViewController.m
//  动画实现和效果
//
//  Created by Kermit Mei on 10/10/14.
//  Copyright (c) 2014 Kermit Mei. All rights reserved.
//

#import "TableViewController.h"
#import "CoreAnimationEffect.h"

@interface TableViewController ()

@property (nonatomic, strong) NSArray *table_array;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    _table_array = [NSArray arrayWithObjects:@"下卷", @"上卷", @"左翻", @"右翻", @"下出", @"上出", @"左出", @"右出", @"淡入", @"淡出", @"Push 上", @"Push 下", @"Push 左", @"Push 右", @"移除 上", @"移除 下", @"移除 左", @"移除 右", @"旋转", @"旋转 缩小", @"上翻转", @"下翻转", @"立方 右", @"立方 左", @"立方 上", @"立方 下", @"吸入", @"水波", @"相机开", @"相机关",nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _table_array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [_table_array objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"index = %ld", (long)indexPath.row);
    switch (indexPath.row) {
        case 0:
            [CoreAnimationEffect animationCurlDown:self.view];
            break;
        case 1:
            [CoreAnimationEffect animationCurlUp:self.view];
            break;
        case 2:
            [CoreAnimationEffect animationFlipFromLeft:self.view];
            break;
        case 3:
            [CoreAnimationEffect animationFlipFromRight:self.view];
            break;
        case 4:
            [CoreAnimationEffect animationRevealFromBottom:self.view];
            break;
        case 5:
            [CoreAnimationEffect animationRevealFromTop:self.view];
            break;
        case 6:
            [CoreAnimationEffect animationRevealFromLeft:self.view];
            break;
        case 7:
            [CoreAnimationEffect animationRevealFromRight:self.view];
            break;
        case 8:
            [CoreAnimationEffect animationEaseIn:self.view];
            break;
        case 9:
            [CoreAnimationEffect animationEaseOut:self.view];
            break;
        case 10:
            [CoreAnimationEffect animationPushUp:self.view];
            break;
        case 11:
            [CoreAnimationEffect animationPushDown:self.view];
            break;
        case 12:
            [CoreAnimationEffect animationPushLeft:self.view];
            break;
        case 13:
            [CoreAnimationEffect animationPushRight:self.view];
            break;
        case 14:
            [CoreAnimationEffect animationMoveUp:self.view duration:1.25f];
            break;
        case 15:
            [CoreAnimationEffect animationMoveDown:self.view duration:1.25f];
            break;
        case 16:
             [CoreAnimationEffect animationMoveLeft:self.view];
            break;
        case 17:
            [CoreAnimationEffect animationMoveRight:self.view];
            break;
        case 18:
            [CoreAnimationEffect animationRotateAndScaleEffects:self.view];
            break;
        case 19:
            [CoreAnimationEffect animationRotateAndScaleDownUp:self.view];
            break;
        // 以下动画为私有API
        case 20:
            [CoreAnimationEffect animationFlipFromTop:self.view];
            break;
        case 21:
            [CoreAnimationEffect animationFlipFromBottom:self.view];
            break;
        case 22:
            [CoreAnimationEffect animationCubeFromLeft:self.view];
            break;
        case 23:
            [CoreAnimationEffect animationCubeFromRight:self.view];
            break;
        case 24:
            [CoreAnimationEffect animationCubeFromTop:self.view];
            break;
        case 25:
            [CoreAnimationEffect animationCubeFromBottom:self.view];
            break;
        case 26:
            [CoreAnimationEffect animationSuckEffect:self.view];
            break;
        case 27:
            [CoreAnimationEffect animationRippleEffect:self.view];
            break;
        case 28:
            [CoreAnimationEffect animationCameraOpen:self.view];
            break;
        case 29:
            [CoreAnimationEffect animationCameraClose:self.view];
            break;
        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
