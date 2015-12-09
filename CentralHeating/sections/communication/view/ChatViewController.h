//
//  ChatViewController.h
//  CentralHeating
//
//  Created by ghg on 15/12/3.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import "ChatModelData.h"
#import "NSUserDefaults+ChatSettings.h"
#import "ChatManager.h"

@class ChatViewController;

@protocol ChatViewControllerDelegate <NSObject>

- (void)didDismissChatViewController:(ChatViewController *)vc;

@end




@interface ChatViewController : JSQMessagesViewController <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate,ChatDelegate>

@property (weak, nonatomic) id<ChatViewControllerDelegate> delegateModal;

@property (strong, nonatomic) ChatModelData *chatData;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;

@end