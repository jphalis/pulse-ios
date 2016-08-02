//
//  CustomTabViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>


@interface CustomTabViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (strong, nonatomic) UICollectionView *currentView;

@end
