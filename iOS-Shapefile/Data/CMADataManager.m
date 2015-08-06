#import "CMADataManager.h"

/*******************************
 * Data Filenames *
 *******************************/
static NSString* const PA_FILENAME = @"pa_zip3_counts";
static NSString* const ZIP_KEYS_FILENAME = @"zip3";
static NSString* const EXT_PLIST = @"plist";

/********
 * Keys *
 ********/
static NSString* const Key_Zip3 = @"ZIP3";
static NSString* const Key_Count = @"Count";

@implementation CMADataManager
+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if(self)
    {
    }
    return self;
}

- (NSArray*)zip3Array
{
    static NSArray *allItems;
    if (!allItems) {
        allItems = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:ZIP_KEYS_FILENAME withExtension:EXT_PLIST]];
    }
    return allItems;
}

- (NSDictionary*)paZip3CountsLookup
{
    static NSMutableDictionary *lookup;
    if (!lookup) {
        NSArray *allItems = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:PA_FILENAME withExtension:EXT_PLIST]];
        lookup = [NSMutableDictionary dictionaryWithCapacity:[allItems count]];
        for (NSDictionary *item in allItems) {
            [lookup setObject:item forKey:[item valueForKey:Key_Zip3]];
        }
    }
    return lookup;
}

-(BOOL)getIsVisibleForZip:(NSString*)Zip
{
    return  ([[[self paZip3CountsLookup] allKeys] containsObject:Zip]);
}

-(NSString*)getZipCodeForIndex:(NSInteger)index
{
    NSDictionary *dict = [[self zip3Array] objectAtIndex:index];
    NSString* zipcode = [dict objectForKey:Key_Zip3];
    return zipcode;
}
@end
