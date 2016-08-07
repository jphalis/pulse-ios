//
//  NotificationsViewController.m
//  Pulse
//


#import <QuartzCore/QuartzCore.h>

#import "AccountViewController.h"
#import "AnimatedMethods.h"
#import "AppDelegate.h"
#import "CustomButton.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "NotificationClass.h"
#import "NotificationsViewController.h"
#import "SCLAlertView.h"
//#import "SingleNotificationViewController.h"
#import "TableViewCellNotification.h"
#import "UIViewControllerAdditions.h"


@interface NotificationsViewController (){
    AppDelegate *appDelegate;
    
    __weak IBOutlet UITableView *tblVW;
    
    NSInteger notificationCount;
    NSMutableArray *arrNotification;
    UIRefreshControl *refreshControl;
}

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    arrNotification = [[NSMutableArray alloc]init];
    
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    
    [tblVW addSubview:refreshControl];
    
    [self getNotificationDetails];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Show the tabbar
    appDelegate.tabbar.tabView.hidden = NO;
    
    [super viewWillAppear:YES];
    
    if(arrNotification.count > 0){
        [self scrollToTop];
    }
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

-(void)scrollToTop{
    [tblVW setContentOffset:CGPointZero animated:YES];
}

-(void)startRefresh{
    [self getNotificationDetails];
}

-(void)getNotificationDetails {
    NotificationClass *notificationClass = [[NotificationClass alloc]init];
    notificationClass.notificationCount = @"18";
    notificationClass.results = [NSMutableArray arrayWithObject:@""];
    notificationClass.senderUrl = @"";
    notificationClass.senderProfilePicture = @"";
    notificationClass.objectId = @"3";
    notificationClass.notificationText = @"Here's a sample notification.";
    notificationClass.recipient = @"myself";
    notificationClass.targetUrl = @"";
    [arrNotification addObject:notificationClass];
    [self showNotifications];
}

-(void)showNotifications{
    [refreshControl endRefreshing];
    [tblVW reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;    //count of section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrNotification count];    //count number of row from counting array hear cataGorry is An Array
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TableViewCellNotification *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCellNotification" forIndexPath:indexPath];
    
    if(arrNotification.count <= 0){
        return cell;
    }
    
    NotificationClass *notificationClass = [arrNotification objectAtIndex:indexPath.row];
    
    cell.notificationTextField.text = notificationClass.notificationText;
    
    if([notificationClass.targetUrl isEqualToString:@""]){
        cell.notificationTextField.textColor = [UIColor lightGrayColor];
    } else {
        cell.notificationTextField.textColor = [UIColor blackColor];
    }
    
    if ([notificationClass.senderProfilePicture isEqual: @""]){
//        cell.senderProfilePicture = @"avatar.png";
    } else {
//        cell.senderProfilePicture = notificationClass.senderProfilePicture;
    }
    cell.senderProfilePicture.layer.cornerRadius = cell.senderProfilePicture.frame.size.width / 2;
    cell.senderProfilePicture.layer.masksToBounds = YES;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationClass *notificationClass = [arrNotification objectAtIndex:indexPath.row];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showNotice:self title:@"Notice" subTitle:@"Load individual notification." closeButtonTitle:@"OK" duration:0.0f];
    
//    if([notificationClass.targetUrl isEqualToString:@""]){
//        return;
//    } else {
//        SingleNotificationViewController *singleNotificationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleNotificationViewController"];
//        singleNotificationViewController.singleNotificationUrl = notificationClass.targetUrl;
//        [self.navigationController pushViewController:singleNotificationViewController animated:YES];
//    }
}

@end
