//
//  HomeViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>


@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblWaterMark;
@property (weak, nonatomic) IBOutlet UITableView *tblVW;
@property (retain, nonatomic) NSMutableArray *arrFeed;

@end
