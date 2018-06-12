//
//  MPData+CoreDataProperties.h
//  
//
//  Created by Jerry Hale on 6/11/18.
//
//  This file was automatically generated and should not be edited.
//

#import "MPData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MPData (CoreDataProperties)

+ (NSFetchRequest<MPData *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *creationDate;
@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, copy) NSURL *url;

@end

NS_ASSUME_NONNULL_END
