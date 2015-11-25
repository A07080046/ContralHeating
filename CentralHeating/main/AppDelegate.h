//
//  AppDelegate.h
//  CentralHeating
//
//  Created by ghg on 15/11/25.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICETutorialController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,ICETutorialControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ICETutorialController *viewController;

@end

