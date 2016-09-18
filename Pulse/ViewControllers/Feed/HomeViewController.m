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
#import "PartyViewController.h"
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
    
    appDelegate = [AppDelegate getDelegate];
    
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
                            feedClass.senderUrl = [dictResult objectForKey:@"sender_url"];
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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [cell.feedText addGestureRecognizer:tapGesture];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    NSMutableAttributedString *feedTextAttributedString = [[NSMutableAttributedString alloc] initWithString:@"{0} {1} {2} {3}" attributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    NSAttributedString *senderAttributedString = [[NSAttributedString alloc] initWithString:feedClass.sender attributes:@{@"senderTag" : @(YES), NSForegroundColorAttributeName: [UIColor colorWithRed:171/255.0 green:14/255.0 blue:27/255.0 alpha:1.0]}];
    
    NSRange range = [feedClass.feedText rangeOfString:@" " options:NSBackwardsSearch];
    
    NSString *result = [feedClass.feedText substringToIndex:range.location];
    NSAttributedString *textAttributedString = [[NSAttributedString alloc] initWithString:result attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    NSString *result2 = [feedClass.feedText substringFromIndex:range.location+1];
    NSAttributedString *eventAttributedString = [[NSAttributedString alloc] initWithString:result2 attributes:@{@"eventTag" : @(YES), NSForegroundColorAttributeName: [UIColor colorWithRed:171/255.0 green:14/255.0 blue:27/255.0 alpha:1.0]}];
    
    NSAttributedString *extraAttributedString = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    NSRange range0 = [[feedTextAttributedString string] rangeOfString:@"{0}"];
    if(range0.location != NSNotFound)
        [feedTextAttributedString replaceCharactersInRange:range0 withAttributedString:senderAttributedString];
    
    NSRange range1 = [[feedTextAttributedString string] rangeOfString:@"{1}"];
    if(range1.location != NSNotFound)
        [feedTextAttributedString replaceCharactersInRange:range1 withAttributedString:textAttributedString];

    NSRange range2 = [[feedTextAttributedString string] rangeOfString:@"{2}"];
    if(range2.location != NSNotFound)
        [feedTextAttributedString replaceCharactersInRange:range2 withAttributedString:eventAttributedString];
    
    NSRange range3 = [[feedTextAttributedString string] rangeOfString:@"{3}"];
    if(range3.location != NSNotFound)
        [feedTextAttributedString replaceCharactersInRange:range3 withAttributedString:extraAttributedString];
    
    [feedTextAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, [feedTextAttributedString length])];
    
    cell.feedText.attributedText = feedTextAttributedString;
    
    if([feedClass.targetUrl isEqualToString:@""]){
        cell.feedText.textColor = [UIColor lightGrayColor];
    }
    [cell.userProfilePicture loadImageFromURL:feedClass.senderProfilePicture withTempImage:@"avatar_icon"];
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    
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
        id termsValue = [textView.textStorage attribute:@"senderTag" atIndex:characterIndex effectiveRange:&range0];
        id policyValue = [textView.textStorage attribute:@"eventTag" atIndex:characterIndex effectiveRange:&range1];
        
        CGPoint location = [recognizer locationInView:tblVW];
        NSIndexPath *ipath = [tblVW indexPathForRowAtPoint:location];
        FeedClass *feedClass = [arrFeed objectAtIndex:ipath.row];
        
        if(termsValue) {
            AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
            accountViewController.userURL = feedClass.senderUrl;
            accountViewController.needBack = YES;
            [self.navigationController pushViewController:accountViewController animated:YES];
            return;
        }
        
        if(policyValue) {
            if (![feedClass.targetUrl isEqualToString:@""]) {
                PartyViewController *partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
                partyViewController.partyUrl = feedClass.targetUrl;
                [self.navigationController pushViewController:partyViewController animated:YES];
            }
            return;
        }
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    FeedClass *feedClass = [arrFeed objectAtIndex:indexPath.row];
//
//    if (![feedClass.targetUrl isEqualToString:@""]){
//        PartyViewController *partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
//        partyViewController.partyUrl = feedClass.targetUrl;
//        [self.navigationController pushViewController:partyViewController animated:YES];
//    }
}

#pragma mark - Functions

-(void)showUser:(CustomButton*)sender{
    FeedClass *feedClass = [arrFeed objectAtIndex:sender.tag];
    
    AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
    accountViewController.userURL = feedClass.senderUrl;
    accountViewController.needBack = YES;
    [self.navigationController pushViewController:accountViewController animated:YES];
}

@end
