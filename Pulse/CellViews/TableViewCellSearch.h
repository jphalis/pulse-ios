//
//  TableViewCellSearch.h
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface TableViewCellSearch : UITableViewCell

@property (weak, nonatomic) IBOutlet SDIAsyncImageView *userProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *userFullName;

@end
