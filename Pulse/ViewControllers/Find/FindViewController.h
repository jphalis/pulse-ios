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
@property (weak, nonatomic) IBOutlet UIButton *currentLocBtn;
@property (weak, nonatomic) IBOutlet UILabel *watermarkLbl;

- (IBAction)onBack:(id)sender;
- (IBAction)onCurrentLocation:(id)sender;

@end

@interface MyAnnotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title, *subtitle;
- (id)initWithLocation:(CLLocationCoordinate2D)coord;
@end
