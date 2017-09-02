//
//  DataAccess.m
//  Movies
//
//  Created by Jerry Hale on 4/11/17.
//  Copyright © 2017 jhale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#import "DictionaryKey.h"

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
+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error
{
    return ([[[XMLParse alloc] initWithError:error] objectWithData:data options:0]); //	root dictionary
}

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)error
{
    return [XMLParse dictionaryForXMLData:[string dataUsingEncoding:NSUTF8StringEncoding] error:error];
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data options:(XMLReaderOptions)options error:(NSError **)error
{
	return ([[[XMLParse alloc] initWithError:error] objectWithData:data options:options]); //	root dictionary
}

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string options:(XMLReaderOptions)options error:(NSError **)error
{
    return ([XMLParse dictionaryForXMLData:[string dataUsingEncoding:NSUTF8StringEncoding] options:options error:error]);
}

#pragma mark - Parsing

- (id)initWithError:(NSError **)error
{
	self = [super init];
	self.errorPointer = *error;

    return self;
}

- (NSDictionary *)objectWithData:(NSData *)data options:(XMLReaderOptions)options
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
    
    return nil;
}

#pragma mark -  NSXMLParserDelegate methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
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

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
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

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //	build the text value
    [self.textInProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    //	set the error pointer to the parser's error object
    self.errorPointer = parseError;
}

@end

#ifdef HAS_WEB_SERVICE

@implementation IndexClient

+ (instancetype)sharedClient
{
    static IndexClient	*_sharedClient = nil;
    static dispatch_once_t		onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[IndexClient alloc] initWithBaseURL:[NSURL URLWithString:[DataAccess URL_BASE]]];

		if ([DataAccess IS_LOCAL_SERVER])
			_sharedClient.securityPolicy = [AFSecurityPolicy defaultPolicy];
		else
			_sharedClient.securityPolicy
								= [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];

			_sharedClient.responseSerializer
								= [AFHTTPResponseSerializer serializer];
			[_sharedClient.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });

    return (_sharedClient);
}
@end

@implementation TheaterClient

+ (instancetype)sharedClient
{
    static TheaterClient	*_sharedClient = nil;
    static dispatch_once_t			onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TheaterClient alloc] initWithBaseURL:[NSURL URLWithString:[DataAccess URL_BASE]]];

		if ([DataAccess IS_LOCAL_SERVER])
			_sharedClient.securityPolicy = [AFSecurityPolicy defaultPolicy];
		else
			_sharedClient.securityPolicy
								= [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];

			_sharedClient.responseSerializer
								= [AFHTTPResponseSerializer serializer];
			[_sharedClient.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });

    return (_sharedClient);
}
@end
#endif

@interface DataAccess()
	- (NSString *)URL_FRAG;
@end

@implementation DataAccess

+ (BOOL)IS_LOCAL_SERVER
{
    static dispatch_once_t once;
    static BOOL IS_LOCAL_SERVER;
    dispatch_once(&once, ^{
        IS_LOCAL_SERVER = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"IS_LOCAL_SERVER"]boolValue];
	});
    return IS_LOCAL_SERVER;
}

+ (NSString *)URL_BASE
{
    static dispatch_once_t once;
    static NSString * URL_BASE;
    dispatch_once(&once, ^{
        URL_BASE = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_BASE"];
    });
    return URL_BASE;
}

+ (NSString *)URL_STRING
{
    static dispatch_once_t once;
    static NSString * URL_STRING;
    dispatch_once(&once, ^{
        URL_STRING = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_STRING"];
    });
    return URL_STRING;
}

+ (NSString *)URL_INDEX
{
    static dispatch_once_t once;
    static NSString * URL_INDEX;
    dispatch_once(&once, ^{
        URL_INDEX = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_INDEX"];
    });
    return URL_INDEX;
}

- (NSString *)URL_FRAG
{
    static dispatch_once_t once;
    static NSString * URL_FRAG;
    dispatch_once(&once, ^{
        URL_FRAG = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_FRAG"];
    });
    return URL_FRAG;
}

+ (NSURL *)GET_URL:(NSString *)path
{
	#ifdef HAS_WEB_SERVICE
		NSString	*string = [[DataAccess URL_BASE] stringByAppendingFormat:@"/%@", path];
		NSURL		*url = [NSURL URLWithString:string];
	#else
		NSString	*string = [@"file://" stringByAppendingString:[[NSBundle mainBundle] resourcePath]];
		NSURL		*url = [NSURL URLWithString:[string stringByAppendingFormat:@"/%@", path]];
	#endif
	
	return (url);
}

+ (NSData *)GET_DATA:(NSString *)path
{
	NSData	*data = [NSData dataWithContentsOfURL:[DataAccess GET_URL:path]];
	
	if (data == nil)
	{
	
	
	}
	
	return (data);
}


- (NSArray *)parseindex:(NSData *)data
{ NSLog(@"DataAccess.parseindex");
	
	NSString		*xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSError			*parseError = nil;
	NSDictionary	*xmlDictionary = [XMLParse dictionaryForXMLString:xmlString error:&parseError];

	return ([[xmlDictionary objectForKey:@"films"] objectForKey:@"movieinfo"]);
}

#ifdef HAS_WEB_SERVICE
- (NSURLSessionDataTask *)getindex:(void (^)(NSArray *index, NSError *error))block
{
	NSMutableString	*url = [NSMutableString stringWithString:[DataAccess URL_INDEX]];

	if ([DataAccess IS_LOCAL_SERVER])
		[url appendString:@".xml"];

	return [[IndexClient sharedClient] GET:url
			parameters:nil progress:nil success:^(NSURLSessionDataTask * __unused task, id responseObject)
	{
		if (block) block([self parseindex:responseObject], nil);
	}
		
	failure:^(NSURLSessionDataTask *__unused task, NSError *error)
	{
		 if (block) block([NSArray array], error);
    }];
}
#endif

- (NSArray *)parsetheaters:(NSData *)data
{ NSLog(@"DataAccess.parsetheaters");

	NSString	*jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

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
				//	theaters[j][k] is a single theater dictionary
				[theaters addObject:pages[j][k]];
	}

	return(theaters);
}

#ifdef HAS_WEB_SERVICE
#pragma mark -
- (NSURLSessionDataTask *)gettheaters:(NSString *)showdate postalcode:(NSString *)postalcode
								completion:(void (^)(NSArray *theaters, NSError *error))block
{
	NSMutableString	*url = [NSMutableString stringWithString:[DataAccess URL_STRING]];

	if ([DataAccess IS_LOCAL_SERVER])
		[url appendString:@".json"];
	else
	{
		[url appendString:showdate];
		[url appendString:[self URL_FRAG]];
		[url appendString:postalcode];
	}

	return [[TheaterClient sharedClient] GET:url
			parameters:nil progress:nil success:^(NSURLSessionDataTask * __unused task, id responseObject)
	{
		if (block) block([self parsetheaters:responseObject], nil);
	}
		
	failure:^(NSURLSessionDataTask *__unused task, NSError *error)
	{
		 if (block) block([NSArray array], error);
    }];
}
#endif

@end
