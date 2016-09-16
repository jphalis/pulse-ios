//
//  InviteCreateViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "GuestsCreateViewController.h"
#import "InviteCreateViewController.h"
#import "SCLAlertView.h"
#import "UIViewControllerAdditions.h"


@interface InviteCreateViewController () <UIActionSheetDelegate> {
    AppDelegate *appDelegate;
}

- (IBAction)onClick:(id)sender;

enum{
    BTNOPEN = 0,
    BTNREQUEST,
    BTNEXCLUSIVE,
};

@end

@implementation InviteCreateViewController

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

- (IBAction)onClick:(id)sender {
    switch ([sender tag]) {
        case BTNOPEN:{
            _openPartyIcon.layer.borderWidth = 3;
            _openPartyIcon.layer.borderColor = [[UIColor greenColor] CGColor];
            _openPartyIcon.layer.cornerRadius = _openPartyIcon.frame.size.width / 2;
            _partyInvite = @"15";
            
            _requestPartyIcon.layer.borderWidth = 0;
            _exclusivePartyIcon.layer.borderWidth = 0;
            break;
        }
        case BTNEXCLUSIVE:{
            _exclusivePartyIcon.layer.borderWidth = 3;
            _exclusivePartyIcon.layer.borderColor = [[UIColor greenColor] CGColor];
            _exclusivePartyIcon.layer.cornerRadius = _exclusivePartyIcon.frame.size.width / 2;
            _partyInvite = @"16";
            
            _openPartyIcon.layer.borderWidth = 0;
            _requestPartyIcon.layer.borderWidth = 0;
            break;
        }
        case BTNREQUEST:{
            _requestPartyIcon.layer.borderWidth = 3;
            _requestPartyIcon.layer.borderColor = [[UIColor greenColor] CGColor];
            _requestPartyIcon.layer.cornerRadius = _requestPartyIcon.frame.size.width / 2;
            _partyInvite = @"17";
            
            _openPartyIcon.layer.borderWidth = 0;
            _exclusivePartyIcon.layer.borderWidth = 0;
            break;
        }
        default: {
            break;
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
    if (!_partyInvite){
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:@"Please select an invitation type" closeButtonTitle:@"OK" duration:0.0f];
    } else {
        GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
        guestsCreateViewController.partyType = _partyType;
        guestsCreateViewController.partyInvite = _partyInvite;
        [self.navigationController pushViewController:guestsCreateViewController animated:YES];
    }
}

@end
