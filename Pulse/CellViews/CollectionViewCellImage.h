//
//  CollectionViewCellImage.h
//

#import <UIKit/UIKit.h>


@interface CollectionViewCellImage : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *viewInfo;
@property (strong, nonatomic) IBOutlet UILabel *partyDate;
@property (strong, nonatomic) IBOutlet UILabel *partyTime;
@property (strong, nonatomic) IBOutlet UIImageView *partyPicture;
@property (strong, nonatomic) IBOutlet UIImageView *userProfilePicture;
@property (strong, nonatomic) IBOutlet UILabel *partyName;
@property (strong, nonatomic) IBOutlet UILabel *partyAddress;
@property (strong, nonatomic) IBOutlet UILabel *numberAttending;
@property (strong, nonatomic) IBOutlet UILabel *numberRequests;

@end
