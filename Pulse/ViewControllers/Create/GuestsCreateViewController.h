//
//  GuestsCreateViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface GuestsCreateViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *partyNameField;
@property (weak, nonatomic) IBOutlet UITextField *partyAddressField;
@property (weak, nonatomic) IBOutlet UIButton *smallPartyIcon;
@property (weak, nonatomic) IBOutlet UILabel *smallPartyLabel;
@property (weak, nonatomic) IBOutlet UIButton *mediumPartyIcon;
@property (weak, nonatomic) IBOutlet UILabel *mediumPartyLabel;
@property (weak, nonatomic) IBOutlet UIButton *largePartyIcon;
@property (weak, nonatomic) IBOutlet UILabel *largePartyLabel;
@property (weak, nonatomic) IBOutlet UILabel *inviteOnlyLabel;
@property (retain, nonatomic) NSString *partyInvite;
@property (retain, nonatomic) NSString *usersInvited;
@property (retain, nonatomic) NSString *usersInvitedCount;
@property (retain, nonatomic) NSString *partyType;
@property (retain, nonatomic) NSString *partySize;
@property (retain, nonatomic) NSString *partyLatitude;
@property (retain, nonatomic) NSString *partyLongitude;

- (IBAction)onLocation:(id)sender;
- (IBAction)onClick:(id)sender;
- (IBAction)onPrevious:(id)sender;
- (IBAction)onScratch:(id)sender;
- (IBAction)onProceed:(id)sender;

@end
