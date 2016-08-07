//
//  PreviewViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "PreviewViewController.h"
#import "SCLAlertView.h"
#import "UIViewControllerAdditions.h"


@interface PreviewViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    [super viewWillAppear:YES];
    
    _partyImageField.layer.borderWidth = 4;
    _partyImageField.layer.borderColor = [[UIColor whiteColor] CGColor];
    _partyImageField.layer.cornerRadius = 10;
    _partyImageField.layer.masksToBounds = YES;
    
    _partyNameField.text = _partyName;
    
    NSInteger monthNumber = [_partyMonth integerValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(monthNumber-1)];
    _partyDateTimeField.text = [NSString stringWithFormat:@"%@ %@, 2016  %@-%@", monthName, _partyDay, _partyStartTime, _partyEndTime];
    
    _partyAddressField.text = _partyAddress;
    
    _partyDescriptionField.text = _partyDescription;
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

#pragma mark - Functions

- (IBAction)addImage:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showInfo:self title:@"Notice" subTitle:@"Add image here." closeButtonTitle:@"OK" duration:0.0f];
}

- (IBAction)onPrevious:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onProceed:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showInfo:self title:@"Notice" subTitle:@"Your party will be created now." closeButtonTitle:@"OK" duration:0.0f];
    [alert alertIsDismissed:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

@end
