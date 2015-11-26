//
//  WebAPI.h
//  CentralHeating
//
//  Created by ghg on 15/11/26.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@interface WebAPI : NSObject
DECLARE_SINGLETON_FOR_CLASS(WebAPI)

- (void)get:(NSTimeInterval)timeout :(BOOL)showWait :(id)handle :(NSString *)url :(NSString *)info :(SEL)success :(SEL)failed;
- (void)post:(NSTimeInterval)timeout :(BOOL)showWait :(id)handle :(NSString *)key :(NSString *)url :(NSString *)info :(NSDictionary *)param :(SEL)success :(SEL)failed;
@end
