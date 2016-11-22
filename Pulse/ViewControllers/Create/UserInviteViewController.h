//
//  UserInviteViewController.h
//  

#import <UIKit/UIKit.h>


@interface UserInviteViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tblVW;
@property (strong, nonatomic) NSArray *arrDetails;

@property (nonatomic, copy) void (^editInvitedUsers)(NSMutableArray *response);

- (IBAction)onAll:(id)sender;
- (IBAction)onDone:(id)sender;

@end
