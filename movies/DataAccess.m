//
//  DataAccess.m
//  movies
//
//  Created by Jerry Hale on 4/11/17.
//  Copyright © 2018 jhale. All rights reserved.
//

//	https://cormya.com/jsonserver/movies/focus_features/7-days-in-entebbe/7-days-in-entebbe-trailer-1_h.480.mov
//	https://cormya.com/jsonserver/trailers/focus_features/7-days-in-entebbe/images/poster-large.jpg

#import "ManagedObjectContext.h"

#import "MIData+CoreDataProperties.h"
#import "MTData+CoreDataProperties.h"

#import "DataAccess.h"

#import "DictionaryKey.h"

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
        sharedClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[DataAccess URL_BASE]]];

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

@interface DataAccess()
	-(void)delete_mt_data_rows;
	-(void)delete_mi_data_rows;

	-(NSString *)URL_FRAG;
@end

@implementation DataAccess

-(id)init
{
    self = [super init];

	_managedObjectContext = [ManagedObjectContext sharedInstance].managedObjectContext;

    return (self);
}

+(NSString *)URL_BASE
{
    static dispatch_once_t once;
    static NSString * URL_BASE;
    dispatch_once(&once, ^{
        URL_BASE = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_BASE"];
    });
    return (URL_BASE);
}

+(NSString *)URL_STRING
{
    static dispatch_once_t once;
    static NSString * URL_STRING;
    dispatch_once(&once, ^{
        URL_STRING = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_STRING"];
    });
    return (URL_STRING);
}

+(NSString *)URL_INDEX
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

+(NSURL *)GET_URL:(NSString *)path
{
	NSString	*string = [[DataAccess URL_BASE] stringByAppendingFormat:@"/%@", path];
	NSURL		*url = [NSURL URLWithString:string];

	return (url);
}

+(NSData *)GET_DATA:(NSString *)path
{
	NSData	*data = [NSData dataWithContentsOfURL:[DataAccess GET_URL:path]];
	
	if (data == nil)
	{
		return nil;
	}
	
	return (data);
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

	NSUInteger today =
		[[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:[NSDate date]];

	for (NSUInteger i = rowArray.count - 1;i < -1;i--)
	{
		MTData		*data = rowArray[i];
		NSUInteger	showDate =
		[[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:[dateFormatter dateFromString:data.showDate]];
		
		if (showDate < today)
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

	NSMutableString	*url = [NSMutableString stringWithString:[DataAccess URL_INDEX]];

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
				NSFetchRequest  *req = [[NSFetchRequest alloc]init];
				[req setEntity:[NSEntityDescription entityForName:ENAME_MIDATA inManagedObjectContext:_managedObjectContext]];
				NSArray *array = [_managedObjectContext executeFetchRequest:req error:&error];

				for (mid in array) { NSLog(@"%@", mid.creationDate); }
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

	NSString	*jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

	jsonString = [jsonString stringByReplacingOccurrencesOfString:@"&#x00E4;" withString:@"ä"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"&#x00E9;" withString:@"é"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];

	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError	*error = nil;
    NSArray	*array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];

	NSMutableArray	*theaters = [NSMutableArray array];

	if (array) for (int i = 0;i < [array count];i++)
	{
		//	array of array of theaters
		NSArray	*pages = [[array objectAtIndex:i] objectForKey:@"pages"];

		for (int j = 0;j < [pages count];j++)
			for (int k = 0;k < [pages[j] count];k++)
				[theaters addObject:pages[j][k]];
	}

	return(theaters);
}

#pragma mark -
-(void)getTheaters:(NSString *)showdate postalcode:(NSString *)postalcode
								completion:(void (^)(NSArray *theaterArray, NSError *error))block
{
	[self delete_mt_data_rows];

	NSFetchRequest	*fr = [[NSFetchRequest alloc] init];
	[fr setEntity:[NSEntityDescription entityForName:ENAME_MTDATA inManagedObjectContext:_managedObjectContext]];

	[fr setPredicate:[NSPredicate predicateWithFormat:@"showDate == %@ AND postalCode == %@", showdate, postalcode]];

	NSError	*error = nil;
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

	NSMutableString	*url = [NSMutableString stringWithString:[DataAccess URL_STRING]];

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
			NSFetchRequest  *req = [[NSFetchRequest alloc]init];
			[req setEntity:[NSEntityDescription entityForName:ENAME_MTDATA inManagedObjectContext:_managedObjectContext]];
				NSArray *array = [_managedObjectContext executeFetchRequest:req error:&error];

			for (mtd in array) { NSLog(@"%@", mtd.dateFetched);
					NSLog(@"%@", mtd.postalCode); NSLog(@"%@", mtd.showDate); }
		#endif
			
		if (block) block([self parsetheaters:responseObject], nil);
		}
		 
	failure:^(NSURLSessionDataTask *__unused task, NSError *error)
	{
		if (block) block([NSArray array], error);
	}];
}
@end

