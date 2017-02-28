//
//  SearchResultsTableViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>

@interface SearchResultsTableViewController : UIViewController

@property (nonatomic, strong) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UILabel *lblWaterMark;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic, assign) BOOL isInviteSearch;

@property (nonatomic, copy) void (^editInvitedUsers)(NSMutableArray *response);

@end
