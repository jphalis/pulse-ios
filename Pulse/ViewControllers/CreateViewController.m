//
//  CreateViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
//#import "GuestsCreateViewController.h"
#import "CreateViewController.h"
#import "UIViewControllerAdditions.h"

#import "SCLAlertView.h"


@interface CreateViewController (){
    AppDelegate *appDelegate;
}

- (IBAction)onClick:(id)sender;

enum{
    BTNCUSTOM = 1,
    BTNSOCIAL,
    BTNHOLIDAY,
    BTNEVENT,
    BTNRAGER,
    BTNTHEMED,
    BTNCELEBRATION,
};

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Show the tabbar
    appDelegate.tabbar.tabView.hidden = NO;
    
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

- (IBAction)onClick:(id)sender {
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    switch ([sender tag]) {
        case BTNCUSTOM:{
            alert.showAnimationType = SlideInFromLeft;
            alert.hideAnimationType = SlideOutToBottom;
            [alert showInfo:self title:@"Notice" subTitle:@"Party type: Custom" closeButtonTitle:@"OK" duration:0.0f];
            
//            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
//            guestsCreateViewController.partyType = @"Holiday";
//            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNSOCIAL:{
            alert.showAnimationType = SlideInFromLeft;
            alert.hideAnimationType = SlideOutToBottom;
            [alert showInfo:self title:@"Notice" subTitle:@"Party type: Social" closeButtonTitle:@"OK" duration:0.0f];
            
//            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
//            guestsCreateViewController.partyType = @"Social";
//            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNHOLIDAY:{
            alert.showAnimationType = SlideInFromLeft;
            alert.hideAnimationType = SlideOutToBottom;
            [alert showInfo:self title:@"Notice" subTitle:@"Party type: Holiday" closeButtonTitle:@"OK" duration:0.0f];
            

//            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
//            guestsCreateViewController.partyType = @"Holiday";
//            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNEVENT:{
            alert.showAnimationType = SlideInFromLeft;
            alert.hideAnimationType = SlideOutToBottom;
            [alert showInfo:self title:@"Notice" subTitle:@"Party type: Event" closeButtonTitle:@"OK" duration:0.0f];
            

//            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
//            guestsCreateViewController.partyType = @"Event";
//            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNRAGER:{
            alert.showAnimationType = SlideInFromLeft;
            alert.hideAnimationType = SlideOutToBottom;
            [alert showInfo:self title:@"Notice" subTitle:@"Party type: Rager" closeButtonTitle:@"OK" duration:0.0f];
            

//            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
//            guestsCreateViewController.partyType = @"Rager";
//            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNTHEMED:{
            alert.showAnimationType = SlideInFromLeft;
            alert.hideAnimationType = SlideOutToBottom;
            [alert showInfo:self title:@"Notice" subTitle:@"Party type: Themed" closeButtonTitle:@"OK" duration:0.0f];
            

//            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
//            guestsCreateViewController.partyType = @"Themed";
//            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNCELEBRATION:{
            alert.showAnimationType = SlideInFromLeft;
            alert.hideAnimationType = SlideOutToBottom;
            [alert showInfo:self title:@"Notice" subTitle:@"Party type: Celebration" closeButtonTitle:@"OK" duration:0.0f];
            

//            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
//            guestsCreateViewController.partyType = @"Celebration";
//            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        default: {
            break;
        }
    }
}

@end
