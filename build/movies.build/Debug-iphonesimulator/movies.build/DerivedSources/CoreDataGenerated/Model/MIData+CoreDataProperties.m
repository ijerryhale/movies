//
//  MIData+CoreDataProperties.m
//  
//
//  Created by Jerry Hale on 6/11/18.
//
//  This file was automatically generated and should not be edited.
//

#import "MIData+CoreDataProperties.h"

@implementation MIData (CoreDataProperties)

+ (NSFetchRequest<MIData *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"MIData"];
}

@dynamic creationDate;
@dynamic data;

@end
