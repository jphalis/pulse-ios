//
//  ForgotViewController.m
//  Pulse
//

#import "defs.h"
#import "ForgotViewController.h"
#import "GlobalFunctions.h"
#import "SCLAlertView.h"
#import "StringUtil.h"

@interface ForgotViewController ()

@end

@implementation ForgotViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _emailField.delegate = self;
    
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
    _emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    
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
        checkNetworkReachability();
        [self.view endEditing:YES];
        [self setBusy:YES];
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *params = [NSString stringWithFormat:@"email=%@",[_emailField.text Trim]];
            NSMutableData *bodyData = [[NSMutableData alloc] initWithData:[params dataUsingEncoding:NSUTF8StringEncoding]];
            NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", FORGOTPASS]];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setTimeoutInterval:60];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            [urlRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
            [urlRequest setHTTPBody:bodyData];
            
            [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([data length] > 0 && error == nil){
                        NSDictionary * JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                        
                        if([JSONValue isKindOfClass:[NSDictionary class]]){
                            
                            if([[JSONValue objectForKey:@"success"]isEqualToString:@"Password reset e-mail has been sent."]){
                                [self setBusy:NO];
                                alert.showAnimationType = SlideInFromLeft;
                                alert.hideAnimationType = SlideOutToBottom;
                                [alert showEdit:self title:@"Notice" subTitle:@"Please check your email to reset your password." closeButtonTitle:@"OK" duration:0.0f];
                                [alert alertIsDismissed:^{
                                    [self.navigationController popViewControllerAnimated:YES];
                                }];
                            } else {
                                [self setBusy:NO];
                                alert.showAnimationType = SlideInFromLeft;
                                alert.hideAnimationType = SlideOutToBottom;
                                [alert showNotice:self title:@"Notice" subTitle:@"That email does not exist." closeButtonTitle:@"OK" duration:0.0f];
                            }
                            _emailField.text = @"";
                        } else {
                            [self setBusy:NO];
                            showServerError();
                        }
                    } else {
                        [self setBusy:NO];
                        showServerError();
                    }
                });
            }];
        });
    }
}

#pragma mark - Functions

-(BOOL)validateFields{
    [self.view endEditing:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];

    if ([_emailField.text isEqualToString:@""] || _emailField.text == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_EMAIL closeButtonTitle:@"OK" duration:0.0f];
        [alert alertIsDismissed:^{
            [_emailField becomeFirstResponder];
        }];
        return NO;
    }
    else if ([AppDelegate validateEmail:[_emailField.text Trim]] == NO){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showEdit:self title:@"Notice" subTitle:INVALID_EMAIL closeButtonTitle:@"OK" duration:0.0f];
        [alert alertIsDismissed:^{
            [_emailField becomeFirstResponder];
        }];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField: textField up: YES];
    _emailField.placeholder = nil;
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
        [_emailField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
