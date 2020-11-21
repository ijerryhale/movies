//
//  MPData+CoreDataProperties.h
//  movies
//
//  Created by Jerry Hale on 6/11/18
//  Copyright © 2018-2020 jhale. All rights reserved
//
//

#import "MPData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MPData (CoreDataProperties)

@property (nullable, nonatomic, copy) NSString *creationDate;
@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, copy) NSURL *url;

@end

NS_ASSUME_NONNULL_END
