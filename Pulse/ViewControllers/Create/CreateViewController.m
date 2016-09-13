//
//  CreateViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "InviteCreateViewController.h"
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
            InviteCreateViewController *inviteCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteCreateViewController"];
            inviteCreateViewController.partyType = @"Custom";
            [self.navigationController pushViewController:inviteCreateViewController animated:YES];
            break;
        }
        case BTNSOCIAL:{
            InviteCreateViewController *inviteCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteCreateViewController"];
            inviteCreateViewController.partyType = @"Social";
            [self.navigationController pushViewController:inviteCreateViewController animated:YES];
            break;
        }
        case BTNHOLIDAY:{
            InviteCreateViewController *inviteCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteCreateViewController"];
            inviteCreateViewController.partyType = @"Holiday";
            [self.navigationController pushViewController:inviteCreateViewController animated:YES];
            break;
        }
        case BTNEVENT:{
            InviteCreateViewController *inviteCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteCreateViewController"];
            inviteCreateViewController.partyType = @"Event";
            [self.navigationController pushViewController:inviteCreateViewController animated:YES];
            break;
        }
        case BTNRAGER:{
            InviteCreateViewController *inviteCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteCreateViewController"];
            inviteCreateViewController.partyType = @"Rager";
            [self.navigationController pushViewController:inviteCreateViewController animated:YES];
            break;
        }
        case BTNTHEMED:{
            InviteCreateViewController *inviteCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteCreateViewController"];
            inviteCreateViewController.partyType = @"Themed";
            [self.navigationController pushViewController:inviteCreateViewController animated:YES];
            break;
        }
        case BTNCELEBRATION:{
            InviteCreateViewController *inviteCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteCreateViewController"];
            inviteCreateViewController.partyType = @"Celebration";
            [self.navigationController pushViewController:inviteCreateViewController animated:YES];
            break;
        }
        default: {
            break;
        }
    }
}

@end
