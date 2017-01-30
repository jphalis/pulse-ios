//
//  HomeViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>


@interface HomeViewController : UIViewController <UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UILabel *lblWaterMark;
@property (weak, nonatomic) IBOutlet UITableView *tblVW;
@property (retain, nonatomic) NSMutableArray *arrFeed;
@property (retain, nonatomic) NSMutableArray *arrUsers;
@property (retain, nonatomic) NSArray *arrFilteredUsers;

@end
