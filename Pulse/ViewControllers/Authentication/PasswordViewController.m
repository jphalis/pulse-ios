//
//  PasswordViewController.m
//  Pulse
//

#import "CustomTabViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "PasswordViewController.h"
#import "SCLAlertView.h"
#import "SignUpViewController.h"
#import "StringUtil.h"

@interface PasswordViewController ()

@end

@implementation PasswordViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _passwordField.delegate = self;
    _confirmPasswordField.delegate = self;
    
    // Go back when swipe right
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    // Hide navigation bar
    self.navigationController.navigationBarHidden = YES;
    
    // Custom Placeholder Color
    UIColor *color = [UIColor whiteColor];
    _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    _confirmPasswordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm password" attributes:@{NSForegroundColorAttributeName: color}];
    
    // Continue button attributes
    _btnContinue.layer.borderWidth = 2;
    _btnContinue.layer.borderColor = [[UIColor whiteColor] CGColor];
    _btnContinue.layer.cornerRadius = 7;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender {
    if([self validateFields]){
        SignUpViewController *signUpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
        signUpViewController.email = _email;
        signUpViewController.first_name = _first_name;
        signUpViewController.last_name = _last_name;
        signUpViewController.password = [_passwordField.text Trim];
        [self.navigationController pushViewController:signUpViewController animated:YES];
    }
}

#pragma mark - Functions

-(BOOL)validateFields{
    [self.view endEditing:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([_passwordField.text isEqualToString:@""] || _passwordField.text == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PASSWORD closeButtonTitle:@"OK" duration:0.0f];
        [alert alertIsDismissed:^{
            [_passwordField becomeFirstResponder];
        }];
        return NO;
    }
    else if ([_confirmPasswordField.text isEqualToString:@""] || _confirmPasswordField.text == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PASSWORD closeButtonTitle:@"OK" duration:0.0f];
        [alert alertIsDismissed:^{
            [_confirmPasswordField becomeFirstResponder];
        }];
        return NO;
    }
    else if (_passwordField.text != _confirmPasswordField.text){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:@"Your passwords do not match." closeButtonTitle:@"OK" duration:0.0f];
        [alert alertIsDismissed:^{
            [_passwordField becomeFirstResponder];
        }];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField: textField up: YES];
    
    if(textField == _passwordField){
        _passwordField.placeholder = nil;
    }
    else if (textField == _confirmPasswordField){
        _confirmPasswordField.placeholder = nil;
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField: textField up: NO];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0){
        [_confirmPasswordField becomeFirstResponder];
    }
    else if(textField.tag == 1){
        [_confirmPasswordField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
