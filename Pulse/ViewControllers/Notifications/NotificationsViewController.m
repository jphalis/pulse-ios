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
#import "SDIAsyncImageView.h"
#import "PartyViewController.h"
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
    [self getNotificationDetails:NOTIFURL];
    
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    
    [tblVW addSubview:refreshControl];
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
    if(arrNotification.count > 0){
        [arrNotification removeAllObjects];
    }
    
    [self getNotificationDetails:NOTIFURL];
}

-(void)getNotificationDetails:(NSString *)requestURL{
    checkNetworkReachability();
    [self setBusy:NO];

    NSString *urlString = [NSString stringWithFormat:@"%@", requestURL];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){

        if([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]]){
                notificationCount = [[JSONValue objectForKey:@"count"]integerValue];
                NSArray *arrNotifResult = [JSONValue objectForKey:@"results"];
                
                if(notificationCount > 0){
                    _lblWaterMark.hidden = YES;
                } else {
                    _lblWaterMark.hidden = NO;
                }
                for (int i = 0; i < arrNotifResult.count; i++) {
                    NotificationClass *notificationClass = [[NotificationClass alloc]init];
                    int userId = [[[arrNotifResult objectAtIndex:i]valueForKey:@"id"]intValue];
                    notificationClass.objectId = [NSString stringWithFormat:@"%d", userId];
                    notificationClass.senderUrl = [[arrNotifResult objectAtIndex:i]valueForKey:@"sender_url"];
                    if([[arrNotifResult objectAtIndex:i]valueForKey:@"sender_profile_picture"] == [NSNull null]){
                        notificationClass.senderProfilePicture = @"";
                    } else {
                        NSString *str = [[arrNotifResult objectAtIndex:i]valueForKey:@"sender_profile_picture"];
                        notificationClass.senderProfilePicture = [NSString stringWithFormat:@"https://oby.s3.amazonaws.com/media/%@", str];
                    }
                    notificationClass.notificationText = [[arrNotifResult objectAtIndex:i]valueForKey:@"__str__"];
                    if([[arrNotifResult objectAtIndex:i]valueForKey:@"target_url"] != [NSNull null]){
                        notificationClass.targetUrl = [[arrNotifResult objectAtIndex:i]valueForKey:@"target_url"];
                    } else {
                        notificationClass.targetUrl = @"";
                    }
                    [arrNotification addObject:notificationClass];
                }
                [self showNotifications];
            }
        } else {
            showServerError();
        }
    }];
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
    
    [cell.senderProfilePicture loadImageFromURL:notificationClass.senderProfilePicture withTempImage:@"avatar_icon"];
    cell.senderProfilePicture.layer.cornerRadius = cell.senderProfilePicture.frame.size.width / 2;
    cell.senderProfilePicture.layer.masksToBounds = YES;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationClass *notificationClass = [arrNotification objectAtIndex:indexPath.row];
    
    if (![notificationClass.targetUrl isEqualToString:@""]){
        PartyViewController *partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
        partyViewController.partyUrl = notificationClass.targetUrl;
        [self.navigationController pushViewController:partyViewController animated:YES];
    }
}

@end
