//
//  ChatManager.m
//  CentralHeating
//
//  Created by ghg on 15/12/8.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import "ChatManager.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

typedef NS_ENUM(NSInteger, EVENT_TYPE)
{
    ET_LOGIN,    //登录
    ET_REGISTER   //注册
};

@interface ChatManager() {
    EVENT_TYPE eventType;
    NSString *password;
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
}
@end

@implementation ChatManager
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

SYNTHESIZE_SINGLETON_FOR_CLASS(ChatManager)

-(instancetype)init{
    if ([super init]){
        xmppStream = [[XMPPStream alloc] init];
        xmppStream.hostName = XMPP_SERVER_HOST_NAME;
        xmppStream.hostPort = XMPP_SERVER_PORT;
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

#pragma mark Core Data
- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

#pragma mark Private
- (void)setupStream:(NSString *)hostName :(UInt16)port
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    [xmppStream setHostName:hostName];
    [xmppStream setHostPort:port];
    
    
    // You may need to alter these settings depending on the server you're connecting to
    customCertEvaluation = YES;
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
}

#pragma mark XMPPStream Delegate
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
    if (customCertEvaluation)
    {
        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
    }
}

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}


#pragma mark XMPPRosterDelegate


- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
}


#pragma mark connnet
-(BOOL)tstconnect{
    
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_current_queue()];
    //从本地取得用户名，密码和服务器地址
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userId = @"user@imac.local";
    NSString *pass = @"admin";
    NSString *server = @"127.0.0.1";
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    if (userId == nil || pass == nil) {
        return NO;
    }
    
    //设置用户
    [xmppStream setMyJID:[XMPPJID jidWithString:userId]];
    //设置服务器
    [xmppStream setHostName:server];
    //密码
    password = pass;
    
    //连接服务器
    NSError *error = nil;
    [xmppStream connectWithTimeout:XMPP_CONNECT_TIMEOUT error:&error];
    if (nil != error) {
        NSLog(@"error = %@",error);
    }
    
    return YES;
    
}

-(void)connect{
    if ([xmppStream isConnected]) {
        NSLog(@"have been connect to server, ignore it");
        return;
    }
    NSError *error = nil;
    [xmppStream connectWithTimeout:XMPP_CONNECT_TIMEOUT error:&error];
    if (nil != error) {
        NSLog(@"error = %@",error);
    }
    
    xmppStream = [[XMPPStream alloc] init];
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"connect server failed");
}

-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"connect to server success");
    switch (eventType) {
        case ET_REGISTER:
        {
            [sender registerWithPassword:password error:nil];
            break;
        }
        case ET_LOGIN:
        {
            NSError *error = nil;
            [sender authenticateWithPassword:password error:&error];
            break;
        }
        default:;
    }
}

- (void)xmppStreamWillConnect:(XMPPStream *)sender
{

}

#pragma mark register
-(void)registerWithName:(NSString *)userName andPassword:(NSString *)pwd{
    eventType = ET_REGISTER;
    password = pwd;
    xmppStream.myJID = [XMPPJID jidWithUser:userName domain:XMPP_SERVER_DOMAIN resource:XMPP_SERVER_RESOURCE];
    [self connect];
}

-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"register success");
    
}

-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"register failed");
}

#pragma mark login
-(void)loginwithName:(NSString *)userName andPassword:(NSString *)pwd
{
    eventType = ET_LOGIN;
    password = pwd;
    xmppStream.myJID = [XMPPJID jidWithUser:userName domain:XMPP_SERVER_DOMAIN resource:XMPP_SERVER_RESOURCE];
    [self connect];
    
    //有可能成功或者失败，所以有相对应的代理方法
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"authenticate password success");
    [self setPresence:PT_ONLINE];
}

-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"authenticate password failed,%@",error);
}

#pragma mark logout
-(void)logout{
    NSLog(@"logout");
    [self setPresence:PT_OFFLINE];
    [xmppStream disconnect];
}

#pragma mark presence
- (void)setPresence:(PRESENCE_TYPE)type {
    NSArray *presences = @[@"available", @"away", @"do not disturb", @"unavailable"];
    [xmppStream sendElement:[XMPPPresence presenceWithType:presences[type]]];
}

//好友状态改变
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSString *presenceType = [presence type];
    NSString *presenceFromUser = [[presence from] user];
    if (![presenceFromUser isEqualToString:[[sender myJID] user]]) {
        if ([presenceType isEqualToString:@"available"]) {
            NSLog(@"%@ have login", presenceFromUser);
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            NSLog(@"%@ have logout", presenceFromUser);
        } else if ([presenceType isEqualToString:@"away"]) {
            NSLog(@"%@ have been away", presenceFromUser);
        } else if ([presenceType isEqualToString:@"do not disturb"]) {
            NSLog(@"%@ have been busy", presenceFromUser);
        }
    }
}

#pragma mark message
- (void)sendMessage:(NSString *) text toUser:(NSString *) user {
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:text];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    NSString *to = [NSString stringWithFormat:@"%@@example.com", user];
    [message addAttributeWithName:@"to" stringValue:to];
    [message addChild:body];
    [xmppStream sendElement:message];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody])
    {
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                                 xmppStream:xmppStream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        
        NSString *text = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [user displayName];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            NSString *text = [[message elementForName:@"body"] stringValue];
            NSLog(@"receive message from %@: %@", displayName, text);
        }
        else
        {
            // We are not active, so use a local notification instead
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName, text];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }
}


@end
