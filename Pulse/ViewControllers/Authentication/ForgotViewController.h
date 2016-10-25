//
//  ForgotViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>

@interface ForgotViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

@end
