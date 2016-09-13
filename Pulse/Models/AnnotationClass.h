//
//  AnnotationClass.h
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface AnnotationClass : MKPointAnnotation <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *annotationUrl;

@end
