//
//  DetailViewController.h
//  CentralHeating
//
//  Created by ghg on 15/12/2.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@end
