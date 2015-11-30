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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
     manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"responseObject = %@", responseObject);
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"json = %@", result);
        NSLog(@"dic = %@",dic);
        if (dic != nil) {
            if (success != nil) {
                [handle performSelector:success withObject:dic];
            }
        } else {
            if (failed != nil) {
                [handle performSelector:failed withObject:nil];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failed != nil) {
            [handle performSelector:failed withObject:error];
        }
    }];
}


- (void)post:(NSTimeInterval)timeout :(BOOL)showWait :(id)handle :(NSString *)key :(NSString *)url :(NSString *)info :(NSDictionary *)param :(SEL)success :(SEL)failed {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"json = %@", result);
        NSLog(@"dic = %@",dic);
        if (dic != nil) {
            if (success != nil) {
                [handle performSelector:success withObject:dic];
            }
        } else {
            if (failed != nil) {
                [handle performSelector:failed withObject:nil];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (failed != nil) {
            [handle performSelector:failed withObject:error];
        }
    }];
}
@end
