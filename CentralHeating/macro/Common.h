//
//  Common.h
//  CentralHeating
//
//  Created by ghg on 15/11/26.
//  Copyright © 2015年 ghg. All rights reserved.
//

#ifndef Common_h
#define Common_h

//单例定义
#pragma mark -
#pragma mark 单例定义
#define DECLARE_SINGLETON_FOR_CLASS(classname) \
+ (classname*)sharedInstance;

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname)	\
+ (classname *)sharedInstance\
{\
static classname *shared##classname = nil;\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
shared##classname = [[self alloc] init];\
});\
return shared##classname;\
}

#endif /* Common_h */
