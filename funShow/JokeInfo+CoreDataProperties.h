//
//  JokeInfo+CoreDataProperties.h
//  funShow
//
//  Created by xiejinke on 16/7/20.
//  Copyright © 2016年 wy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "JokeInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface JokeInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *ct;
@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *type;

@end

NS_ASSUME_NONNULL_END
