
#import <UIKit/UIKit.h>

@class TestObjCShapefileViewController;

@interface TestObjCShapefileAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestObjCShapefileViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestObjCShapefileViewController *viewController;

@end

