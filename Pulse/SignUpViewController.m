//
//  SignUpViewController.m
//  Pulse
//

//#import "CustomTabViewController.h"
#import "defs.h"
#import "SCLAlertView.h"
#import "SignUpViewController.h"
#import "StringUtil.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _nameField.delegate = self;
    _emailField.delegate = self;
    _passwordField.delegate = self;
    
    // Go back when swipe right
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    // Hide navigation bar
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender {
    if([self validateFields]){
        [self doSubmit];
    }
}

#pragma mark - Functions

-(BOOL)validateFields{
    [self.view endEditing:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([_nameField.text isEqualToString:@""] || _nameField.text == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_NAME closeButtonTitle:@"OK" duration:0.0f];
        [_nameField becomeFirstResponder];
        return NO;
    }
    else if ([_emailField.text isEqualToString:@""] || _emailField.text == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_EMAIL closeButtonTitle:@"OK" duration:0.0f];
        [_emailField becomeFirstResponder];
        return NO;
    }
    else if ([AppDelegate validateEmail:[_emailField.text Trim]] == NO){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showEdit:self title:@"Notice" subTitle:INVALID_EMAIL closeButtonTitle:@"OK" duration:0.0f];
        [_emailField becomeFirstResponder];
        return NO;
    }
    else if ([_passwordField.text isEqualToString:@""] || _passwordField.text == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PASSWORD closeButtonTitle:@"OK" duration:0.0f];
        [_passwordField becomeFirstResponder];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger length = [textField.text length] - range.length + [string length];
    
    if(textField == _emailField){
        _emailField.text = _emailField.text.lowercaseString;
        BOOL isValidChar = [AppDelegate isValidCharacter:string filterCharSet:EMAIL];
        return isValidChar && length <= 60;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0){
        [_emailField becomeFirstResponder];
    }
    else if(textField.tag == 1){
        [_passwordField becomeFirstResponder];
    }
    else if(textField.tag == 2){
        [_passwordField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag != 2){
        [self animateTextField: textField up: YES];
    }
    else {
        self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)animateTextField: (UITextField*) textField up:(BOOL) up{
    float val = 0.21;
    
    const int movementDistance = val * textField.frame.origin.y;
    const float movementDuration = 0.3f;
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)doSubmit{
    [self.view endEditing:YES];
    SetUserName([_nameField.text Trim]);
    SetUserEmail([_emailField.text Trim]);
    SetUserPassword([_passwordField.text Trim]);
    
    // Temporary alert until home screen is put in
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showInfo:self title:@"Success" subTitle:@"This is where a redirect will occur to the home screen." closeButtonTitle:@"OK" duration:0.0f];
    
    //    CustomTabViewController *customTabViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomTabViewController"];
    //    [self.navigationController pushViewController:customTabViewController animated:animation];
}

@end
