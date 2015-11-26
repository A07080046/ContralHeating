//
//  WebAPI.m
//  CentralHeating
//
//  Created by ghg on 15/11/26.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import "WebAPI.h"
#import "AFNetworking.h"

@implementation WebAPI
SYNTHESIZE_SINGLETON_FOR_CLASS(WebAPI)

- (void)get:(NSTimeInterval)timeout :(BOOL)showWait :(id)handle :(NSString *)url :(NSString *)info :(SEL)success :(SEL)failed {
    MBProgressHUD * HUD;
    if (showWait) {
        HUD = [self showWait:handle: info];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = timeout;
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (showWait) {
            [self hideWait:HUD];
        }
        if (success != nil) {
            [handle performSelector:success withObject:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (showWait) {
            [self hideWait:HUD];
        }
        if (failed != nil) {
            [handle performSelector:failed withObject:error];
        }
    }];
}


- (void)post:(NSTimeInterval)timeout :(BOOL)showWait :(id)handle :(NSString *)key :(NSString *)url :(NSString *)info :(NSDictionary *)param :(SEL)success :(SEL)failed {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer.timeoutInterval = timeout;
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
#ifndef USE_JSON_DATA
    NSString *data = AFQueryStringFromParametersWithEncoding(param, NSUTF8StringEncoding);
#else //USE_JSON_DATA
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    NSString *data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
#endif //USE_JSON_DATA
    
    MBProgressHUD * HUD;
    if (showWait) {
        HUD = [self showWait:handle: info];
    }
    NSLog(@"postData:url=%@\nparam=%@",url, data);
    NSLog(@"postEncryptData:param=%@", [NSDictionary dictionaryWithObjectsAndKeys:__BASE64(data, key), @"data" ,nil]);
    [manager POST:url parameters:[NSDictionary dictionaryWithObjectsAndKeys:__BASE64(data, key), @"data" ,nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (showWait) {
            [self hideWait:HUD];
        }
        NSString *encryptData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData *decryptData = [__TEXT(encryptData, key) dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:decryptData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"backData:url=%@\nparam=%@",url,__TEXT(encryptData, key));
        
        if (dictionary != nil) {
            if (success != nil) {
                [handle performSelector:success withObject:dictionary];
            }
        } else {
            if (failed != nil) {
                [handle performSelector:failed withObject:nil];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"net error: url=%@",url);
        if (showWait) {
            [self hideWait:HUD];
        }
        if (failed != nil) {
            [handle performSelector:failed withObject:error];
        }
    }];
}
@end
