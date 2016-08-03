//
//  SignInViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

@end
