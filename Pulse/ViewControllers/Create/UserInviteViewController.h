//
//  UserInviteViewController.h
//  

#import <UIKit/UIKit.h>


@interface UserInviteViewController : UIViewController <UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) IBOutlet UITableView *tblVW;
@property (strong, nonatomic) NSMutableArray *arrDetails;
@property (retain, nonatomic) NSMutableArray *arrUsers;
@property (retain, nonatomic) NSArray *arrFilteredUsers;
@property (retain, nonatomic) NSMutableArray *myArray;

@property (nonatomic, copy) void (^editInvitedUsers)(NSMutableArray *response);

- (IBAction)onAll:(id)sender;
- (IBAction)onDone:(id)sender;

@end
