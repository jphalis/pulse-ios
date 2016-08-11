//
//  CollectionViewCellImage.h
//

#import <UIKit/UIKit.h>


@interface CollectionViewCellImage : UICollectionViewCell

//@property (weak, nonatomic) IBOutlet UIView *viewInfo;
//@property (strong, nonatomic) IBOutlet UILabel *partyDate1;
//@property (strong, nonatomic) IBOutlet UILabel *partyTime1;
//@property (strong, nonatomic) IBOutlet UIImageView *partyPicture1;
//@property (strong, nonatomic) IBOutlet UIImageView *userProfilePicture1;
//@property (strong, nonatomic) IBOutlet UILabel *partyName1;
//@property (strong, nonatomic) IBOutlet UILabel *partyAddress1;
//@property (strong, nonatomic) IBOutlet UILabel *numberAttending1;
//@property (strong, nonatomic) IBOutlet UILabel *numberRequests1;

@property (strong, nonatomic) IBOutlet UIImageView *partyPicture;
@property (strong, nonatomic) IBOutlet UILabel *partyDate;
@property (strong, nonatomic) IBOutlet UILabel *partyTime;
@property (strong, nonatomic) IBOutlet UIImageView *userProfilePicture;
@property (strong, nonatomic) IBOutlet UILabel *partyName;
@property (strong, nonatomic) IBOutlet UILabel *partyAddress;
@property (strong, nonatomic) IBOutlet UILabel *partyAttending;
@property (strong, nonatomic) IBOutlet UILabel *partyRequests;


@end
