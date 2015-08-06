#import "ShapePolyline.h"
#import <MapKit/MapKit.h>
@implementation ShapePolyline

@synthesize numParts;
@synthesize numPoints;

-(void)initMutableArray
{
	m_Parts = [[NSMutableArray alloc] init];
	m_Points = [[NSMutableArray alloc] init];
}

@end
