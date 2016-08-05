//
//  GuestsCreateViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "DateCreateViewController.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "GuestsCreateViewController.h"
#import "UIViewControllerAdditions.h"

#import "SCLAlertView.h"


@interface GuestsCreateViewController () <UIActionSheetDelegate> {
    AppDelegate *appDelegate;
}

- (IBAction)onClick:(id)sender;

enum{
    BTNSMALL = 0,
    BTNMED,
    BTNLARGE,
};

@end

@implementation GuestsCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
    
    _partyNameField.delegate = self;
    _partyAddressField.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    [super viewWillAppear:YES];
    
    // partyNameField attributes
    _partyNameField.layer.cornerRadius = 7;
    
    // partyAddressField attributes
    _partyAddressField.layer.cornerRadius = 7;
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

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField: textField up: YES];
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
        [_partyAddressField becomeFirstResponder];
    }
    else if(textField.tag == 1){
        [_partyAddressField resignFirstResponder];
    }
    return YES;
}

- (BOOL)checkParty{
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([_partyNameField.text isEqualToString:@""]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PARTY_NAME closeButtonTitle:@"OK" duration:0.0f];
        [alert alertIsDismissed:^{
            [_partyNameField becomeFirstResponder];
        }];
        return NO;
    }
    if ([_partyAddressField.text isEqualToString:@""]){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_PARTY_ADDRESS closeButtonTitle:@"OK" duration:0.0f];
        [alert alertIsDismissed:^{
            [_partyAddressField becomeFirstResponder];
        }];
        return NO;
    }
    return YES;
}

- (IBAction)onLocation:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showInfo:self title:@"Notice" subTitle:@"Current location will be rendered here." closeButtonTitle:@"OK" duration:0.0f];
}

- (IBAction)onClick:(id)sender {
    
    if ([self checkParty] == 1){
    
        switch ([sender tag]) {
            case BTNSMALL:{
                _smallPartyIcon.layer.borderWidth = 3;
                _smallPartyIcon.layer.borderColor = [[UIColor greenColor] CGColor];
                _smallPartyIcon.layer.cornerRadius = _smallPartyIcon.frame.size.width / 2;
                _partySize = @"1-25";
                
                _mediumPartyIcon.layer.borderWidth = 0;
                _largePartyIcon.layer.borderWidth = 0;
                break;
            }
            case BTNMED:{
                _mediumPartyIcon.layer.borderWidth = 3;
                _mediumPartyIcon.layer.borderColor = [[UIColor greenColor] CGColor];
                _mediumPartyIcon.layer.cornerRadius = _mediumPartyIcon.frame.size.width / 2;
                _partySize = @"25-100";
                
                _smallPartyIcon.layer.borderWidth = 0;
                _largePartyIcon.layer.borderWidth = 0;
                break;
            }
            case BTNLARGE:{
                _largePartyIcon.layer.borderWidth = 3;
                _largePartyIcon.layer.borderColor = [[UIColor greenColor] CGColor];
                _largePartyIcon.layer.cornerRadius = _largePartyIcon.frame.size.width / 2;
                _partySize = @"100+";
                
                _smallPartyIcon.layer.borderWidth = 0;
                _mediumPartyIcon.layer.borderWidth = 0;
                break;
            }
            default: {
                break;
            }
        }
    }
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
    DateCreateViewController *dateCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DateCreateViewController"];
    dateCreateViewController.partyInvite = _partyInvite;
    dateCreateViewController.partyType = _partyType;
    dateCreateViewController.partyName = _partyNameField.text;
    dateCreateViewController.partyAddress = _partyAddressField.text;
    dateCreateViewController.partySize = _partySize;
    [self.navigationController pushViewController:dateCreateViewController animated:YES];
}

@end
