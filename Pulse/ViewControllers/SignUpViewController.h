//
//  SignUpViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

@end
