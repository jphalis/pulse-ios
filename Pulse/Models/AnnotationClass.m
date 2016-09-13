//
//  AnnotationClass.m
//

#import "AnnotationClass.h"


@implementation AnnotationClass

@synthesize title, subtitle, coordinate, annotationUrl;

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [_latitude doubleValue];
    theCoordinate.longitude = [_longitude doubleValue];
    return theCoordinate;
}

@end
