
//
//  DataAccess.h
//  Movies
//
//  Created by Jerry Hale on 4/11/17.
//  Copyright © 2017 jhale. All rights reserved.
//


#ifdef HAS_WEB_SERVICE
	#import "AFNetworking/AFNetworking.h"
#endif

enum {
    XMLReaderOptionsProcessNamespaces           = 1 << 0, // Specifies whether the receiver reports the namespace and the qualified name of an element.
    XMLReaderOptionsReportNamespacePrefixes     = 1 << 1, // Specifies whether the receiver reports the scope of namespace declarations.
    XMLReaderOptionsResolveExternalEntities     = 1 << 2, // Specifies whether the receiver reports declarations of external entities.
};
typedef NSUInteger XMLReaderOptions;

@interface XMLParse : NSObject <NSXMLParserDelegate>

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLData:(NSData *)data options:(XMLReaderOptions)options error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string options:(XMLReaderOptions)options error:(NSError **)errorPointer;

@end

#ifdef HAS_WEB_SERVICE

@interface IndexClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end

@interface TheaterClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
#endif

@interface DataAccess : NSObject

+ (BOOL)IS_LOCAL_SERVER;
+ (NSString *)URL_BASE;
+ (NSString *)URL_INDEX;
+ (NSString *)URL_STRING;
+ (NSData *)GET_DATA:(NSString *)path;
+ (NSURL *)GET_URL:(NSString *)path;


- (NSArray *)parseindex:(NSData *)data;
- (NSArray *)parsetheaters:(NSData *)array;

- (NSURLSessionDataTask *)getindex:(void (^)(NSArray *index, NSError *error))block;
- (NSURLSessionDataTask *)gettheaters:(NSString *)showdate postalcode:(NSString *)postalcode
								completion:(void (^)(NSArray *theaters, NSError *error))block;
@end
