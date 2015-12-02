//
//  DetailViewController.m
//  CentralHeating
//
//  Created by ghg on 15/12/2.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.mainTableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    } else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailTableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = @"blablabla";
    cell.imageView.image = [UIImage imageNamed:@"RMB"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//    [self.navigationController pushViewController:controller animated:YES];
}
@end
