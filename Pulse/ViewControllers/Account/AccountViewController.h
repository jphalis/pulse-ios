//
//  AccountViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface AccountViewController : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) NSString *userURL;
@property (weak, nonatomic) IBOutlet SDIAsyncImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *eventCount;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (nonatomic, assign) BOOL needBack;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionVW;

- (IBAction)onBack:(id)sender;
- (IBAction)onSettings:(id)sender;
- (IBAction)onProfilePictureChange:(id)sender;
- (IBAction)onEvents:(id)sender;
- (IBAction)onViewList:(id)sender;

@end
