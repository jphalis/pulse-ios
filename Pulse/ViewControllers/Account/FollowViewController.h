//
//  FollowViewController.h
//  

#import <UIKit/UIKit.h>


@interface FollowViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tblVW;
@property (strong, nonatomic) IBOutlet UILabel *pageTitleLabel;
@property (strong, nonatomic) NSString *pageTitle;
@property (strong, nonatomic) NSMutableArray *arrDetails;

@end
