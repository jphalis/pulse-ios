//
//  TableViewCellFeed.h
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface TableViewCellFeed : UITableViewCell

@property (strong, nonatomic) IBOutlet SDIAsyncImageView *userProfilePicture;
@property (strong, nonatomic) IBOutlet UITextView *feedText;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileBtn;

@end
