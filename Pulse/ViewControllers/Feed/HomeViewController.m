//
//  HomeViewController.m
//  Pulse
//



#import "HomeViewController.h"
#import "UIViewControllerAdditions.h"

#import <QuartzCore/QuartzCore.h>

#import "AccountViewController.h"
#import "AnimatedMethods.h"
#import "AppDelegate.h"
#import "CustomButton.h"
#import "defs.h"
#import "FeedClass.h"
#import "GlobalFunctions.h"
#import "HomeViewController.h"
#import "SCLAlertView.h"
#import "TableViewCellFeed.h"
#import "UIViewControllerAdditions.h"


@interface HomeViewController (){
    AppDelegate *appDelegate;
    
    __weak IBOutlet UITableView *tblVW;
    
    NSMutableArray *arrFeed;
    UIRefreshControl *refreshControl;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    arrFeed = [[NSMutableArray alloc]init];
    
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    
    [tblVW addSubview:refreshControl];
    
    [self getFeedDetails];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Show the tabbar
    appDelegate.tabbar.tabView.hidden = NO;
    
    [super viewWillAppear:YES];
    
    if(arrFeed.count > 0){
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
    if(arrFeed.count > 0){
        [arrFeed removeAllObjects];
    }
    
    [self getFeedDetails];
}

-(void)getFeedDetails {
    FeedClass *feedClass = [[FeedClass alloc]init];
    feedClass.results = [NSMutableArray arrayWithObject:@""];
    feedClass.ownerUrl = @"";
    feedClass.ownerProfilePicture = @"";
    feedClass.objectId = @"3";
    feedClass.feedText = @"Here's a sample feed item.";
    feedClass.time = @"18m";
    feedClass.targetUrl = @"";
    [arrFeed addObject:feedClass];
    [self showFeed];
}

-(void)showFeed{
    [refreshControl endRefreshing];
    [tblVW reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;    //count of section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrFeed count];    //count number of row from counting array hear cataGorry is An Array
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TableViewCellFeed *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCellFeed" forIndexPath:indexPath];
    
    if(arrFeed.count <= 0){
        return cell;
    }
    
    FeedClass *feedClass = [arrFeed objectAtIndex:indexPath.row];
    
    cell.feedText.text = feedClass.feedText;
    
    if([feedClass.targetUrl isEqualToString:@""]){
        cell.feedText.textColor = [UIColor lightGrayColor];
    } else {
        cell.feedText.textColor = [UIColor blackColor];
    }
    
    if ([feedClass.ownerProfilePicture isEqual: @""]){
        //        cell.senderProfilePicture = @"avatar.png";
    } else {
        //        cell.senderProfilePicture = notificationClass.senderProfilePicture;
    }
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NotificationClass *notificationClass = [arrNotification objectAtIndex:indexPath.row];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showInfo:self title:@"Notice" subTitle:@"Load individual feed item." closeButtonTitle:@"OK" duration:0.0f];
    
    //    if([notificationClass.targetUrl isEqualToString:@""]){
    //        return;
    //    } else {
    //        SingleNotificationViewController *singleNotificationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleNotificationViewController"];
    //        singleNotificationViewController.singleNotificationUrl = notificationClass.targetUrl;
    //        [self.navigationController pushViewController:singleNotificationViewController animated:YES];
    //    }
}

@end
