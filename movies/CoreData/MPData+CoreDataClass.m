//
//  MPData+CoreDataClass.m
//  movies
//
//  Created by Jerry Hale on 6/11/18.
//  Copyright © 2019 jhale. All rights reserved.
//
//

#import "MPData+CoreDataClass.h"

@implementation MPData

- (void) awakeFromInsert
{
	[super awakeFromInsert];

	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd";
	self.creationDate = [dateFormatter stringFromDate:[NSDate date]];
}

@end
