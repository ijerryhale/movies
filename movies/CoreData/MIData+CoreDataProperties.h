//
//  MIData+CoreDataProperties.h
//  movies
//
//  Created by Jerry Hale on 10/27/17
//  Copyright © 2018-2020 jhale. All rights reserved
//
//

#import "MIData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MIData (CoreDataProperties)

@property (nullable, nonatomic, copy) NSString *creationDate;
@property (nullable, nonatomic, retain) NSData *data;

@end

NS_ASSUME_NONNULL_END
