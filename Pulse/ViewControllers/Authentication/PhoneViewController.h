//
//  PhoneViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>

@interface PhoneViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (strong, nonatomic) NSString *profileName;
@property (strong, nonatomic) NSString *profileId;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

@end
