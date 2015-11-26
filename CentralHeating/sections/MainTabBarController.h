//
//  MainTabBarController.h
//  CentralHeating
//
//  Created by ghg on 15/11/26.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICETutorialController.h"

@interface MainTabBarController : UITabBarController<ICETutorialControllerDelegate>
@property (strong, nonatomic) ICETutorialController *viewController;
@end
