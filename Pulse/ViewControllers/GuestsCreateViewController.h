//
//  GuestsCreateViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>


@interface GuestsCreateViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *partyNameField;
@property (weak, nonatomic) IBOutlet UITextField *partyAddressField;
@property (weak, nonatomic) IBOutlet UIButton *smallPartyIcon;
@property (weak, nonatomic) IBOutlet UIButton *mediumPartyIcon;
@property (weak, nonatomic) IBOutlet UIButton *largePartyIcon;
@property (retain, nonatomic) NSString *partyType;
@property (retain, nonatomic) NSString *partySize;

- (IBAction)onLocation:(id)sender;
- (IBAction)onClick:(id)sender;
- (IBAction)onScratch:(id)sender;
- (IBAction)onProceed:(id)sender;

@end
