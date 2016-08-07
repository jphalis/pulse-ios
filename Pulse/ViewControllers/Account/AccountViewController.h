//
//  AccountViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>


@interface AccountViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *eventCount;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;

- (IBAction)onSettings:(id)sender;
- (IBAction)onProfilePictureChange:(id)sender;
- (IBAction)onEvents:(id)sender;
- (IBAction)onFollowers:(id)sender;
- (IBAction)onFollowing:(id)sender;

@end
