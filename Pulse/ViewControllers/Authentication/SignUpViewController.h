//
//  SignUpViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *acceptField;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (retain, nonatomic) NSString *email;
@property (retain, nonatomic) NSString *first_name;
@property (retain, nonatomic) NSString *last_name;
@property (retain, nonatomic) NSString *password;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

@end
