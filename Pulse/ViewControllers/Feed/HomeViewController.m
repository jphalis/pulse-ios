//
//  HomeViewController.m
//  Pulse
//


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
#import "SDIAsyncImageView.h"
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
    
    [self getFeedDetails];
    
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
    checkNetworkReachability();

    NSString *urlString = [NSString stringWithFormat:@"%@", FEEDURL];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (error != nil){
            [appDelegate hideHUDForView2:self.view];
        }
        if ([data length] > 0 && error == nil){
            [appDelegate hideHUDForView2:self.view];
            
            NSArray *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if ([JSONValue isKindOfClass:[NSNull class]]){
                [self setBusy:NO];
                showServerError();
                return;
            }
            if ([JSONValue isKindOfClass:[NSArray class]]){
                [self setBusy:NO];
                

                if ([JSONValue count] > 0){

                    if (arrFeed.count > 0){
                        [arrFeed removeAllObjects];
                    }

                    for (int i = 0; i < JSONValue.count; i++) {
                        NSMutableDictionary *dictResult;
                        dictResult = [JSONValue objectAtIndex:i];
                        FeedClass *feedClass = [[FeedClass alloc]init];
                        
                        if([dictResult objectForKey:@"sender"] == [NSNull null]){
                            feedClass.sender = @"";
                        } else {
                            feedClass.sender = [dictResult objectForKey:@"sender"];
                        }
                        if([dictResult objectForKey:@"sender_url"] == [NSNull null]){
                            feedClass.senderUrl = @"";
                        } else {
                            feedClass.senderUrl = [dictResult objectForKey:@"sender"];
                        }
                        if([dictResult objectForKey:@"sender_profile_picture"] == [NSNull null]){
                            feedClass.senderProfilePicture = @"";
                        } else {
                            feedClass.senderProfilePicture = [dictResult objectForKey:@"sender_profile_picture"];
                        }
                        if([dictResult objectForKey:@"__str__"] == [NSNull null]){
                            feedClass.feedText = @"";
                        } else {
                            feedClass.feedText = [dictResult objectForKey:@"__str__"];
                        }
                        if([dictResult objectForKey:@"target_url"] == [NSNull null]){
                            feedClass.targetUrl = @"";
                        } else {
                            feedClass.targetUrl = [dictResult objectForKey:@"target_url"];
                        }
                        if([dictResult objectForKey:@"time_since"] == [NSNull null]){
                            feedClass.time = @"";
                        } else {
                            feedClass.time = [dictResult objectForKey:@"time_since"];
                        }

                        [arrFeed addObject:feedClass];
                    }
                    [self showFeed];
                }
            }
        } else {
            [self setBusy:NO];
            [appDelegate hideHUDForView2:self.view];
            showServerError();
        }
    }];
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
    
    cell.timeLabel.text = feedClass.time;
    
    cell.feedText.text = feedClass.feedText;
    
    if([feedClass.targetUrl isEqualToString:@""]){
        cell.feedText.textColor = [UIColor lightGrayColor];
    } else {
        cell.feedText.textColor = [UIColor blackColor];
    }
    
    [cell.userProfilePicture loadImageFromURL:feedClass.senderProfilePicture withTempImage:@"avatar_icon"];
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
