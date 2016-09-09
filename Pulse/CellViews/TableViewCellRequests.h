//
//  TableViewCellRequests.h
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface TableViewCellRequests : UITableViewCell

@property (strong, nonatomic) IBOutlet SDIAsyncImageView *userProfilePicture;
@property (strong, nonatomic) IBOutlet UITextView *userName;
@property (weak, nonatomic) IBOutlet UIButton *approveBtn;
@property (weak, nonatomic) IBOutlet UIButton *denyBtn;

@end
