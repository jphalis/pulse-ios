//
//  RequestsViewController.h
//  

#import <UIKit/UIKit.h>


@interface RequestsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tblVW;
@property (strong, nonatomic) NSMutableArray *arrDetails;
@property (retain) NSString *partyId;
@property (retain) NSString *userName;
@property (retain) NSString *userId;

@end
