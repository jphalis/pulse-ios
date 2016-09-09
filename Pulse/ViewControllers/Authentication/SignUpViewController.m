//
//  SignUpViewController.m
//  Pulse
//

#import "CustomTabViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "SCLAlertView.h"
#import "SignUpViewController.h"
#import "StringUtil.h"

@interface SignUpViewController () {
    BOOL acceptedTerms;
}

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Go back when swipe right
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    acceptedTerms = NO;
    
    // Hide navigation bar
    self.navigationController.navigationBarHidden = YES;
    
    // Checkbox
    [_acceptField addTarget:self action:@selector(toggleButton:) forControlEvents: UIControlEventTouchUpInside];
    
    // Done button attributes
    _btnSignUp.layer.borderWidth = 2;
    _btnSignUp.layer.borderColor = [[UIColor whiteColor] CGColor];
    _btnSignUp.layer.cornerRadius = 7;
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
    if (acceptedTerms)
    {
        [self doSubmit];
    }
    else
    {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:@"Please accept the terms." closeButtonTitle:@"OK" duration:0.0f];
    }
}

#pragma mark - Functions

- (void)toggleButton:(id)sender
{
    UIButton *tappedButton = (UIButton*)sender;

    if([tappedButton.currentImage isEqual:[UIImage imageNamed:@"unchecked_icon"]])
    {
        [sender setImage:[UIImage imageNamed: @"checked_icon"] forState:UIControlStateNormal];
        acceptedTerms = YES;
    }
    else
    {
        [sender setImage:[UIImage imageNamed: @"unchecked_icon"] forState:UIControlStateNormal];
        acceptedTerms = NO;
        
    }
}

-(void)doSubmit{
    checkNetworkReachability();
    [self.view endEditing:YES];
    [self setBusy:YES];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    NSString *full_name = [NSString stringWithFormat:@"%@ %@", _first_name, _last_name];
    
    NSString *params = [NSString stringWithFormat:@"{\"full_name\":\"%@\",\"email\":\"%@\",\"password\":\"%@\"}",full_name, _email, _password];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[params length]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", SIGNUPURL]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"" forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if ([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(JSONValue != nil){
                if([[JSONValue objectForKey:@"email"] isKindOfClass:[NSString class]]){
                    SetUserID([[JSONValue objectForKey:@"id"]integerValue]);
                    SetUserName(full_name);
                    SetUserEmail(_email);
                    SetUserPassword(_password);
                    CustomTabViewController *customTabViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomTabViewController"];
                    [self.navigationController pushViewController:customTabViewController animated:YES];
                } else {
                    alert.showAnimationType = SlideInFromLeft;
                    alert.hideAnimationType = SlideOutToBottom;
                    [alert showNotice:self title:@"Notice" subTitle:EMAIL_EXISTS closeButtonTitle:@"OK" duration:0.0f];
                }
            }
        } else {
            showServerError();
        }
        [self setBusy:NO];
    }];
}

@end
