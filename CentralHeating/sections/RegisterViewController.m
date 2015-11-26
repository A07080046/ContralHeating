//
//  RegisterViewController.m
//  CentralHeating
//
//  Created by ghg on 15/11/26.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = true;
}

- (IBAction)clickCommit {
    [self.navigationController pushViewController: [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"] animated:YES];
}
@end
