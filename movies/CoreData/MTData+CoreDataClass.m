//
//  MTData+CoreDataClass.m
//  movies
//
//  Created by Jerry Hale on 10/8/17
//  Copyright © 2018-2020 jhale. All rights reserved
//
//

#import "MTData+CoreDataClass.h"

@implementation MTData

- (void) awakeFromInsert
{
   [super awakeFromInsert];
	
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd";
	self.creationDate = [dateFormatter stringFromDate:[NSDate date]];
}

@end
