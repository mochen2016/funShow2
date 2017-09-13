//
//  UserInfo+CoreDataProperties.h
//  funShow
//
//  Created by xiejinke on 16/7/20.
//  Copyright © 2016年 wy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *uid;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *age;
@property (nullable, nonatomic, retain) NSString *sex;
@property (nullable, nonatomic, retain) NSString *pw;

@end

NS_ASSUME_NONNULL_END
