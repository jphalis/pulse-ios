//
//  AccountViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface AccountViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet SDIAsyncImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UILabel *eventCount;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UIButton *eventsBtn;
@property (strong, nonatomic) IBOutlet UITextField *profileBio;
@property (weak, nonatomic) IBOutlet UIImageView *lockIcon;
@property (strong, nonatomic) NSString *userURL;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionVW;
@property (nonatomic, assign) BOOL needBack;

- (IBAction)onBack:(id)sender;
- (IBAction)onSettings:(id)sender;
- (IBAction)onProfilePictureChange:(id)sender;
- (IBAction)onEvents:(id)sender;
- (IBAction)onViewList:(id)sender;
- (IBAction)onFollow:(id)sender;

@end
