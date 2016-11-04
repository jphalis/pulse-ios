//
//  PhoneViewController.m
//  Pulse
//

#import "defs.h"
#import "PhoneViewController.h"
#import "GlobalFunctions.h"
#import "PhoneViewController.h"
#import "SCLAlertView.h"
#import "StringUtil.h"

@interface PhoneViewController ()

@end

@implementation PhoneViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _phoneField.delegate = self;
    
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
    _phoneField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"(XXX) XXX-XXXX" attributes:@{NSForegroundColorAttributeName: color}];
    
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
        [self updatePhone];
    }
}

#pragma mark - Functions

-(BOOL)validateFields{
    [self.view endEditing:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];

    if ([_phoneField.text isEqualToString:@""] || _phoneField.text == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:@"Please enter your phone number" closeButtonTitle:@"OK" duration:0.0f];
        [alert alertIsDismissed:^{
            [_phoneField becomeFirstResponder];
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
    
    if(textField == _phoneField){
        BOOL isValidChar = [AppDelegate isValidCharacter:string filterCharSet:NUMBERS];
        return isValidChar && length <= 10;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField: textField up: YES];
    _phoneField.placeholder = nil;
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
        [_phoneField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)updatePhone {
    checkNetworkReachability();
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    NSString *params = [NSString stringWithFormat:@"full_name=%@&email=%@&phone_number=%@", _profileName, GetUserEmail, _phoneField.text];
    
    NSMutableData *bodyData = [[NSMutableData alloc] initWithData:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/", PROFILEURL, _profileId];
    NSURL *requestURL = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:requestURL];
    [urlRequest setTimeoutInterval:60];
    [urlRequest setHTTPMethod:@"PUT"];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
    [urlRequest setHTTPBody:bodyData];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if ([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if(JSONValue != nil){
                SetUserPhone([JSONValue objectForKey:@"phone_number"]);
                alert.showAnimationType = SlideInFromLeft;
                alert.hideAnimationType = SlideOutToBottom;
                [alert showNotice:self title:@"Notice" subTitle:@"Your profile has been verified." closeButtonTitle:@"OK" duration:0.0f];
                [alert alertIsDismissed:^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
            }
        } else {
            showServerError();
        }
        [self setBusy:NO];
    }];
}

@end
