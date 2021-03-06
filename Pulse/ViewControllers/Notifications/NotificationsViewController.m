//
//  NotificationsViewController.m
//  Pulse
//


#import "AccountViewController.h"
#import "AppDelegate.h"
#import "CustomButton.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "NotificationClass.h"
#import "NotificationsViewController.h"
#import "SDIAsyncImageView.h"
#import "PartyViewController.h"
#import "TableViewCellNotification.h"


@interface NotificationsViewController (){
    AppDelegate *appDelegate;
    
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
    
    appDelegate = [AppDelegate getDelegate];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    
    [_tblVW addSubview:refreshControl];
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
    [_tblVW setContentOffset:CGPointZero animated:YES];
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
                    notificationClass.sender = [[arrNotifResult objectAtIndex:i]valueForKey:@"sender"];
                    notificationClass.senderUrl = [[arrNotifResult objectAtIndex:i]valueForKey:@"sender_url"];
                    if([[arrNotifResult objectAtIndex:i]valueForKey:@"sender_profile_picture"] == [NSNull null]){
                        notificationClass.senderProfilePicture = @"";
                    } else {
                        notificationClass.senderProfilePicture = [[arrNotifResult objectAtIndex:i]valueForKey:@"sender_profile_picture"];                    }
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
    [_tblVW reloadData];
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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [cell.notificationTextField addGestureRecognizer:tapGesture];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    
    // Without target_url
    if([notificationClass.targetUrl isEqualToString:@""]){
        NSMutableAttributedString *notifTextAttributedString = [[NSMutableAttributedString alloc] initWithString:@"{0} {1} {2} {3}" attributes:@{ NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        
        NSAttributedString *senderAttributedString = [[NSAttributedString alloc] initWithString:notificationClass.sender attributes:@{@"senderTag" : @(YES), NSForegroundColorAttributeName: [UIColor colorWithRed:171/255.0 green:14/255.0 blue:27/255.0 alpha:1.0]}];
        
        NSRange range = [notificationClass.notificationText rangeOfString:@" " options:NSBackwardsSearch];
        
        NSString *result = [notificationClass.notificationText substringToIndex:range.location];
        NSAttributedString *textAttributedString = [[NSAttributedString alloc] initWithString:result attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        
        NSString *result2 = [notificationClass.notificationText substringFromIndex:range.location+1];
        NSAttributedString *eventAttributedString = [[NSAttributedString alloc] initWithString:result2 attributes:@{@"eventTag" : @(YES), NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        
        NSAttributedString *extraAttributedString = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        
        NSRange range0 = [[notifTextAttributedString string] rangeOfString:@"{0}"];
        if(range0.location != NSNotFound)
            [notifTextAttributedString replaceCharactersInRange:range0 withAttributedString:senderAttributedString];
        
        NSRange range1 = [[notifTextAttributedString string] rangeOfString:@"{1}"];
        if(range1.location != NSNotFound)
            [notifTextAttributedString replaceCharactersInRange:range1 withAttributedString:textAttributedString];
        
        NSRange range2 = [[notifTextAttributedString string] rangeOfString:@"{2}"];
        if(range2.location != NSNotFound)
            [notifTextAttributedString replaceCharactersInRange:range2 withAttributedString:eventAttributedString];
        
        NSRange range3 = [[notifTextAttributedString string] rangeOfString:@"{3}"];
        if(range3.location != NSNotFound)
            [notifTextAttributedString replaceCharactersInRange:range3 withAttributedString:extraAttributedString];
        
        [notifTextAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, [notifTextAttributedString length])];
        
        cell.notificationTextField.attributedText = notifTextAttributedString;
    }
    // With target_url
    else {
        NSMutableAttributedString *notifTextAttributedString = [[NSMutableAttributedString alloc] initWithString:@"{0} {1} {2} {3}" attributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]}];
        
        NSAttributedString *senderAttributedString = [[NSAttributedString alloc] initWithString:notificationClass.sender attributes:@{@"senderTag" : @(YES), NSForegroundColorAttributeName: [UIColor colorWithRed:171/255.0 green:14/255.0 blue:27/255.0 alpha:1.0]}];
        
        NSRange range = [notificationClass.notificationText rangeOfString:@" " options:NSBackwardsSearch];
        
        NSString *result = [notificationClass.notificationText substringToIndex:range.location];
        NSAttributedString *textAttributedString = [[NSAttributedString alloc] initWithString:result attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        
        NSString *result2 = [notificationClass.notificationText substringFromIndex:range.location+1];
        NSAttributedString *eventAttributedString = [[NSAttributedString alloc] initWithString:result2 attributes:@{@"eventTag" : @(YES), NSForegroundColorAttributeName: [UIColor colorWithRed:171/255.0 green:14/255.0 blue:27/255.0 alpha:1.0]}];
        
        NSAttributedString *extraAttributedString = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        
        NSRange range0 = [[notifTextAttributedString string] rangeOfString:@"{0}"];
        if(range0.location != NSNotFound)
            [notifTextAttributedString replaceCharactersInRange:range0 withAttributedString:senderAttributedString];
        
        NSRange range1 = [[notifTextAttributedString string] rangeOfString:@"{1}"];
        if(range1.location != NSNotFound)
            [notifTextAttributedString replaceCharactersInRange:range1 withAttributedString:textAttributedString];
        
        NSRange range2 = [[notifTextAttributedString string] rangeOfString:@"{2}"];
        if(range2.location != NSNotFound)
            [notifTextAttributedString replaceCharactersInRange:range2 withAttributedString:eventAttributedString];
        
        NSRange range3 = [[notifTextAttributedString string] rangeOfString:@"{3}"];
        if(range3.location != NSNotFound)
            [notifTextAttributedString replaceCharactersInRange:range3 withAttributedString:extraAttributedString];
        
        [notifTextAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, [notifTextAttributedString length])];
        
        cell.notificationTextField.attributedText = notifTextAttributedString;
    }
    
    [cell.senderProfilePicture loadImageFromURL:notificationClass.senderProfilePicture withTempImage:@"avatar_icon"];
    cell.senderProfilePicture.layer.cornerRadius = cell.senderProfilePicture.frame.size.width / 2;
    cell.senderProfilePicture.layer.masksToBounds = YES;
    
    [cell.profileBtn setTag:indexPath.row];
    [cell.profileBtn addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];

    return cell;
}

-(void)didRecognizeTapGesture:(UITapGestureRecognizer *)recognizer {
    UITextView *textView = (UITextView *)recognizer.view;
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [recognizer locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < textView.textStorage.length) {
        NSRange range0;
        NSRange range1;
        id userValue = [textView.textStorage attribute:@"senderTag" atIndex:characterIndex effectiveRange:&range0];
        id eventValue = [textView.textStorage attribute:@"eventTag" atIndex:characterIndex effectiveRange:&range1];
        
        CGPoint location = [recognizer locationInView:_tblVW];
        NSIndexPath *ipath = [_tblVW indexPathForRowAtPoint:location];
        NotificationClass *notificationClass = [arrNotification objectAtIndex:ipath.row];
        
        if(userValue) {
            AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
            accountViewController.userURL = notificationClass.senderUrl;
            accountViewController.needBack = YES;
            [self.navigationController pushViewController:accountViewController animated:YES];
            return;
        }
        
        if(eventValue) {
            if (![notificationClass.targetUrl isEqualToString:@""]) {
                PartyViewController *partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
                partyViewController.partyUrl = notificationClass.targetUrl;
                [self.navigationController pushViewController:partyViewController animated:YES];
            }
            return;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NotificationClass *notificationClass = [arrNotification objectAtIndex:indexPath.row];
//    
//    if (![notificationClass.targetUrl isEqualToString:@""]){
//        PartyViewController *partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
//        partyViewController.partyUrl = notificationClass.targetUrl;
//        [self.navigationController pushViewController:partyViewController animated:YES];
//    }
}

#pragma mark - Functions

-(void)showUser:(CustomButton*)sender{
    NotificationClass *notificationClass = [arrNotification objectAtIndex:sender.tag];
    
    AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
    accountViewController.userURL = notificationClass.senderUrl;
    accountViewController.needBack = YES;
    [self.navigationController pushViewController:accountViewController animated:YES];
}

@end
