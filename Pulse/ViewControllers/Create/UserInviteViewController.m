//
//  UserInviteViewController.m
//


#import "AppDelegate.h"
#import "defs.h"
#import "InviteCreateViewController.h"
#import "SDIAsyncImageView.h"
#import "TableViewCellInvite.h"
#import "UserInviteViewController.h"


@interface UserInviteViewController ()
{
    AppDelegate *appDelegate;
    InviteCreateViewController *inviteCreateViewController;
    NSMutableArray *myArray;
}

@end

@implementation UserInviteViewController

@synthesize arrDetails;

- (void)viewDidLoad
{
    appDelegate = [AppDelegate getDelegate];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    inviteCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteCreateViewController"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    // Hide navigation bar
    self.navigationController.navigationBarHidden = YES;
    
    myArray = [[NSMutableArray alloc] init];
    
    [_tblVW reloadData];
}

- (void)didReceiveMemoryWarning
{
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrDetails count];    //count number of row from counting array hear catagory is An Array
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCellInvite *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteCell" forIndexPath:indexPath];
    
    NSMutableDictionary *dictUser = [arrDetails objectAtIndex:indexPath.row];
    
    [cell.userProfilePicture loadImageFromURL:[dictUser objectForKey:@"user__profile_pic"] withTempImage:@"avatar_icon"];
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    cell.userName.text = [dictUser objectForKey:@"user__full_name"];
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
    if ([myArray indexOfObject:cell.textLabel.text] != NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictUser = [arrDetails objectAtIndex:indexPath.row];
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
//    if ([myArray containsObject:[NSString stringWithString:newCell.textLabel.text]]) {
//        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
    
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [myArray addObject:dictUser];
        _editInvitedUsers(myArray.mutableCopy);
    }
    else
    {
        newCell.accessoryType = UITableViewCellAccessoryNone;
        [myArray removeObject:dictUser];
        _editInvitedUsers(myArray.mutableCopy);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

#pragma mark - Functions

- (IBAction)onDone:(id)sender
{
    [self.view removeFromSuperview];
}
@end