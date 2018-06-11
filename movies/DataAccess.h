//
//  DataAccess.h
//  movies
//
//  Created by Jerry Hale on 4/11/17.
//  Copyright © 2018 jhale. All rights reserved.
//

#import "AFNetworking/AFNetworking.h"

enum {
    XMLReaderOptionsProcessNamespaces           = 1 << 0, // Specifies whether the receiver reports the namespace and the qualified name of an element.
    XMLReaderOptionsReportNamespacePrefixes     = 1 << 1, // Specifies whether the receiver reports the scope of namespace declarations.
    XMLReaderOptionsResolveExternalEntities     = 1 << 2, // Specifies whether the receiver reports declarations of external entities.
};
typedef NSUInteger XMLReaderOptions;

@interface XMLParse : NSObject <NSXMLParserDelegate>

+(NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+(NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;
+(NSDictionary *)dictionaryForXMLData:(NSData *)data options:(XMLReaderOptions)options error:(NSError **)errorPointer;
+(NSDictionary *)dictionaryForXMLString:(NSString *)string options:(XMLReaderOptions)options error:(NSError **)errorPointer;

@end

@interface AFHTTPClient : AFHTTPSessionManager

+(instancetype)sharedClient;

@end

@interface DataAccess : NSObject

@property (strong) NSManagedObjectContext   *managedObjectContext;

+(NSString *)URL_BASE;
+(NSString *)URL_INDEX;
+(NSString *)URL_STRING;

+(NSURL *)GET_URL:(NSString *)path;
+ (void)downloadImageForURLRequest:(NSString *)path
					success:(void (^)(NSURLRequest *request, NSHTTPURLResponse  *response, UIImage *responseObject))success
					failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

-(NSArray *)parseindex:(NSData *)data;
-(NSArray *)parsetheaters:(NSData *)array;

-(void)getIndex:(void (^)(NSArray *index, NSError *error))block;
-(void)getTheaters:(NSString *)showdate postalcode:(NSString *)postalcode
								completion:(void (^)(NSArray *theaterArray, NSError *error))block;
@end
