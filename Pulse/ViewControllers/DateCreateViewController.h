//
//  DateCreateViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>


@interface DateCreateViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *monthField;
@property (weak, nonatomic) IBOutlet UITextField *dayField;
@property (strong, nonatomic) UIDatePicker *startPickerView;
@property (strong, nonatomic) UIDatePicker *endPickerView;
@property (weak, nonatomic) IBOutlet UITextField *startTimeField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTextCount;
@property (retain, nonatomic) NSString *partyType;
@property (retain, nonatomic) NSString *partyName;
@property (retain, nonatomic) NSString *partyAddress;
@property (retain, nonatomic) NSString *partySize;

- (IBAction)onProceed:(id)sender;
- (IBAction)onScratch:(id)sender;
- (IBAction)onPrevious:(id)sender;

@end
