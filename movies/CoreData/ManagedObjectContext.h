//
//  ManagedObjectContext.h
//  movies
//
//  Created by Jerry Hale on 10/28/17
//  Copyright © 2018-2020 jhale. All rights reserved
//


@interface ManagedObjectContext : NSObject
{
    NSManagedObjectModel            *_objectModel;
    NSManagedObjectContext          *_mainObjectContext;
    NSPersistentStoreCoordinator    *_persistentStoreCoordinator;
}

@property (nonatomic, readonly, retain) NSManagedObjectModel            *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext          *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

+(ManagedObjectContext *)sharedInstance;

-(BOOL)save;
-(NSManagedObjectContext *)managedObjectContext;

+(NSArray *)objectsForEntityNamed:(NSString *)name inContext:(NSManagedObjectContext *)context;
+(NSArray *)objectsForEntityNamed:(NSString *)name matchingKey:(NSString *)key andValue:(id)value inContext:(NSManagedObjectContext *)context;
+(NSManagedObject *)objectForEntityNamed:(NSString *)name matchingKey:(NSString *)key andValue:(id)value inContext:(NSManagedObjectContext *)context;
+(NSArray *)objectsForEntityNamed:(NSString *)name matchingKeysAndValues:(NSDictionary *)keyValues usingOR:(BOOL)useOR inContext:(NSManagedObjectContext *)context;

@end
