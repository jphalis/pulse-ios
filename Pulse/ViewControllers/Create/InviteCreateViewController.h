//
//  InviteCreateViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>


@interface InviteCreateViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *openPartyIcon;
@property (weak, nonatomic) IBOutlet UIButton *requestPartyIcon;
@property (weak, nonatomic) IBOutlet UIButton *exclusivePartyIcon;
@property (retain, nonatomic) NSString *partyInvite;
@property (retain, nonatomic) NSString *partyType;
@property (weak, nonatomic) IBOutlet UILabel *visibilityLabel;
@property (retain, nonatomic) NSMutableArray *usersInvited;

- (IBAction)onClick:(id)sender;
- (IBAction)onPrevious:(id)sender;
- (IBAction)onScratch:(id)sender;
- (IBAction)onProceed:(id)sender;

@end
