//
//  TableViewCellNotification.h
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface TableViewCellNotification : UITableViewCell

@property (weak, nonatomic) IBOutlet SDIAsyncImageView *senderProfilePicture;
@property (weak, nonatomic) IBOutlet UITextView *notificationTextField;
@property (weak, nonatomic) IBOutlet UIButton *profileBtn;

@end
