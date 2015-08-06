#import <Foundation/Foundation.h>
#import "Shapefile.h"

@interface ShapePolyline : Shapefile
{

@private
	
	long numParts;
	long numPoints;
	
@public
	
	NSMutableArray* m_Points;
	NSMutableArray* m_Parts;
	double m_nBoundingBox[4];
	double m_nEast;
	double m_nNorth;

}

-(void)initMutableArray;
@property (readwrite) long numParts;
@property (readwrite) long numPoints;

@end
