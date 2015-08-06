#import <Foundation/Foundation.h>

@interface CMADataManager : NSObject
+ (id)sharedInstance;
- (NSDictionary*)paZip3CountsLookup;
-(BOOL)getIsVisibleForZip:(NSString*)Zip;
-(NSString*)getZipCodeForIndex:(NSInteger)index;
@end
