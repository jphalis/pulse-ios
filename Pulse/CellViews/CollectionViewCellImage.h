//
//  CollectionViewCellImage.h
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface CollectionViewCellImage : UICollectionViewCell

@property (strong, nonatomic) IBOutlet SDIAsyncImageView *partyPicture;
@property (strong, nonatomic) IBOutlet UILabel *partyDate;
@property (strong, nonatomic) IBOutlet UILabel *partyTime;
@property (strong, nonatomic) IBOutlet SDIAsyncImageView *userProfilePicture;
@property (strong, nonatomic) IBOutlet UILabel *partyName;
@property (strong, nonatomic) IBOutlet UILabel *partyAddress;
@property (strong, nonatomic) IBOutlet UILabel *partyAttending;
@property (strong, nonatomic) IBOutlet UILabel *partyRequests;


@end
