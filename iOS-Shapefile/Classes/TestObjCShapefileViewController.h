#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TestObjCShapefileViewController : UIViewController <MKMapViewDelegate> {
}

@property (nonatomic,assign) IBOutlet MKMapView *mapView;

-(void)openShapefile:(NSString *)strShapefile;

@end

