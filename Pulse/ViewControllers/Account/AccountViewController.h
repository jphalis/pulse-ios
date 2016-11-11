//
//  AccountViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>
#import "KIImagePager.h"
#import "SDIAsyncImageView.h"


@interface AccountViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scroller;
@property (weak, nonatomic) IBOutlet SDIAsyncImageView *profilePicture;
@property (weak, nonatomic) IBOutlet KIImagePager *imagePager;
@property (weak, nonatomic) IBOutlet UITextField *profileName;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@property (weak, nonatomic) IBOutlet UILabel *eventCount;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn2;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UIButton *eventsBtn;
@property (weak, nonatomic) IBOutlet UITextField *profileBio;
@property (weak, nonatomic) IBOutlet UIImageView *lockIcon;
@property (weak, nonatomic) IBOutlet UIButton *userImagesBtn;
@property (weak, nonatomic) IBOutlet UIButton *eventImagesBtn;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionVW;
@property (weak, nonatomic) IBOutlet UIButton *userImageNewBtn;
@property (strong, nonatomic) NSString *userURL;
@property (nonatomic, assign) BOOL needBack;

- (IBAction)onBack:(id)sender;
- (IBAction)onSettings:(id)sender;
- (IBAction)onProfilePictureChange:(id)sender;
- (IBAction)onEvents:(id)sender;
- (IBAction)onViewList:(id)sender;
- (IBAction)onFollow:(id)sender;
- (IBAction)onVerify:(id)sender;
- (IBAction)onUserImages:(id)sender;
- (IBAction)onEventImages:(id)sender;
- (IBAction)onAddNewPhoto:(id)sender;

@end
