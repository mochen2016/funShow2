//
//  ServerDataOpe.h
//  funShow
//
//  Created by xiejinke on 16/7/20.
//  Copyright © 2016年 wy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerDataOpe : NSObject


+ (void)getJokeDataByPage:(int)page
                     isRefresh:(BOOL)refresh
                withBlock:(void(^)(NSDictionary *data))block;

@end
