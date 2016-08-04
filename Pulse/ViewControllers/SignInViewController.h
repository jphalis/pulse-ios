//
//  SignInViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

@end
