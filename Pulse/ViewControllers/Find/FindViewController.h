//
//  FindViewController.h
//  Pulse
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>


@interface FindViewController : UIViewController <MKMapViewDelegate>


@property (strong, nonatomic) IBOutlet UICollectionView *collectionVW;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)onBack:(id)sender;

@end
