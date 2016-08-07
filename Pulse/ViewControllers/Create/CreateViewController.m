//
//  CreateViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "GuestsCreateViewController.h"
#import "CreateViewController.h"
#import "UIViewControllerAdditions.h"


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
    
    switch ([sender tag]) {
        case BTNCUSTOM:{
            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
            guestsCreateViewController.partyType = @"Custom";
            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNSOCIAL:{
            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
            guestsCreateViewController.partyType = @"Social";
            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNHOLIDAY:{
            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
            guestsCreateViewController.partyType = @"Holiday";
            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNEVENT:{
            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
            guestsCreateViewController.partyType = @"Event";
            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNRAGER:{
            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
            guestsCreateViewController.partyType = @"Rager";
            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNTHEMED:{
            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
            guestsCreateViewController.partyType = @"Themed";
            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        case BTNCELEBRATION:{
            GuestsCreateViewController *guestsCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuestsCreateViewController"];
            guestsCreateViewController.partyType = @"Celebration";
            [self.navigationController pushViewController:guestsCreateViewController animated:YES];
            break;
        }
        default: {
            break;
        }
    }
}

@end
