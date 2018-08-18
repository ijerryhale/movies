//
//  DataAccess.m
//  movies
//
//  Created by Jerry Hale on 4/11/17.
//  Copyright © 2018 jhale. All rights reserved.
//

#import "AFImageDownloader.h"

#import "DictionaryKey.h"
#import "ManagedObjectContext.h"

#import "MIData+CoreDataProperties.h"
#import "MTData+CoreDataProperties.h"
#import "MPData+CoreDataProperties.h"

#import "DataAccess.h"

//	I didn't build this XML Parser,
//	I don't really know who did
NSString *const kXMLParseTextNodeKey	=	@"text";

@interface XMLParse()
@property (nonatomic, strong) NSMutableArray	*dictionaryStack;
@property (nonatomic, strong) NSMutableString	*textInProgress;
@property (nonatomic, strong) NSError			*errorPointer;
@end

@implementation XMLParse

#pragma mark - Public methods
+(NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error
{ return ([[[XMLParse alloc] initWithError:error] objectWithData:data options:0]); /* root dictionary */ }

+(NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)error
{ return ([XMLParse dictionaryForXMLData:[string dataUsingEncoding:NSUTF8StringEncoding] error:error]); }

+(NSDictionary *)dictionaryForXMLData:(NSData *)data options:(XMLReaderOptions)options error:(NSError **)error
{ return ([[[XMLParse alloc] initWithError:error] objectWithData:data options:options]); /* root dictionary */ }

+(NSDictionary *)dictionaryForXMLString:(NSString *)string options:(XMLReaderOptions)options error:(NSError **)error
{ return ([XMLParse dictionaryForXMLData:[string dataUsingEncoding:NSUTF8StringEncoding] options:options error:error]); }

#pragma mark - Parsing

-(id)initWithError:(NSError **)error
{
	self = [super init];
	self.errorPointer = *error;

    return (self);
}

-(NSDictionary *)objectWithData:(NSData *)data options:(XMLReaderOptions)options
{
    //	clear out any old data
    self.dictionaryStack = [[NSMutableArray alloc] init];
    self.textInProgress = [[NSMutableString alloc] init];
    
    //	init stack with a fresh dictionary
    [self.dictionaryStack addObject:[NSMutableDictionary dictionary]];
    
    //	parse the XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
    [parser setShouldProcessNamespaces:(options & XMLReaderOptionsProcessNamespaces)];
    [parser setShouldReportNamespacePrefixes:(options & XMLReaderOptionsReportNamespacePrefixes)];
    [parser setShouldResolveExternalEntities:(options & XMLReaderOptionsResolveExternalEntities)];
    
    parser.delegate = self;
    BOOL success = [parser parse];
	
    //	return the stack's root dictionary on success
    if (success)
    {
        return ([self.dictionaryStack objectAtIndex:0]);
    }
    
    return (nil);
}

#pragma mark -  NSXMLParserDelegate methods
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{   
    //	get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [self.dictionaryStack lastObject];

    //	create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    //	if there's already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue)
    {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]])
        {
            //	the array exists, so use it
            array = (NSMutableArray *) existingValue;
        }
        else
        {
            //	create an array if it doesn't exist
            array = [NSMutableArray array];
            [array addObject:existingValue];

            //	replace the child dictionary with
			//	an array of child dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        //	add new child dictionary to the array
        [array addObject:childDict];
    }
    else
    {
        //	no existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    //	update the stack
    [self.dictionaryStack addObject:childDict];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //	update the parent dict with text info
    NSMutableDictionary *dictInProgress = [self.dictionaryStack lastObject];
    
    //	set the text property
    if ([self.textInProgress length] > 0)
    {
        //	trim after concatenating
        NSString *trimmedString = [self.textInProgress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [dictInProgress setObject:[trimmedString mutableCopy] forKey:kXMLParseTextNodeKey];

        //	reset the text
        self.textInProgress = [[NSMutableString alloc] init];
    }
    
    //	pop the current dict
    [self.dictionaryStack removeLastObject];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //	build the text value
    [self.textInProgress appendString:string];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    //	set the error pointer to the parser's error object
    self.errorPointer = parseError;
	
//    NSString *errorString = [NSString stringWithFormat:@"Error %i, Description: %@, Line: %i, Column: %i", [parseError code],
//        [[parser parserError] localizedDescription], [parser lineNumber],
//        [parser columnNumber]];
//
//    NSLog(errorString);
}

@end

//	#define IS_SSL_CONNECTION

@implementation AFHTTPClient

+(instancetype)sharedClient
{
    static AFHTTPClient		*sharedClient = nil;
    static dispatch_once_t	onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[DataHelper URL_BASE]]];

		#ifdef IS_SSL_CONNECTION
			sharedClient.securityPolicy
								= [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
		#else
			sharedClient.securityPolicy = [AFSecurityPolicy defaultPolicy];
		#endif

		sharedClient.responseSerializer
								= [AFHTTPResponseSerializer serializer];
		[sharedClient.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });

    return (sharedClient);
}
@end

@interface DataHelper()

	+(NSString *)URL_POSTER;
	+(NSString *)URL_TRAILER;
@end

@implementation DataHelper

+(NSString *)URL_BASE
{
    static dispatch_once_t once;
    static NSString * URL_BASE;
    dispatch_once(&once, ^{
        URL_BASE = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_BASE"];
    });
    return (URL_BASE);
}

+(NSString *)URL_POSTER
{
    static dispatch_once_t once;
    static NSString * URL_POSTER;
    dispatch_once(&once, ^{
        URL_POSTER = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_POSTER"];
    });
    return (URL_POSTER);
}

+(NSString *)URL_TRAILER
{
    static dispatch_once_t once;
    static NSString * URL_TRAILER;
    dispatch_once(&once, ^{
        URL_TRAILER = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_TRAILER"];
    });
    return (URL_TRAILER);
}

+(NSURL *)GET_URL_TRAILER:(NSString *)path
{
	NSString	*pathString = [DataHelper URL_BASE];
	
	pathString = [pathString stringByAppendingString:@"/"];
	pathString = [pathString stringByAppendingString:[DataHelper URL_TRAILER]];
	pathString = [pathString stringByAppendingString:path];

	return ([NSURL URLWithString:pathString]);
}

+(NSURL *)GET_URL_POSTER:(NSString *)path
{
	NSString	*pathString = [DataHelper URL_BASE];
	
	pathString = [pathString stringByAppendingString:@"/"];
	pathString = [pathString stringByAppendingString:[DataHelper URL_POSTER]];
	pathString = [pathString stringByAppendingString:path];

	return ([NSURL URLWithString:pathString]);
}

+ (void)downloadImageForURLRequest:(NSURL *)url
							success:(void (^)(NSURLRequest *request, NSHTTPURLResponse  *response, UIImage *responseObject))success
							failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
	NSURLRequest	*request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];

	[[AFImageDownloader defaultInstance] downloadImageForURLRequest:request success:success failure:failure];
}

@end

@interface DataAccess()

	-(NSString *)URL_INDEX;

	-(NSString *)URL_FRAG;
	-(NSString *)URL_THEATER;

	-(void)delete_mt_data_rows;
	-(void)delete_mi_data_rows;
@end

@implementation DataAccess

-(id)init
{
    self = [super init];

	_managedObjectContext = [ManagedObjectContext sharedInstance].managedObjectContext;

    return (self);
}

-(NSString *)URL_THEATER
{
    static dispatch_once_t once;
    static NSString * URL_THEATER;
    dispatch_once(&once, ^{
        URL_THEATER = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_THEATER"];
    });
    return (URL_THEATER);
}

-(NSString *)URL_INDEX
{
    static dispatch_once_t once;
    static NSString * URL_INDEX;
    dispatch_once(&once, ^{
        URL_INDEX = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_INDEX"];
    });
    return (URL_INDEX);
}

-(NSString *)URL_FRAG
{
    static dispatch_once_t once;
    static NSString * URL_FRAG;
    dispatch_once(&once, ^{
        URL_FRAG = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_FRAG"];
    });
    return (URL_FRAG);
}

#pragma mark -

-(void)clearCachedData
{ NSLog(@"DataAccess.clearCachedData");

	NSError			*error = nil;
	NSFetchRequest  *fr = [[NSFetchRequest alloc]init];
	[fr setEntity:[NSEntityDescription entityForName:ENAME_MIDATA inManagedObjectContext:self->_managedObjectContext]];

	NSArray *rowArray = [self->_managedObjectContext executeFetchRequest:fr error:&error];

	for (NSManagedObject *row in rowArray)
	  [_managedObjectContext deleteObject:row];

    if ([_managedObjectContext save:&error] == false) { NSLog(@"Couldn't save to Data Store: %@", [error localizedDescription]); }
	
	[fr setEntity:[NSEntityDescription entityForName:ENAME_MTDATA inManagedObjectContext:self->_managedObjectContext]];
	rowArray = [self->_managedObjectContext executeFetchRequest:fr error:&error];

	for (NSManagedObject *row in rowArray)
	  [_managedObjectContext deleteObject:row];

    if ([_managedObjectContext save:&error] == false) { NSLog(@"Couldn't save to Data Store: %@", [error localizedDescription]); }

	[fr setEntity:[NSEntityDescription entityForName:ENAME_MPDATA inManagedObjectContext:self->_managedObjectContext]];
	rowArray = [self->_managedObjectContext executeFetchRequest:fr error:&error];

	for (NSManagedObject *row in rowArray)
	  [_managedObjectContext deleteObject:row];

    if ([_managedObjectContext save:&error] == false) { NSLog(@"Couldn't save to Data Store: %@", [error localizedDescription]); }
}

-(NSData *)getCachedPoster:(NSURL *)url
{ NSLog(@"DataAccess.getCachedPoster");

	NSError			*error = nil;
	NSFetchRequest	*fr = [[NSFetchRequest alloc] init];
	[fr setEntity:[NSEntityDescription entityForName:ENAME_MPDATA inManagedObjectContext:_managedObjectContext]];
	[fr setPredicate:[NSPredicate predicateWithFormat:@"url == %@", url]];

	NSArray *rowArray = [_managedObjectContext executeFetchRequest:fr error:&error];
	fr = nil;

	if (rowArray.count == 1)
	{
		MPData	*mpd = rowArray[0];
		NSLog(@"Poster Cache Hit: %@", mpd.url);
		return (mpd.data);
	}
	
	NSLog(@"No Cached Poster for: %@", url);
	return (nil);
}

-(void)cachePoster:(NSURL *)url data:(NSData *)data
{ NSLog(@"DataAccess.cachePoster");

	//	create new row in MPData and save this data
	MPData	*mpd = [NSEntityDescription insertNewObjectForEntityForName:ENAME_MPDATA inManagedObjectContext:self->_managedObjectContext];

	[mpd setUrl:url];
	[mpd setData:data];

	NSError	*error = nil;
	if ([self->_managedObjectContext save:&error] == false) { NSLog(@"Couldn't save to Data Store: %@", [error localizedDescription]); }

	#if 0
		NSFetchRequest  *fr = [[NSFetchRequest alloc]init];
		[fr setEntity:[NSEntityDescription entityForName:ENAME_MPDATA inManagedObjectContext:self->_managedObjectContext]];
		NSArray *rowArray = [self->_managedObjectContext executeFetchRequest:fr error:&error];

		for (mpd in rowArray) { NSLog(@"%@ %@", mpd.url, mpd.data); }
	#endif
}

-(void)trimPosterCache
{
	//	delete anything in MPData that
	//	is more than two weeks old
	NSError			*error = nil;
	NSFetchRequest	*fr = [[NSFetchRequest alloc] init];
	[fr setEntity:[NSEntityDescription entityForName:ENAME_MPDATA inManagedObjectContext:_managedObjectContext]];
	[fr setIncludesPropertyValues:NO];   //    only fetch the managedObjectID

	NSArray *rowArray = [_managedObjectContext executeFetchRequest:fr error:&error];
	fr = nil;

	if (rowArray.count == 0)
		return;

	NSDateFormatter	*dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd";

	NSDateComponents	*offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setDay:-14];	//	look for anything older than two weeks

	NSCalendar	*gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDate		*fortnight = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
	//	NSLog(@"%@", fortnight);

	for (MPData *mpd in rowArray)
	{
		NSDate	*creationDate = [dateFormatter dateFromString:mpd.creationDate];

		if ([creationDate earlierDate: fortnight] == creationDate)
		{ NSLog(@"Deleting Poster at URL: %@ from Database", mpd.url);
			[_managedObjectContext deleteObject:mpd];

			 if ([_managedObjectContext save:&error] == false) { NSLog(@"Couldn't save to Data Store: %@", [error localizedDescription]); }
		}
	}
}

-(void)delete_mi_data_rows
{
	//	delete anything in MIData
	//	that wasn't created today
	NSError			*error = nil;
	NSFetchRequest	*fr = [[NSFetchRequest alloc] init];
	[fr setEntity:[NSEntityDescription entityForName:ENAME_MIDATA inManagedObjectContext:_managedObjectContext]];
	[fr setIncludesPropertyValues:NO];   //    only fetch the managedObjectID

	NSArray *rowArray = [_managedObjectContext executeFetchRequest:fr error:&error];
	fr = nil;

	if (rowArray.count == 0)
		return;

	MIData	*mid = rowArray[0];

	NSDateFormatter	*dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd";

	NSString	*today = [dateFormatter stringFromDate:[NSDate date]];
	
	if ([today isEqualToString:mid.creationDate] && rowArray.count == 1)
		return;

	for (NSManagedObject *row in rowArray)
	  [_managedObjectContext deleteObject:row];

    if ([_managedObjectContext save:&error] == false) { NSLog(@"Couldn't save to Data Store: %@", [error localizedDescription]); }
}

-(void)delete_mt_data_rows
{
	//	delete anything in MTData
	//	where the showDate is older
	//	than today
	NSError			*error = nil;
	NSFetchRequest	*fr = [[NSFetchRequest alloc] init];
	[fr setEntity:[NSEntityDescription entityForName:ENAME_MTDATA inManagedObjectContext:_managedObjectContext]];
	[fr setIncludesPropertyValues:NO];   //	only fetch the managedObjectID

	NSArray	*rowArray = [_managedObjectContext executeFetchRequest:fr error:&error];
	fr = nil;

	if (rowArray.count == 0)
		return;

	NSDateFormatter	*dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd";

	unsigned int		flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
	NSCalendar			*calendar = [NSCalendar currentCalendar];
	NSDateComponents	*components = [calendar components:flags fromDate:[NSDate date]];
	NSDate				*todaysdate = [calendar dateFromComponents:components];

	for (NSUInteger i = rowArray.count - 1;i < -1;i--)
	{
		MTData	*data = rowArray[i];
		NSDate	*showdate = [dateFormatter dateFromString:data.showDate];

		if ([showdate compare:todaysdate] == NSOrderedAscending)
		{
			[_managedObjectContext deleteObject:rowArray[i]];

			if ([_managedObjectContext save:&error] == false) { NSLog(@"Couldn't save to Data Store: %@", [error localizedDescription]); }
		}
	}
}
-(NSArray *)parseindex:(NSData *)data
{ NSLog(@"DataAccess.parseindex");

	NSString		*xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

	NSError			*parseError = nil;
	NSDictionary	*xmlDictionary = [XMLParse dictionaryForXMLString:xmlString error:&parseError];
	
	return ([[xmlDictionary objectForKey:@"films"] objectForKey:@"movieinfo"]);
}

-(void)getIndex:(void (^)(NSArray *index, NSError *error))block
{
	[self delete_mi_data_rows];

	NSFetchRequest	*fr = [[NSFetchRequest alloc] init];

	[fr setEntity:[NSEntityDescription entityForName:ENAME_MIDATA inManagedObjectContext:_managedObjectContext]];

	NSError	*error = nil;
	NSArray *rowArray = [_managedObjectContext executeFetchRequest:fr error:&error];
	fr = nil;

	if (rowArray.count)
	{
		NSLog(@"Using Data Store for Index");
		if (rowArray.count > 1) NSLog(@"%i rows in MIData for getIndex!!!", (int)rowArray.count);

		MIData	*mid = rowArray[0];

		block([self parseindex:mid.data], nil);

		return;
	}

	NSMutableString	*url = [NSMutableString stringWithString:[self URL_INDEX]];

	[[AFHTTPClient sharedClient] GET:url
			parameters:nil progress:nil success:^(NSURLSessionDataTask * __unused task, id responseObject)
	{
		if (block)
		{
			//	create new row in MIData and save this data
			MIData	*mid = [NSEntityDescription insertNewObjectForEntityForName:ENAME_MIDATA inManagedObjectContext:self->_managedObjectContext];

			[mid setData:responseObject];

			NSError	*error = nil;
			if ([self->_managedObjectContext save:&error] == false) { NSLog(@"Couldn't save to Data Store: %@", [error localizedDescription]); }
			
			#if 0
				NSFetchRequest  *fr = [[NSFetchRequest alloc]init];
			[fr setEntity:[NSEntityDescription entityForName:ENAME_MIDATA inManagedObjectContext:self->_managedObjectContext]];
				NSArray *rowArray = [self->_managedObjectContext executeFetchRequest:fr error:&error];

				for (mid in rowArray) { NSLog(@"%@", mid.creationDate); }
			#endif
			
			block([self parseindex:responseObject], nil);
		}
	}
	 
	failure:^(NSURLSessionDataTask *__unused task, NSError *error)
	{
		 if (block) block([NSArray array], error);
	}];
}

-(NSArray *)parsetheaters:(NSData *)data
{ NSLog(@"DataAccess.parsetheaters");

    NSError	*error = nil;
    NSArray	*array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];

	NSMutableArray	*theaters = [NSMutableArray array];

	if (array) for (int i = 0;i < [array count];i++)
	{
		//	array of array of theaters
		NSArray	*pages = [[array objectAtIndex:i] objectForKey:@"pages"];

		for (int j = 0;j < [pages count];j++)
			for (int k = 0;k < [pages[j] count];k++)
				[theaters addObject:pages[j][k]];
	}

	return (theaters);
}

-(void)getTheaters:(NSString *)showdate postalcode:(NSString *)postalcode
								completion:(void (^)(NSArray *theaterArray, NSError *error))block
{
	[self delete_mt_data_rows];

	NSError			*error = nil;
	NSFetchRequest	*fr = [[NSFetchRequest alloc] init];
	[fr setEntity:[NSEntityDescription entityForName:ENAME_MTDATA inManagedObjectContext:_managedObjectContext]];

	[fr setPredicate:[NSPredicate predicateWithFormat:@"showDate == %@ AND postalCode == %@", showdate, postalcode]];
	
	NSArray *rowArray = [_managedObjectContext executeFetchRequest:fr error:&error];
	fr = nil;

	if (rowArray.count)
	{
		NSLog(@"Using Data Store for Theaters");
		if (rowArray.count > 1) NSLog(@"%i rows in MTData for getTheaters!!!", (int)rowArray.count);

		MTData	*mtd = rowArray[0];

		block([self parsetheaters:mtd.data], nil);

		return;
	}

	NSMutableString	*url = [NSMutableString stringWithString:[self URL_THEATER]];

	[url appendString:showdate];
	[url appendString:[self URL_FRAG]];
	[url appendString:postalcode];

	[[AFHTTPClient sharedClient] GET:url
				parameters:nil progress:nil success:^(NSURLSessionDataTask * __unused task, id responseObject)
	{
		//	create new row in MTData and save this data
		MTData	*mtd = [NSEntityDescription insertNewObjectForEntityForName:ENAME_MTDATA inManagedObjectContext:self->_managedObjectContext];

		[mtd setData:responseObject];
		[mtd setShowDate:showdate];
		[mtd setPostalCode:postalcode];

		NSError	*error = nil;
		if ([self->_managedObjectContext save:&error] == false) { NSLog(@"Couldn't save to Data Store: %@", [error localizedDescription]); }
			
		#if 0
			NSFetchRequest  *fr = [[NSFetchRequest alloc]init];
			[fr setEntity:[NSEntityDescription entityForName:ENAME_MTDATA inManagedObjectContext:self->_managedObjectContext]];
			NSArray *rowArray = [self->_managedObjectContext executeFetchRequest:fr error:&error];

			for (mtd in rowArray) { NSLog(@"%@ %@", mtd.postalCode, mtd.showDate); }
		#endif
			
		if (block) block([self parsetheaters:responseObject], nil);
	}
		 
	failure:^(NSURLSessionDataTask *__unused task, NSError *error)
	{
		if (block) block([NSArray array], error);
	}];
}
@end

