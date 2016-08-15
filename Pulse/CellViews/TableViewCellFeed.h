//
//  TableViewCellFeed.h
//

#import <UIKit/UIKit.h>


@interface TableViewCellFeed : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userProfilePicture;
@property (strong, nonatomic) IBOutlet UITextView *feedText;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;


@end
