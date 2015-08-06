#import <CoreLocation/CoreLocation.h>
#import "TestObjCShapefileViewController.h"
#import "Shapefile.h"
#import "ShapePolyline.h"

@implementation TestObjCShapefileViewController
@synthesize mapView;

static MKCoordinateSpan kStandardZoomSpan = {2.f, 2.f};

#define SHP_FILENAME @"zip3"
#define MAP_REGION MKCoordinateRegionMake((CLLocationCoordinate2D){41,-77.5}, (MKCoordinateSpan){7.f, 7.f})

- (BOOL) region:(MKCoordinateRegion)region1 isEqualTo:(MKCoordinateRegion)region2 {
	MKMapPoint coord1 = MKMapPointForCoordinate(region1.center);
	MKMapPoint coord2 = MKMapPointForCoordinate(region2.center);
	BOOL coordsEqual = MKMapPointEqualToPoint(coord1, coord2);
	
	BOOL spanEqual = region1.span.latitudeDelta == region2.span.latitudeDelta; // let's just only do one, okay?
	return (coordsEqual && spanEqual);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.mapView.region = MAP_REGION;

	NSString *shapePath = [[NSBundle mainBundle] pathForResource:SHP_FILENAME ofType:@"shp"];
	[self openShapefile:shapePath];
}

- (void)animateToState
{    
    [self.mapView setRegion:MAP_REGION animated:YES];
}

- (void)animateToAnnotation:(id<MKAnnotation>)annotation
{
	if (!annotation)
		return;
	
    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, kStandardZoomSpan);
    [self.mapView setRegion:region animated:YES];	
}

- (void)moveMapToAnnotation:(id<MKAnnotation>)annotation {
	if (![self region:self.mapView.region isEqualTo:MAP_REGION]) { // it's another region, let's zoom out/in
		[self performSelector:@selector(animateToState) withObject:nil afterDelay:0.3];
		[self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:1.7];        
	}
	else
		[self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:0.7];	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay{
	
	if ([overlay isKindOfClass:[MKPolygon class]]){
		UIColor *myColor = [UIColor redColor];
		
		MKPolygonView*    aView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];		
		aView.fillColor = [myColor colorWithAlphaComponent:0.2];
        aView.strokeColor = [myColor colorWithAlphaComponent:0.7];
        aView.lineWidth = 2;
        return aView;
    }
    return nil;
}

-(void)openShapefile:(NSString *)strShapefile
{
	Shapefile *shapefile = [[Shapefile alloc] init];

	BOOL bLoad = [shapefile loadShapefile:strShapefile withProjection:nil];
	
	if(bLoad)
	{
		long nShapefileType = [shapefile shapefileType];
		
		if(nShapefileType == kShapeTypePoint)
			[self.mapView addAnnotations:shapefile.objects];

		if((nShapefileType == kShapeTypePolyline) || (nShapefileType == kShapeTypePolygon))
			[self.mapView addOverlays:shapefile.objects];
		
		[self.mapView setNeedsDisplay];
	}
	
	else
	{
		[shapefile release];
	}
}


@end
