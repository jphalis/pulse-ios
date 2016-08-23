//
//  TableViewCellAccount.h
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface TableViewCellAccount : UITableViewCell


@property (strong, nonatomic) IBOutlet SDIAsyncImageView *userProfilePicture;
@property (strong, nonatomic) IBOutlet UITextView *userName;
@property (strong, nonatomic) IBOutlet UIButton *followBtn;

- (IBAction)onFollow:(id)sender;

@end
