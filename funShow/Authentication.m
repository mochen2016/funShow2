//
//  Authentication.m
//  funShow
//
//  Created by xiejinke on 16/7/26.
//  Copyright © 2016年 wy. All rights reserved.
//

#import "Authentication.h"
#import <LocalAuthentication/LocalAuthentication.h>


@implementation Authentication


+ (void)authenticateUserLocalizedReason:(NSString *)localizedReason
                      completionSuccess:(void (^)())completionSuccess
                                  error:(void (^)(NSError *))completionError
                   notCanEvaluatePolicy:(void (^)(NSError *))notCanEvaluate
{
    LAContext* context = [[LAContext alloc] init];
    NSError* error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:localizedReason reply:^(BOOL success, NSError *error){
            if (success) {
                if (completionSuccess) {
                    completionSuccess();
                }
            }else {
                if (completionError) {
                    completionError(error);
                }
            }
        }];
    } else {
        if (notCanEvaluate) {
            notCanEvaluate(error);
        }
    }
}




@end
