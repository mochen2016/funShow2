//
//  DataBaseOpe.h
//  funShow
//
//  Created by xiejinke on 16/7/20.
//  Copyright © 2016年 wy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
@interface DataBaseOpe : NSObject
+ (NSManagedObjectContext *)context;
+ (id)searchEntityWithPredicate:(NSPredicate *)predicate entityname:(NSString *)name;

+ (BOOL)saveUserInfo:(NSDictionary *)userDict completion:(void(^)(BOOL flag))completion;

+ (BOOL)getUserInfoByName:(NSString *)name Completion:(void(^)(NSDictionary *user))completion;

+ (BOOL)cacheNewJoke:(NSArray *)jokes isRefresh:(BOOL)refresh completion:(void(^)(BOOL flag))completion;

+ (BOOL)getJokeCompletion:(void(^)(NSArray *jokes))completion;

+ (BOOL)saveMarkJoke:(NSDictionary *)joke completion:(void(^)(BOOL flag))completion;

+ (BOOL)getMarkJokeCompletion:(void(^)(NSArray *markJokes))completion;

@end
