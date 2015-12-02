//
//  MainTabBarController.m
//  CentralHeating
//
//  Created by ghg on 15/11/26.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import "MainTabBarController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.tintColor = [UIColor redColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (int i=0; i<self.tabBar.items.count; i++) {
        UITabBarItem *item = self.tabBar.items[i];
        if (i == 0) {
            item.title = @"通讯";
        } else if (i == 1) {
            item.title = @"关系";
        } else if (i == 2) {
            item.title = @"生活";
        } else if (i == 3) {
            item.title = @"发现";
        }
        item.image = [UIImage imageNamed:@"winer"];
        item.selectedImage = [UIImage imageNamed:@"vip"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
