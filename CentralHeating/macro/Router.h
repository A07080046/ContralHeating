//
//  Router.h
//  CentralHeating
//
//  Created by ghg on 15/11/27.
//  Copyright © 2015年 ghg. All rights reserved.
//

#ifndef Router_h
#define Router_h

#import "WebAPI.h"

#define SERVER_URL @"http://127.0.0.1:8081/"
//#define SERVER_URL @"http://192.168.1.103:3000/"
//#define SERVER_URL @"http://222.54.3.36:50080/phone/"
#define SERVER_WEB_URL @"http://222.54.3.36:50080/web/"
#define SERVER_UPLOAD_URL @"http://222.54.3.36:50080/"

#define DES_KEY @"ABCDEFGH"

#define DEFAULT_GET_TIMEOUT     (60.0f)
#define DEFAULT_POST_TIMEOUT    (60.0f)
#define DEFAULT_UPLOAD_TIMEOUT   (100000000.0f)

//GET定义
#pragma mark -
#pragma mark GET宏定义
#define ORIGIN_GET(timeout, wait, url, info, success, failed) [[WebAPI sharedInstance] get:timeout :wait :self :url :info :success :failed]
//非等待模式
#define GET1(url, success, failed) ORIGIN_GET(DEFAULT_GET_TIMEOUT, NO, url, nil, success, failed)
#define GET(url, success) GET1(url, success, nil)
#define GET2(url) GET(url, nil)

//等待模式
#define WGET3(url, info, success, failed) ORIGIN_GET(DEFAULT_GET_TIMEOUT, YES, url, info, success, failed)
#define WGET2(url, info, success) WGET3(url, info, success, nil)
#define WGET1(url, success, failed) WGET3(url, nil, success, failed)
#define WGET(url, success) WGET1(url, success, nil)

//POST定义
#pragma mark -
#pragma mark POST宏定义
#define ORIGIN_POST(timeout, wait, url, info, param, success, failed) [[WebAPI sharedInstance] post:timeout :wait :self :DES_KEY :url :info :param :success :failed]

//非等待模式
#define POST1(url, param, success, failed) ORIGIN_POST(DEFAULT_POST_TIMEOUT, NO, url, nil, param, success, failed)
#define POST(url, param, success) POST1(url, param, success, nil)
#define POST2(url, param) POST(url, param, nil)

//等待模式
#define WPOST3(url, info, param, success, failed) ORIGIN_POST(DEFAULT_POST_TIMEOUT, YES, url, info, param, success, failed)
#define WPOST2(url, info, param, success) WPOST3(url, info, param, success, nil)
#define WPOST1(url, param, success, failed) WPOST3(url, nil, param, success, failed)
#define WPOST(url, param, success) WPOST1(url, param, success, nil)

//UPLOAD定义
#pragma mark -
#pragma mark UPLOAD宏定义
#define ORIGIN_UPLOAD(timeout, wait, url, info, param, path, fieldname, success, failed) [[WebAPI sharedInstance] upload:timeout :wait :self :DES_KEY :url :info :param :path :fieldname :success :failed]

//非等待模式
#define UPLOAD1(url, param, path, fieldname, success, failed) ORIGIN_UPLOAD(DEFAULT_UPLOAD_TIMEOUT, NO, url, nil, param, path, fieldname, success, failed)
#define UPLOAD(url, param, path, fieldname, success) UPLOAD1(url, param, path, fieldname, success, nil)
#define UPLOAD2(url, param, path, fieldname) UPLOAD(url, param, path, fieldname, nil)

//等待模式
#define WUPLOAD3(url, info, param, path, fieldname, success, failed) ORIGIN_UPLOAD(DEFAULT_UPLOAD_TIMEOUT, YES, url, info, param, path, fieldname, success, failed)
#define WUPLOAD2(url, info, param, path, fieldname, success) WUPLOAD3(url, info, param, path, fieldname, success, nil)
#define WUPLOAD1(url, param, path, fieldname, success, failed) WUPLOAD3(url, nil, param, path, fieldname, success, failed)
#define WUPLOAD(url, param, path, fieldname, success) WUPLOAD1(url, param, path, fieldname, success, nil)


#pragma mark - 访问失败返回宏定义
#define FAILURE_RETURN(data) \
do { \
if (!data[@"status"] || [data[@"status"] isEqualToString:@"failure" ]) { \
return; \
} \
} while (0)

#define FAILURE_TOAST_RETURN(data) \
do { \
if (!data[@"status"] || [data[@"status"] isEqualToString:@"failure" ]) { \
TOAST(N2S(data[@"msg"])); \
return; \
} \
} while (0)



#pragma mark -
#pragma mark 账号相关

#define ROUTE_TEST                          SERVER_URL "listUsers"
//账号相关
#define ROUTE_USER_LOGIN                    SERVER_URL "userManage/login"
#define ROUTE_USER_REGISTER                 SERVER_URL "verificationPhone"
#define ROUTE_GET_VERIFICATION_CODE         SERVER_URL "getVerificationCode"
#define ROUTE_FORGET_PASSWORD               SERVER_URL "forgetPassword"
#define ROUTE_MODIFY_PASSWORD               SERVER_URL "userManage/revisePwd"

//登录获取火星币
//获取登录状态
#define ROUTE_GET_LOGIN_STATUS              SERVER_URL "task/getLoginTask"
#define ROUTE_GET_LOGIN_REWARD              SERVER_URL "taskReward/firstLoginReward"

//任务
//登录获取火星币信息
#define ROUTE_GET_MARSCOIN_INFO             SERVER_URL "userManage/marsList"
//领取火星币接口
#define ROUTE_HAVE_GET_MARSCOIN             SERVER_URL "userManage/mars"
//完善个人资料
#define ROUTE_IMPROVE_PERSONAL_INFO         SERVER_URL "userManage/perfectUser"

//空间
#define ROUTE_GET_ZONE_LIST                 SERVER_URL "getZoneList"
#define ROUTE_DELETE_ZONE_ITEM              SERVER_URL "deleteZoneItem"
#define ROUTE_ISSUE_ZONE_ITEM               SERVER_URL "issueZoneItem"

#pragma mark - 设置界面
//邮件
#define ROUTE_GET_EMAIL_LIST                SERVER_URL "systemEmail/getEmailForUser"
#define ROUTE_DELETE_EMAIL_ITEM             SERVER_URL "systemEmail/deleteEmail"
#define ROUTE_SET_EMAIL_READ                SERVER_URL "systemEmail/checkEmail"

//收藏
#define ROUTE_GET_COLLECTION_LIST           SERVER_URL "videoRelevant/myCollection"
#define ROUTE_DELETE_COLLECTION_ITEM        SERVER_URL "videoRelevant/deleteCollection"

//反馈
#define ROUTE_FEEDBACK                      SERVER_URL "feedback/feedback"
//帮助
#define ROUTE_HELP                          SERVER_WEB_URL "helpAndAbout/help"
#define ROUTE_ABOUT                         SERVER_WEB_URL "helpAndAbout/about"
#define ROUTE_LAW                           SERVER_WEB_URL "helpAndAbout/law"


#pragma mark - 播放界面
//获取视频列表
#define ROUTE_GET_SEARCH_VIDEO_LIST         SERVER_URL "videoRelevant/searchVideo"
#define ROUTE_GET_RELEVANT_VIDEO_LIST       SERVER_URL "videoRelevant/tagConnVideo"
#define ROUTE_GET_HOT_VIDEO_LIST            SERVER_URL "videoRelevant/heatVideoList"
//视频点赞
#define ROUTE_VIDEO_ADDPRAISE               SERVER_URL "recordPraise/addPraise"
//获取视频播放奖励
#define ROUTE_VIDEO_REWARD                  SERVER_URL "taskReward/playVideoReward"
//视频收藏
#define ROUTE_VIDEO_ADDCOLLECTION           SERVER_URL "videoRelevant/addCollection"
//拉取话题
#define ROUTE_REFRESH_TOPIC_DISCUSS         SERVER_URL "topicDiscuss/getTopicDiscuss"
//发送道具
#define ROUTE_SEND_PROPS                    SERVER_URL "topicDiscuss/sendProp"
//发送消息
#define ROUTE_SEND_DISCUSS_MESSAGE          SERVER_URL "topicDiscuss/addDiscussContent"

//龙虎榜
#define ROUTE_GET_BILLBOARD_LIST            SERVER_URL "loongTigerList/LTList"
#define ROUTE_GET_GAINBOARD_LIST            SERVER_URL "harvestList/getHarvestInfo"

#pragma mark - 个人中心
//主页获取公共信息
#define ROUTE_GET_PERSONAL_INFO             SERVER_URL "userManage/personalCenter"

//商城
#define ROUTE_GET_GOODS_LIST                SERVER_URL "mall/getRealGoods"
#define ROUTE_GET_SHOP_INFO                 SERVER_URL "mall/propMall"
//购买
#define ROUTE_GET_BUY_RICH_CION             SERVER_URL "buy/getBuyRichCoin"
#define ROUTE_GET_BUY_MARS_COIN             SERVER_URL "buy/getBuyMarsCoin"
#define ROUTE_GET_BUY_PROPERTY              SERVER_URL "buy/getBuyProp"
#define ROUTE_GET_BUY_VIDEO                 SERVER_URL "buy/getBuyVideo"
#define ROUTE_GET_BUY_GOODS                SERVER_URL "buy/getBuyShiwu"
#define ROUTE_GET_BUY_VIP                   SERVER_URL "buy/getBuyVip"

#pragma mark - 抽奖相关
//抽奖相关
#define ROUTE_GET_LOTTERY_INFO              SERVER_URL "prize/rewardList"
#define ROUTE_GET_LOTTERY_RESULT            SERVER_URL "prize/getPrizes"
#define ROUTE_SEND_LOTTERY_GOODS_ADDRESS    SERVER_URL "prize/addAddress"

//成长历程
#define ROUTE_GET_GROWTH_LIST               SERVER_URL "growth/growthListForUser"

//上传头像
#define ROUTE_UPLOAD_HEAD_ICON              SERVER_URL "upload/headIcon"

//保存自定义头像
#define ROUTE_SAVE_CUSTOM_HEAD_ICON         SERVER_URL "headIcon/headIconSave"

//保存系统头像
#define ROUTE_SAVE_SYSTEM_HEAD_ICON         SERVER_URL "headIcon/addSystemHeadIcon"

#endif /* Router_h */
