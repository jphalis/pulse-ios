//
//  TableViewCellInvite.h
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface TableViewCellInvite : UITableViewCell

@property (strong, nonatomic) IBOutlet SDIAsyncImageView *userProfilePicture;
@property (strong, nonatomic) IBOutlet UITextView *userName;

@end
