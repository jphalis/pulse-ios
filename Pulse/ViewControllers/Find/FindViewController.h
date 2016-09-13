//
//  FindViewController.h
//  Pulse
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>


@interface FindViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionVW;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *annotations;

- (IBAction)onBack:(id)sender;

@end

@interface MyAnnotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title, *subtitle;
- (id)initWithLocation:(CLLocationCoordinate2D)coord;
@end
