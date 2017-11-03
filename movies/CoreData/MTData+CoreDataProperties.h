//
//  MTData+CoreDataProperties.h
//  movies
//
//  Created by Jerry Hale on 10/27/17.
//  Copyright © 2017 jhale. All rights reserved.
//
//

#import "MTData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MTData (CoreDataProperties)

@property (nullable, nonatomic, copy) NSString *creationDate;
@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, copy) NSString *postalCode;
@property (nullable, nonatomic, copy) NSString *showDate;

@end

NS_ASSUME_NONNULL_END
