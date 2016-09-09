//
//  PasswordViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>

@interface PasswordViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) NSString *email;
@property (retain, nonatomic) NSString *first_name;
@property (retain, nonatomic) NSString *last_name;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

@end
