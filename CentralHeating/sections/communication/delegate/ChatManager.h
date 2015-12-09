//
//  ChatManager.h
//  CentralHeating
//
//  Created by ghg on 15/12/8.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

#import "XMPPReconnect.h"

#import "XMPPRoster.h"
#import "XMPPRosterCoreDataStorage.h"

#import "XMPPvCardTempModule.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "XMPPCapabilities.h"
#import "XMPPCapabilitiesCoreDataStorage.h"

#import "XMPPMUC.h"
#import "XMPPRoomCoreDataStorage.h"

#import "Common.h"

#define XMPP_CONNECT_TIMEOUT 30.0f //s
#define XMPP_SERVER_DOMAIN @"ghg"
#define XMPP_SERVER_RESOURCE @"iPhone8"
#define XMPP_SERVER_HOST_NAME @"127.0.0.1"
#define XMPP_SERVER_PORT 5222

typedef NS_ENUM(NSInteger, PRESENCE_TYPE)
{
    PT_ONLINE = 0, //available 上线
    PT_AWAY, //away  离开
    PT_BUSY, //do not disturb 忙碌
    PT_OFFLINE //unavailable 离线
};

@protocol ChatDelegate <NSObject>
@optional
- (void)receiveMsgDE:(NSString *)info;
@end

@interface ChatManager : NSObject<XMPPStreamDelegate, XMPPRosterDelegate> {
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

DECLARE_SINGLETON_FOR_CLASS(ChatManager)
@property (nonatomic, assign)id<ChatDelegate>delegate;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

-(BOOL)tstconnect;
- (void)sendMessage:(NSString *) text toUser:(NSString *) user;
-(void)registerWithName:(NSString *)userName andPassword:(NSString *)password;
-(void)loginwithName:(NSString *)userName andPassword:(NSString *)password;
-(void)logout;

@end
