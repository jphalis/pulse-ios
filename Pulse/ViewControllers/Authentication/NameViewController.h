//
//  NameViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>

@interface NameViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) NSString *email;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

@end
