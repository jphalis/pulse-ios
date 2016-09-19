//
//  UserInviteViewController.h
//  

#import <UIKit/UIKit.h>


@interface UserInviteViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tblVW;
@property (strong, nonatomic) NSMutableArray *arrDetails;

@property (nonatomic, copy) void (^editInvitedUsers)(NSMutableArray *response);

- (IBAction)onDone:(id)sender;

@end
