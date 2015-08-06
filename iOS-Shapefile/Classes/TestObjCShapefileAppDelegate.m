#import "TestObjCShapefileAppDelegate.h"
#import "TestObjCShapefileViewController.h"

@implementation TestObjCShapefileAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	return YES;
}

@end
