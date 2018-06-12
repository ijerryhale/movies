//
//  MIData+CoreDataProperties.h
//  
//
//  Created by Jerry Hale on 6/11/18.
//
//  This file was automatically generated and should not be edited.
//

#import "MIData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MIData (CoreDataProperties)

+ (NSFetchRequest<MIData *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *creationDate;
@property (nullable, nonatomic, retain) NSData *data;

@end

NS_ASSUME_NONNULL_END
