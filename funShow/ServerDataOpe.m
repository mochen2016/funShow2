//
//  ServerDataOpe.m
//  funShow
//
//  Created by xiejinke on 16/7/20.
//  Copyright © 2016年 wy. All rights reserved.
//

#import "ServerDataOpe.h"
#import "CustomNetworking.h"
#import "DataBaseOpe.h"
static NSString *const apikey = @"11d7e729fbaec89d9a294c1ef52aa9e3";
static NSString *const jokeUrl = @"http://apis.baidu.com/showapi_open_bus/showapi_joke/joke_text";

@implementation ServerDataOpe

+ (void)getJokeDataByPage:(int)page isRefresh:(BOOL)refresh withBlock:(void (^)(NSDictionary *))block {
    NSString *url = [NSString stringWithFormat:@"%@?page=%d",jokeUrl,page];
    [CustomNetworking configCommonHttpHeaders:@{@"apikey":apikey}];
    [CustomNetworking getWithUrl:url success:^(id response) {
        int code = [[response objectForKey:@"showapi_res_code"] intValue];
        NSString *errorMsg = [response objectForKey:@"showapi_res_error"];
        if (code == 0) {
            NSDictionary *body = response[@"showapi_res_body"];
            NSArray *contentlist = body[@"contentlist"];
            
            [DataBaseOpe cacheNewJoke:contentlist isRefresh:refresh completion:^(BOOL flag) {
                if (block) {
                    block(body);
                }
            }];
            
        }else {
            NSLog(@"%@",errorMsg);
        }
    } fail:^(NSError *error) {
        NSLog(@"fail");
    }];
}


@end
