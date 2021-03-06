#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "Shapefile.h"
#import "ShapePolyline.h"

@interface Shapefile ()
-(void *)parsePolyline:(void *)pMain forRecord:(int)record;
-(void *)parsePoint:(void *)pMain;
@end

@implementation Shapefile
@synthesize objects;
@synthesize shapefileType;
@synthesize	recordCount;
@synthesize fileLength;
@synthesize extendLeft;
@synthesize extendTop;
@synthesize extendRight;
@synthesize extendBottom;

- (void)dealloc {
	if (m_objList)
		[m_objList release];
	[super dealloc];
}

-(NSString *)shapefileTypeAsString{
	NSString* strShapefileType;
	switch(shapefileType)
	{
		
		case kShapeTypeNull:
			strShapefileType = @"Null Shape";
			break;
			
		case kShapeTypePoint:
			strShapefileType = @"Point";
			break;
		
		case kShapeTypePolyline:
			strShapefileType = @"PolyLine";
			break;
			
		case kShapeTypePolygon:
			strShapefileType = @"Polygon";
			break;
			
		case kShapeTypeMulti:
			strShapefileType = @"MultiPoint";
			break;
			
		case kShapeTypePointZ:
			strShapefileType = @"PointZ";
			break;
			
		case kShapeTypePolylineZ:
			strShapefileType = @"PolyLineZ";
			break;
			
		case kShapeTypePolygonZ:
			strShapefileType = @"PolygonZ";
			break;
			
		case kShapeTypeMultiZ:
			strShapefileType = @"MultiPointZ";
			break;
			
		case kShapeTypePointM:
			strShapefileType = @"PointM";
			break;
			
		case kShapeTypePolylineM:
			strShapefileType = @"PolyLineM";
			break;
			
		case kShapeTypePolygonM:
			strShapefileType = @"PolygonM";
			break;
			
		case kShapeTypeMultiM:
			strShapefileType = @"MultiPointM";
			break;
			
		case kShapeTypeMultiPatch:
			strShapefileType = @"MultiPatch";
			break;
			
		case kShapeTypeUnknown:
		default:
			strShapefileType = @"unknown";
			break;
	
	}
	return strShapefileType;
}


int convertToLittleEndianInteger(void* pVal){
	int dwResult;
	
	memcpy((void*) ((unsigned long) &dwResult), (void*) ((unsigned long) pVal + 3), 1);
	memcpy((void*) ((unsigned long) &dwResult + 1), (void*) ((unsigned long) pVal + 2), 1);
	memcpy((void*) ((unsigned long) &dwResult + 2), (void*) ((unsigned long) pVal + 1), 1);
	memcpy((void*) ((unsigned long) &dwResult + 3), (void*) ((unsigned long) pVal), 1);
	
	return dwResult;
}


long convertToLittleEndianLong(long Val)
{
	
	long dwResult = Val;
	
	memcpy((void*) ((unsigned long) &dwResult), (void*) ((unsigned long) &Val + 3), 1);
	memcpy((void*) ((unsigned long) &dwResult + 1), (void*) ((unsigned long) &Val + 2), 1);
	memcpy((void*) ((unsigned long) &dwResult + 2), (void*) ((unsigned long) &Val + 1), 1);
	memcpy((void*) ((unsigned long) &dwResult + 3), (void*) ((unsigned long) &Val), 1);
	
	return dwResult;
	
}

-(BOOL)loadShapefile:(NSString *)strShapefile
{
	if (m_objList)
		[m_objList release];

	m_objList = [[NSMutableArray alloc] init];
	char     *pBufferShapefile;
	void	 *pMain;
	long     nShapefileType;	
	long     nRecord;
	long     nTotalContentLength = 100;
	long	 nContentLength = 0;
	
	m_strShapefile = strShapefile;
	m_data = [NSData dataWithContentsOfFile:m_strShapefile];
	
	pBufferShapefile = malloc([m_data length]);
	[m_data getBytes:pBufferShapefile];
	
	pMain = &pBufferShapefile[0];
	
	// magic number of header block does not match (9994)
	if(convertToLittleEndianInteger(pMain) != 0x270a){
		return NO;
	}
	
	// go to file length
	pMain = (void*) ((unsigned long) pMain + 24);	
	fileLength = 2 * convertToLittleEndianInteger(pMain);
	
	// go to version number
	pMain = (void*) ((unsigned long) pMain + 4);
	memcpy(&m_nVersion, pMain, 4);
	
	// version number should match (1000)
	if(m_nVersion != 0x03e8){
		return NO;
	}
	
	// go to shape type
	pMain = (void*) ((unsigned long) pMain + 4);
	memcpy(&nShapefileType, pMain, 4);
	shapefileType = nShapefileType;
	
	pMain = (void*) ((unsigned long) pMain + 4);
		
	// get bounding box
	memcpy(&extendLeft, pMain, 8);
	pMain = (void*) ((unsigned long) pMain + 8);
	memcpy(&extendBottom, pMain, 8);
	pMain = (void*) ((unsigned long) pMain + 8);
	memcpy(&extendRight, pMain, 8);
	pMain = (void*) ((unsigned long) pMain + 8);
	memcpy(&extendTop, pMain, 8);
	pMain = (void*) ((unsigned long) pMain + 40);
	
	while(nTotalContentLength <= fileLength){
		
		memcpy(&nRecord, pMain, 4);
		recordCount = convertToLittleEndianLong(nRecord);
		pMain = (void*) ((unsigned long) pMain + 4);
		
		memcpy(&nContentLength, pMain, 4);
		nContentLength = convertToLittleEndianLong(nContentLength);
		
		nTotalContentLength = nTotalContentLength + (2 * nContentLength) + 8;
		
		pMain = (void*) ((unsigned long) pMain + 4);
		memcpy(&nShapefileType, pMain, 4);
		pMain = (void*) ((unsigned long) pMain + 4);
		
		if(nShapefileType == kShapeTypePoint)
			pMain = [self parsePoint:pMain];
		
		if((nShapefileType == kShapeTypePolyline) || (nShapefileType == kShapeTypePolygon))
			pMain = [self parsePolyline:pMain forRecord:recordCount];
		
		if(nTotalContentLength == fileLength){
			return YES;
		}
	}
	return YES;
}

-(NSArray*)objects {
	return m_objList;
}

#define NAD83 "+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs"
#define WGS1984 "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
#define DEST_PROJECTION WGS1984

-(void *)parsePoint:(void *)pMain
{
	double nEast = 0, nNorth = 0;
	
	memcpy(&nEast,  (void*) ((unsigned long) pMain), 8);		// east
	memcpy(&nNorth, (void*) ((unsigned long) pMain + 8), 8);	// north

	CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(nNorth, nEast);
		
	MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:coords addressDictionary:nil];
	[m_objList addObject:place];
	[place release];
	
	pMain = (void*) ((unsigned long) pMain + 16);
	
	return pMain;
}

-(void *)parsePolyline:(void *)pMain forRecord:(int)record
{
	long i;
	long nNumParts;
	long nNumPoints;
	long nPart;
	//long nEast, nNorth;
		
	ShapePolyline *shapePolyline = [[ShapePolyline alloc] init];
	[shapePolyline initMutableArray];
	
	for(i = 0; i <= 3; i++){
		memcpy(&(shapePolyline->m_nBoundingBox[i]), pMain, 8);
		pMain = (void*) ((unsigned long) pMain + 8);
		
	}
	
	memcpy(&nNumParts, pMain, 4);
	[shapePolyline setNumParts:nNumParts];
	
	pMain = (void*) ((unsigned long) pMain + 4);
	memcpy(&nNumPoints, pMain, 4);
	[shapePolyline setNumPoints:nNumPoints];
	pMain = (void*) ((unsigned long) pMain + 4);
	
	for(i = 0; i < nNumParts; i++)
	{
		memcpy(&nPart, (void*) (unsigned long) pMain, 4);
		NSNumber *part = [[NSNumber alloc] initWithInt:nPart];
		[shapePolyline->m_Parts addObject:part];
		pMain = (void*) ((unsigned long) pMain + 4);
	}
	
	CLLocationCoordinate2D *pointsCArray = calloc(nNumPoints, sizeof(CLLocationCoordinate2D));

	// read the elements
	for(NSInteger index = 0; index < nNumPoints; index++)
	{
		double north = 0, east = 0;
		memcpy(&east, (void*) (unsigned long) pMain, 8);
		pMain = (void*) ((unsigned long) pMain + 8);
		memcpy(&north, (void*) (unsigned long) pMain, 8);
		pMain = (void*) ((unsigned long) pMain + 8);

		pointsCArray[index] = CLLocationCoordinate2DMake(north, east);
	}

	MKPolygon *polygon=[MKPolygon polygonWithCoordinates:pointsCArray 
												   count:nNumPoints];
    
    polygon.title = [NSString stringWithFormat:@"%d",record];
	
	if (pointsCArray) {
		free(pointsCArray);
		pointsCArray = NULL;
	}
	
	[m_objList addObject:polygon];
	
	return pMain;
}

@end