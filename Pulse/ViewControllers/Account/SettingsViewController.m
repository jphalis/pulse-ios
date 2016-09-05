//
//  SettingsViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "defs.h"
#import "SettingsViewController.h"
#import "SCLAlertView.h"
#import "SVModalWebViewController.h"


@interface SettingsViewController (){
    AppDelegate *appDelegate;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = [AppDelegate getDelegate];
    
    // Go back when swipe right
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
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

- (IBAction)onNotifications:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showNotice:self title:@"Notice" subTitle:@"Trigger notifications" closeButtonTitle:@"OK" duration:0.0f];
}

- (IBAction)onTerms:(id)sender {
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:TERMSURL];
    [self presentViewController:webViewController animated:YES completion:NULL];
}

- (IBAction)onPrivacy:(id)sender {
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:PRIVACYURL];
    [self presentViewController:webViewController animated:YES completion:NULL];
}

- (IBAction)onCredits:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showNotice:self title:@"Notice" subTitle:@"View credits" closeButtonTitle:@"OK" duration:0.0f];
}

- (IBAction)onLinkAccounts:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showNotice:self title:@"Notice" subTitle:@"Link accounts" closeButtonTitle:@"OK" duration:0.0f];
}

- (IBAction)onSignOut:(id)sender {
    [appDelegate userLogout];
}

@end
