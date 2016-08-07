//
//  TableViewCellAccount.h
//

#import <UIKit/UIKit.h>


@interface TableViewCellAccount : UITableViewCell


@property (strong, nonatomic) IBOutlet UIImageView *userProfilePicture;
@property (strong, nonatomic) IBOutlet UITextView *userName;
@property (strong, nonatomic) IBOutlet UIButton *followBtn;

- (IBAction)onFollow:(id)sender;

@end
