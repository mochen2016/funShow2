//
//  DataBaseOpe.m
//  funShow
//
//  Created by xiejinke on 16/7/20.
//  Copyright © 2016年 wy. All rights reserved.
//

#import "DataBaseOpe.h"
#import "JokeInfo.h"
#import "UserInfo.h"
#import "MarkJoke.h"
@implementation DataBaseOpe

+ (NSManagedObjectContext *)context {
    return [AppDelegate currentDelegate].privateContext;
}

+ (id)searchEntityWithPredicate:(NSPredicate *)predicate entityname:(NSString *)name {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:[self context]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [[self context] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"------search error = %@",error.description);
    }
    if (fetchedObjects.count) {
        if (predicate == nil) {
            return fetchedObjects;
        }
        
        return fetchedObjects.firstObject;
    }
    
    return nil;
}


+ (BOOL)saveUserInfo:(NSDictionary *)userDict completion:(void (^)(BOOL))completion {
    if (!userDict || userDict.count == 0) {
        return NO;
    }
    
    [[self context] performBlock:^{
        NSPredicate *p = [NSPredicate predicateWithFormat:@"uid = %@",userDict[@"uid"]];
        NSManagedObject *info = [self searchEntityWithPredicate:p entityname:@"UserInfo"];
        if (!info) {
            info = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:[self context]];
        }
        [info setValue:[NSNumber numberWithInteger:[userDict[@"uid"] integerValue]] forKey:@"uid"];
        [info setValue:userDict[@"name"] forKey:@"name"];
        [info setValue:[NSNumber numberWithInteger:[userDict[@"age"] integerValue]] forKey:@"age"];
        [info setValue:userDict[@"sex"] forKey:@"sex"];
        [info setValue:userDict[@"pw"] forKey:@"pw"];
        
        NSError *err = nil;
        if (![[self context] save:&err]) {
            if (completion) {
                completion(NO);
            }
            NSLog(@"error = %@",err.description);
        }
    
        if (completion) {
            completion(YES);
        }

    }];
    
    return YES;
    
}

+ (BOOL)getUserInfoByName:(NSString *)name Completion:(void (^)(NSDictionary *))completion {
    if (!name || name.length == 0) {
        return NO;
    }
    
    [[self context] performBlock:^{
        NSPredicate *p = [NSPredicate predicateWithFormat:@"name = %@",name];
        NSManagedObject *info = [self searchEntityWithPredicate:p entityname:@"UserInfo"];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:5];
        infoDic[@"uid"] = [info valueForKey:@"uid"];
        infoDic[@"name"] = [info valueForKey:@"name"];
        infoDic[@"age"] = [info valueForKey:@"age"];
        infoDic[@"sex"] = [info valueForKey:@"sex"];
        infoDic[@"pw"] = [info valueForKey:@"pw"];
        if (completion) {
            completion(infoDic);
        }
    }];

    
    return YES;
}


+ (BOOL)saveMarkJoke:(NSDictionary *)joke completion:(void (^)(BOOL))completion {
    if (!joke || !joke.count) {
        return NO;
    }
    
    [[self context] performBlock:^{
        NSPredicate *p = [NSPredicate predicateWithFormat:@"uid = %@ and id = %@",joke[@"uid"],joke[@"id"]];
        NSManagedObject *info = [self searchEntityWithPredicate:p entityname:@"MarkJoke"];
        if (!info) {
            info = [NSEntityDescription insertNewObjectForEntityForName:@"MakeJoke" inManagedObjectContext:[self context]];
            [info setValue:[NSNumber numberWithInteger:[joke[@"uid"] integerValue]] forKey:@"uid"];
            [info setValue:joke[@"name"] forKey:@"name"];
            [info setValue:[NSNumber numberWithInteger:[joke[@"type"] integerValue]] forKey:@"type"];
            [info setValue:joke[@"id"] forKey:@"id"];
            [info setValue:joke[@"ct"] forKey:@"ct"];
            [info setValue:joke[@"text"] forKey:@"text"];
            [info setValue:joke[@"title"] forKey:@"title"];
        }
        
        
        NSError *err = nil;
        if (![[self context] save:&err]) {
            if (completion) {
                completion(NO);
            }
            NSLog(@"error = %@",err.description);
        }
        
        if (completion) {
            completion(YES);
        }
        
    }];

    
    return YES;
}

+ (BOOL)getMarkJokeCompletion:(void(^)(NSArray *markJokes))completion{
    [[self context] performBlock:^{
        NSArray *jokes = [self searchEntityWithPredicate:nil entityname:@"MarkJoke"];
        
        if (completion) {
            completion(jokes);
        }
    }];

    return  YES;
}

+ (BOOL)cacheNewJoke:(NSArray *)jokes isRefresh:(BOOL)refresh completion:(void (^)(BOOL))completion{
    if (jokes.count == 0) {
        return NO;
    }
    [[self context] performBlock:^{
        if (refresh) {
            NSArray *oldJokes = [self searchEntityWithPredicate:nil entityname:@"JokeInfo"];
            if (oldJokes && oldJokes.count) {
                for (NSManagedObject *obj in oldJokes) {
                    [[self context] deleteObject:obj];
                }
                
                NSError *error;
                if (![[self context] save:&error]){
                    NSLog(@"error:%@",error);
                }
            }
        }
        
        
        for (NSDictionary *joke in jokes) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"id = %@",joke[@"id"]];
            NSManagedObject *info = [self searchEntityWithPredicate:p entityname:@"JokeInfo"];
            if (!info) {
                NSManagedObject *info = [NSEntityDescription insertNewObjectForEntityForName:@"JokeInfo" inManagedObjectContext:[self context]];
                [info setValue:[NSString stringWithFormat:@"%@",joke[@"id"]] forKey:@"id"];
                [info setValue:[NSString stringWithFormat:@"%@",joke[@"ct"]] forKey:@"ct"];
                [info setValue:[NSString stringWithFormat:@"%@",joke[@"text"]] forKey:@"text"];
                [info setValue:[NSString stringWithFormat:@"%@",joke[@"title"]] forKey:@"title"];
                [info setValue:[NSNumber numberWithInt:[joke[@"type"] intValue]] forKey:@"type"];
            }
           
    
            NSError *err = nil;
            if (![[self context] save:&err]) {
                if (completion) {
                    completion(NO);
                }
                NSLog(@"error = %@",err.description);
            }
        }
        
        if (completion) {
            completion(YES);
        }
    }];
    
    return YES;
}


+ (BOOL)getJokeCompletion:(void (^)(NSArray *))completion {
    [[self context] performBlock:^{
        NSArray *jokes = [self searchEntityWithPredicate:nil entityname:@"JokeInfo"];
        
        if (completion) {
            completion(jokes);
        }
    }];
    
    return YES;
}



@end
