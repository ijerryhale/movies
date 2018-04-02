//
//  ManagedObjectContext.m
//  movies
//
//  Created by Jerry Hale on 10/28/17.
//  Copyright © 2018 jhale. All rights reserved.
//

NSString * const CORE_DATA_EXCEPTION = @"Core Data exception";
NSString * const MANAGED_CONTEXT_DID_SAVE = @"DataManagerDidSaveNotification";
NSString * const MANAGED_CONTEXT_DID_SAVE_FAILED = @"DataManagerDidSaveFailedNotification";

#import "ManagedObjectContext.h"

#pragma mark ManagedObjectContext
@implementation ManagedObjectContext

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize objectModel = _objectModel;

+ (ManagedObjectContext *)sharedInstance
{
	static dispatch_once_t		pred;
	static ManagedObjectContext	*sharedInstance = nil;

	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });

    return (sharedInstance);
}
 
-(void)dealloc
{
    [self save];
}

-(NSManagedObjectModel *)objectModel
{
	if (_objectModel) return (_objectModel);

	_objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"mom" subdirectory:@"Model.momd"]];
 
	return (_objectModel);
}
 
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) return (_persistentStoreCoordinator);
  
	// Define the Core Data version migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
				 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
				 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
				 nil];
 
	//  attempt to load the persistent store
	NSError *error = nil;
    
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];

	NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            storeURL = [storeURL URLByAppendingPathComponent:@"movies.sqlite"];

	NSLog(@"%@", storeURL.absoluteString);
	
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
						       configuration:nil URL:storeURL options:options error:&error])
    {
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
	}
 
	return _persistentStoreCoordinator;
}

-(NSManagedObjectContext *)mainObjectContext
{
	if (_mainObjectContext) return (_mainObjectContext);
 
	//  create the main context only on the main thread
	if (![NSThread isMainThread])
    {
		[self performSelectorOnMainThread:@selector(mainObjectContext)
 				       withObject:nil
				    waitUntilDone:YES];

        return (_mainObjectContext);
	}
 
	_mainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
 
	return (_mainObjectContext);
}

-(BOOL)save
{
	if (![self.mainObjectContext hasChanges]) return (YES);
 
	NSError *error = nil;

	if (![self.mainObjectContext save:&error])
    {
		NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);

        [[NSNotificationCenter defaultCenter] postNotificationName:MANAGED_CONTEXT_DID_SAVE_FAILED object:error];
		return (NO);
	}
 
	[[NSNotificationCenter defaultCenter] postNotificationName:MANAGED_CONTEXT_DID_SAVE object:nil];

    return (YES);
}

-(NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext  *ctx = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

    [ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];
 
	return (ctx);
}

+(NSArray *)objectsForEntityNamed:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    //  we have to tell the Fetch Request which entity instances to retrieve. We do
    //  that using an NSEntityDescription based on the parameter name.
    NSEntityDescription *entity = [NSEntityDescription 
       entityForName:name inManagedObjectContext:context];

    //  ext, we declare an NSFetchRequest, and give it the entity description
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];	[fr setEntity:entity];

    //  before executing the fetch request, we declare an NSError
    //  which is used to find out about any problems encountered
    //  executing the request
    NSError *error = nil;

    //  we next supply it (by reference) when we execute the request
    NSArray *array = [context executeFetchRequest:fr error:&error];

    //  a nil array tells us something went wrong
    if (array == nil)
    {
       //   we instantiate an exception using the error description from
       //   NSError, then raise the exception, which stops execution
        NSException *exception = [NSException exceptionWithName:CORE_DATA_EXCEPTION
                                    reason:[error localizedDescription] userInfo:nil];

        //   since execution will stop when we raise the exception, we
        //   need to release any memory before we do so. 
        [exception raise];
    }

    // Return the result set returned from executing the fetch request
    return (array);
}

//
//  NSArray *results = [ManagedObjectContext objectsForEntityNamed:@"person" matchingKey:@"lastName" andValue:@"Smith" inContext:context];
//
+(NSArray *)objectsForEntityNamed:(NSString *)name matchingKey:(NSString *)key
                                andValue:(id)value inContext:(NSManagedObjectContext *)context
{
    //  since NSString and NSPredicate use different format strings,
    //  we use a two-step process to create our format string here
    NSString *predString = [NSString stringWithFormat:@"%@ == %%@", key];
    NSPredicate *pred = [NSPredicate predicateWithFormat:predString, value];

    //  we still need an entity description, of course
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:context];

    //  and, of course, a fetch request. This time we give it both the entity
    //  description and the predicate we've just created.
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:entity];
    [fr setPredicate:pred];

    //  we declare an NSError and handle errors by raising
    //  an exception, just like in the previous method
	
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fr error:&error];     

    if (array == nil)
    {
       NSException *exception = [NSException exceptionWithName:CORE_DATA_EXCEPTION
           reason:[error localizedDescription] userInfo:nil];

        [exception raise];
    }

    return (array);
}

//
//  NSManagedObject *item = [ManagedObjectContext objectsForEntityNamed:@"book" matchingKey:@"id" andValue:[NSNumber numberWithInt:192] inContext:context];
//
+(NSManagedObject *)objectForEntityNamed:(NSString *)name  matchingKey:(NSString *)key
                        andValue:(id)value inContext:(NSManagedObjectContext *)context
{
    //  we call the previous method, then return the object at index 0. We 
    //  declare no exception handler, so an exception encountered in this call
    //  will stop execution of this method and throw up to the code 
    //  from where it was called.
    NSArray *array = [ManagedObjectContext objectsForEntityNamed:name  matchingKey:key andValue:value inContext:context];

    //  if there are more than one objects in the array, throw an exception
    if ([array count] > 1)
    {
        NSException *exception = [NSException exceptionWithName:@"Too many entities returned"
                                        reason:@"Too many instances retrieved for criteria" userInfo:nil];	
       [exception raise];
    }

    //  if there are no objects, just return nil
    if ([array count] == 0)
        return (nil);
		
    //  return the object at index 0
    return ((NSManagedObject *)[array objectAtIndex:0]);
}

//
//  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"BookCo", @"publisher", [NSNumber numberWithInt:482769], @"salesRank", nil];
//
//  NSArray *array = [ManagedObjectContext objectsForEntityNamed:@"Book" matchingKeysAndValues:dict usingOR:YES inContext:[self managedObjectContext]];
//
+(NSArray *)objectsForEntityNamed:(NSString *)name matchingKeysAndValues:(NSDictionary *)keyValues 
                        usingOR:(BOOL)useOR inContext:(NSManagedObjectContext *)context
{
    //  we'll retrieve an enumerator of all the keys in the dictionary
    NSEnumerator *e = [keyValues keyEnumerator];

    //  declare the predicate outside of the enumerator loop
    NSPredicate *pred = nil;

    //  declare a string to hold the current key while looping
    NSString    *key;
     
    while (key = [e nextObject]) 
    {
        //  declare a format string for creating the current subpredicate
        NSString *predString = [NSString stringWithFormat:@"%@ == %%@",  key];

        //  first time through, pred is nil and shouldn't be compounded with anything
        if (pred == nil)
            pred = [NSPredicate predicateWithFormat:predString, [keyValues objectForKey:key]];
       else
       {
            //   if pred is not nil, then create a compound based on the new
            // subpredicate tempPred and the existing predicate pred
            NSPredicate *tempPred = [NSPredicate predicateWithFormat:predString, [keyValues objectForKey:key]];

            NSArray *array = [NSArray arrayWithObjects:tempPred, pred, nil];

            if (useOR)
                pred = [NSCompoundPredicate orPredicateWithSubpredicates:array];
            else
                pred = [NSCompoundPredicate andPredicateWithSubpredicates:array]; 
        }
    }

    //  everything from here down should look familiar.
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:context];

    NSFetchRequest  *fr = [[NSFetchRequest alloc] init];

    [fr setEntity:entity];
    [fr setPredicate:pred];

    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fr error:&error];

    if (array == nil)
    {
        NSException *exception = [NSException exceptionWithName:CORE_DATA_EXCEPTION reason:[error localizedDescription] userInfo:nil];

        [exception raise];
    }

    return (array);
}
@end
