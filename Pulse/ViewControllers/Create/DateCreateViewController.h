//
//  DateCreateViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>


@interface DateCreateViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) UIDatePicker *startPickerView;
@property (strong, nonatomic) UIDatePicker *endPickerView;
@property (weak, nonatomic) IBOutlet UITextField *startTimeField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTextCount;
@property (retain, nonatomic) NSString *partyInvite;
@property (retain, nonatomic) NSString *usersInvited;
@property (retain, nonatomic) NSString *partyType;
@property (retain, nonatomic) NSString *partyName;
@property (retain, nonatomic) NSString *partyAddress;
@property (retain, nonatomic) NSString *partySize;
@property (retain, nonatomic) NSString *partyLatitude;
@property (retain, nonatomic) NSString *partyLongitude;
@property (retain, nonatomic) NSString *partyMonth;
@property (retain, nonatomic) NSString *partyDay;
@property (retain, nonatomic) NSString *partyYear;

- (IBAction)onPrevious:(id)sender;
- (IBAction)onScratch:(id)sender;
- (IBAction)onProceed:(id)sender;

@end
