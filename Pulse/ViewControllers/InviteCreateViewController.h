//
//  InviteCreateViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>


@interface InviteCreateViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *openPartyIcon;
@property (weak, nonatomic) IBOutlet UIButton *requestPartyIcon;
@property (weak, nonatomic) IBOutlet UIButton *exclusivePartyIcon;
@property (retain, nonatomic) NSString *partyInvite;

- (IBAction)onClick:(id)sender;
- (IBAction)onScratch:(id)sender;
- (IBAction)onProceed:(id)sender;

@end
