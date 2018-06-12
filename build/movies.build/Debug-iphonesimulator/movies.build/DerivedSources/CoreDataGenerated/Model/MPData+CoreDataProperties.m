//
//  MPData+CoreDataProperties.m
//  
//
//  Created by Jerry Hale on 6/11/18.
//
//  This file was automatically generated and should not be edited.
//

#import "MPData+CoreDataProperties.h"

@implementation MPData (CoreDataProperties)

+ (NSFetchRequest<MPData *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"MPData"];
}

@dynamic creationDate;
@dynamic data;
@dynamic url;

@end
