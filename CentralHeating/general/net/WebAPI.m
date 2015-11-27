//
//  WebAPI.m
//  CentralHeating
//
//  Created by ghg on 15/11/26.
//  Copyright © 2015年 ghg. All rights reserved.
//

#import "WebAPI.h"
#import "AFHTTPRequestOperationManager.h"

@implementation WebAPI
SYNTHESIZE_SINGLETON_FOR_CLASS(WebAPI)

- (void)get:(NSTimeInterval)timeout :(BOOL)showWait :(id)handle :(NSString *)url :(NSString *)info :(SEL)success :(SEL)failed {
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer.timeoutInterval = timeout;
//    
//    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if (success != nil) {
//            [handle performSelector:success withObject:responseObject];
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if (failed != nil) {
//            [handle performSelector:failed withObject:error];
//        }
//    }];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)post:(NSTimeInterval)timeout :(BOOL)showWait :(id)handle :(NSString *)key :(NSString *)url :(NSString *)info :(NSDictionary *)param :(SEL)success :(SEL)failed {
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    manager.requestSerializer.timeoutInterval = timeout;
//    
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    
//    NSLog(@"postData:url=%@\nparam=%@",url, data);
//    [manager POST:url parameters:[NSDictionary dictionaryWithObjectsAndKeys:data, @"data" ,nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *encryptData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSData *decryptData = [encryptData dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:decryptData options:NSJSONReadingMutableLeaves error:nil];
//        
//        if (dictionary != nil) {
//            if (success != nil) {
//                [handle performSelector:success withObject:dictionary];
//            }
//        } else {
//            if (failed != nil) {
//                [handle performSelector:failed withObject:nil];
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"net error: url=%@",url);
//        if (failed != nil) {
//            [handle performSelector:failed withObject:error];
//        }
//    }];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"foo": @"bar"};
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
@end
