//
//  EventsViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>


@interface EventsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *collectionVW;
@property (retain) NSString *userId;

@end
