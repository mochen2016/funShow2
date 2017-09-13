//
//  Authentication.h
//  funShow
//
//  Created by xiejinke on 16/7/26.
//  Copyright © 2016年 wy. All rights reserved.
//

#import <Foundation/Foundation.h>

//    LAErrorSystemCancel //切换到其他APP，系统取消验证Touch ID
//    LAErrorUserCancel   //用户取消验证Touch ID
//    LAErrorUserFallback //用户选择其他验证方式，切换主线程处理


@interface Authentication : NSObject
+ (void)authenticateUserLocalizedReason:(NSString *)localizedReason
                      completionSuccess:(void(^)())completionSuccess
                                  error:(void(^)(NSError *error))completionError
                     notCanEvaluatePolicy:(void(^)(NSError *error))notCanEvaluate;
@end
