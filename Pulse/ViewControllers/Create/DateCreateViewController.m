//
//  DateCreateViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "DateCreateViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "PreviewViewController.h"
#import "SCLAlertView.h"
#import "UIViewControllerAdditions.h"


@interface DateCreateViewController () <UIActionSheetDelegate> {
    AppDelegate *appDelegate;
}

@end

@implementation DateCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
    
    _dateField.delegate = self;
    _startTimeField.delegate = self;
    _endTimeField.delegate = self;
    _descriptionField.delegate = self;
    
    // Date picker
    _datePickerView = [[UIDatePicker alloc] init];
    [_datePickerView setMinimumDate:[NSDate date]];
    [_datePickerView setMaximumDate:[[NSDate date] dateByAddingTimeInterval:60*60*24*7]];
    _datePickerView.datePickerMode = UIDatePickerModeDate;
    [_datePickerView addTarget:self action:@selector(updateDateLabel:)
               forControlEvents:UIControlEventValueChanged];
    [_dateField setInputView:_datePickerView];
    
    // Start time picker
    _startPickerView = [[UIDatePicker alloc] init];
    _startPickerView.datePickerMode = UIDatePickerModeTime; // UIDatePickerModeDateAndTime
    _startPickerView.minuteInterval = 30;
    [_startPickerView addTarget:self action:@selector(updateStartTimeLabel:)
              forControlEvents:UIControlEventValueChanged];
    [_startTimeField setInputView:_startPickerView];
    
    // End time picker
    _endPickerView = [[UIDatePicker alloc] init];
    _endPickerView.datePickerMode = UIDatePickerModeTime; // UIDatePickerModeDateAndTime
    _endPickerView.minuteInterval = 30;
    [_endPickerView addTarget:self action:@selector(updateEndTimeLabel:)
               forControlEvents:UIControlEventValueChanged];
    [_endTimeField setInputView:_endPickerView];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    [super viewWillAppear:YES];
    
    // Field attributes
    _dateField.layer.cornerRadius = 7;
    _startTimeField.layer.cornerRadius = 7;
    _endTimeField.layer.cornerRadius = 7;
    _descriptionField.layer.cornerRadius = 7;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Picker views

-(void)updateDateLabel:(UIDatePicker *)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"LLLL dd, YYYY"];
    _dateField.text = [dateFormatter stringFromDate:_datePickerView.date];
    
    NSString *dateString = [dateFormatter stringFromDate:_datePickerView.date];
    NSArray *components = [dateString componentsSeparatedByString:@" "];
    NSDateFormatter *monthFormatter =[[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MM"];
    NSDate *aDate = [monthFormatter dateFromString:components[0]];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:aDate];

    NSString *month = [NSString stringWithFormat:@"%ld", [components2 month]];
    NSString *day = [[components[1] stringByReplacingOccurrencesOfString:@"," withString:@""]
                               stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    NSString *year = components[2];
    
    _partyMonth = month;
    _partyDay = day;
    _partyYear = year;
}

-(void)updateStartTimeLabel:(UIDatePicker *)sender {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    _startTimeField.text = [timeFormatter stringFromDate:_startPickerView.date];
}

-(void)updateEndTimeLabel:(UIDatePicker *)sender {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    _endTimeField.text = [timeFormatter stringFromDate:_endPickerView.date];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_dateField resignFirstResponder];
    [_startTimeField resignFirstResponder];
    [_endTimeField resignFirstResponder];
}

#pragma mark - Functions

-(BOOL)ValidateFields{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([_dateField.text isEqualToString:@""] || _dateField.text == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_MONTH closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    else if ([_startTimeField.text isEqualToString:@""] || _startTimeField.text == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_START_TIME closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    else if ([_endTimeField.text isEqualToString:@""] || _endTimeField.text == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_END_TIME closeButtonTitle:@"OK" duration:0.0f];
    }
    return  YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    NSUInteger length = [textView.text length] - range.length + [text length];
    if(textView == _descriptionField){
        _descriptionTextCount.text = [NSString stringWithFormat:@"%lu/500", (unsigned long)length];
        return length <= 500;
    }
    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField: textField up: NO];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self animateTextView:textView up: YES];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self animateTextView:textView up: NO];
}

- (void)animateTextField:(UITextField*)textField up: (BOOL) up{
    float val;
    
    if(self.view.frame.size.height == 480){
        val = 0.75;
    } else {
        val = 0.65;
    }
    
    const int movementDistance = val * textField.frame.origin.y;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}

- (void)animateTextView:(UITextView*)textView up: (BOOL) up{
    float val;
    
    if(self.view.frame.size.height == 480){
        val = 0.75;
    } else {
        val = 0.65;
    }
    
    const int movementDistance = val * textView.frame.origin.y;

    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag == 1){
        [_dateField becomeFirstResponder];
    }
    else if(textField.tag == 2){
        [_endTimeField becomeFirstResponder];
    }
    else if(textField.tag == 3){
        [_endTimeField resignFirstResponder];
    }
    return YES;
}

- (IBAction)onPrevious:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onScratch:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Are you sure you want to scratch this party?"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Yes", @"No", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        return;
    }
}

- (IBAction)onProceed:(id)sender {
    if([self ValidateFields]){
        PreviewViewController *previewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PreviewViewController"];
        previewViewController.partyInvite = _partyInvite;
        previewViewController.partyType = _partyType;
        previewViewController.partyName = _partyName;
        previewViewController.partyAddress = _partyAddress;
        previewViewController.partyLatitude = _partyLatitude;
        previewViewController.partyLongitude = _partyLongitude;
        previewViewController.partySize = _partySize;
        previewViewController.partyMonth = _partyMonth;
        previewViewController.partyDay = _partyDay;
        
//        //Get current year
//        NSDate *currentYear = [[NSDate alloc]init];
//        currentYear = [NSDate date];
//        NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
//        [formatter1 setDateFormat:@"yyyy"];
//        NSString *currentYearString = [formatter1 stringFromDate:currentYear];
//        previewViewController.partyYear = currentYearString;
        previewViewController.partyYear = _partyYear;

        previewViewController.partyStartTime = _startTimeField.text;
        previewViewController.partyEndTime = _endTimeField.text;
        previewViewController.partyDescription = _descriptionField.text;
        [self.navigationController pushViewController:previewViewController animated:YES];
    }
}

@end
