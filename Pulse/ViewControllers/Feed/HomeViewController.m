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
#import "SCLAlertView.h"
#import "SDIAsyncImageView.h"
#import "SearchResultsTableViewController.h"
#import "TableViewCellFeed.h"
#import "UIViewControllerAdditions.h"


@interface HomeViewController (){
    AppDelegate *appDelegate;
    UIRefreshControl *refreshControl;
    int lastCount;
    BOOL isFiltered;
    BOOL isEmpty;
}

- (IBAction)onSearch:(id)sender;

@end

@implementation HomeViewController
@synthesize arrFeed, arrUsers, arrFilteredUsers;

- (void)viewDidLoad {
    arrFeed = [[NSMutableArray alloc]init];
    arrUsers = [[NSMutableArray alloc]init];
    arrFilteredUsers = [[NSArray alloc]init];
    
    [self initializeSearchController];

    [self getFeedDetails];
    
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
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
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

- (void)initializeSearchController {
    
    // There's no transition in our storyboard to our search results tableview or navigation controller
    // so we'll have to grab it using the instantiateViewControllerWithIdentifier: method
    UINavigationController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TableSearchResultsNavController"];
    
    // Our instance of UISearchController will use searchResults
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    
    // The searchcontroller's searchResultsUpdater property will contain our tableView.
    self.searchController.searchResultsUpdater = self;
    
    // The searchBar contained in XCode's storyboard is a leftover from UISearchDisplayController.
    // Don't use this. Instead, we'll create the searchBar programatically.
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x,
                                                       self.searchController.searchBar.frame.origin.y,
                                                       self.searchController.searchBar.frame.size.width, 44.0);
    
    self.searchController.searchBar.placeholder = @"Search for user";
    self.searchController.searchBar.barStyle = UIBarStyleBlackTranslucent;
    self.searchController.searchBar.barTintColor = [UIColor clearColor];
    
    //add the UISearchController's search bar to the header of this table
    _tblVW.tableHeaderView = self.searchController.searchBar;
    
    
    //this view controller can be covered by theUISearchController's view (i.e. search/filter table)
    self.definesPresentationContext = YES;
    
    //this ViewController will be responsible for implementing UISearchResultsDialog protocol method(s) - so handling what happens when user types into the search bar
    self.searchController.searchResultsUpdater = self;
    
    //this ViewController will be responsisble for implementing UISearchBarDelegate protocol methods(s)
    self.searchController.searchBar.delegate = self;
    
    [self.searchController.searchBar sizeToFit];
    self.searchController.dimsBackgroundDuringPresentation = YES;
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
                    _lblWaterMark.hidden = YES;

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
                } else {
                    _lblWaterMark.hidden = NO;
                }
            }
        } else {
            [appDelegate hideHUDForView2:self.view];
            showServerError();
        }
        [self setBusy:NO];
        [self showFeed];
    }];
}

-(void)showFeed{
    [_tblVW reloadData];
    [refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrFeed count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCellFeed *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCellFeed" forIndexPath:indexPath];
    
    if (arrFeed.count <= 0){
        return cell;
    }
    
    FeedClass *feedClass = [arrFeed objectAtIndex:indexPath.row];
    
    cell.timeLabel.text = feedClass.time;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [cell.feedText addGestureRecognizer:tapGesture];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    NSMutableAttributedString *feedTextAttributedString = [[NSMutableAttributedString alloc] initWithString:@"{0} {1} {2} {3} {4}" attributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    NSString *senderText;
//    NSString *article;
    
    if ([feedClass.sender isEqualToString:GetUserName]) {
        senderText = @"You";
//        article = @"are";
    } else {
        senderText = feedClass.sender;
//        article = @"is";
    }
    NSString *article = @"will be";
    
    NSAttributedString *senderAttributedString = [[NSAttributedString alloc] initWithString:senderText attributes:@{@"senderTag" : @(YES), NSForegroundColorAttributeName: [UIColor colorWithRed:171/255.0 green:14/255.0 blue:27/255.0 alpha:1.0]}];
    
    NSAttributedString *articleAttributedString = [[NSAttributedString alloc] initWithString:article attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    NSRange range = [feedClass.feedText rangeOfString:@" " options:NSBackwardsSearch];
    
    NSString *result = [feedClass.feedText substringToIndex:range.location];
    NSAttributedString *textAttributedString = [[NSAttributedString alloc] initWithString:result attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    NSString *result2 = [feedClass.feedText substringFromIndex:range.location+1];
    NSAttributedString *eventAttributedString = [[NSAttributedString alloc] initWithString:result2 attributes:@{@"eventTag" : @(YES), NSForegroundColorAttributeName: [UIColor colorWithRed:171/255.0 green:14/255.0 blue:27/255.0 alpha:1.0]}];
    
    NSAttributedString *extraAttributedString = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    NSRange range0 = [[feedTextAttributedString string] rangeOfString:@"{0}"];
    if (range0.location != NSNotFound)
        [feedTextAttributedString replaceCharactersInRange:range0 withAttributedString:senderAttributedString];
    
    NSRange range1 = [[feedTextAttributedString string] rangeOfString:@"{1}"];
    if (range1.location != NSNotFound)
        [feedTextAttributedString replaceCharactersInRange:range1 withAttributedString:articleAttributedString];
    
    NSRange range2 = [[feedTextAttributedString string] rangeOfString:@"{2}"];
    if (range2.location != NSNotFound)
        [feedTextAttributedString replaceCharactersInRange:range2 withAttributedString:textAttributedString];
    
    NSRange range3 = [[feedTextAttributedString string] rangeOfString:@"{3}"];
    if (range3.location != NSNotFound)
        [feedTextAttributedString replaceCharactersInRange:range3 withAttributedString:eventAttributedString];
    
    NSRange range4 = [[feedTextAttributedString string] rangeOfString:@"{4}"];
    if (range4.location != NSNotFound)
        [feedTextAttributedString replaceCharactersInRange:range4 withAttributedString:extraAttributedString];
    
    [feedTextAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, [feedTextAttributedString length])];
    
    cell.feedText.attributedText = feedTextAttributedString;
    
    if ([feedClass.targetUrl isEqualToString:@""]){
        cell.feedText.textColor = [UIColor lightGrayColor];
    }
    else if ([feedClass.sender isEqualToString:GetUserName]) {
        cell.feedText.font = [UIFont boldSystemFontOfSize:12];
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
        id userValue = [textView.textStorage attribute:@"senderTag" atIndex:characterIndex effectiveRange:&range0];
        id eventValue = [textView.textStorage attribute:@"eventTag" atIndex:characterIndex effectiveRange:&range1];
        
        CGPoint location = [recognizer locationInView:_tblVW];
        NSIndexPath *ipath = [_tblVW indexPathForRowAtPoint:location];
        FeedClass *feedClass = [arrFeed objectAtIndex:ipath.row];
        
        if(userValue) {
            AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
            accountViewController.userURL = feedClass.senderUrl;
            accountViewController.needBack = YES;
            [self.navigationController pushViewController:accountViewController animated:YES];
            return;
        }
        
        if(eventValue) {
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

#pragma mark - Search

// Called when the search bar becomes first responder
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    searchController.searchResultsController.view.hidden = NO;
    
    UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
    
    // Present SearchResultsTableViewController as the topViewController
    SearchResultsTableViewController *vc = (SearchResultsTableViewController *)navController.topViewController;
    
    vc.searchController = _searchController;
    
    NSString *searchText = self.searchController.searchBar.text;
    
    if([searchText length] == 0 || searchText == nil){
        isFiltered = NO;
        if(arrUsers.count > 0){
            [arrUsers removeAllObjects];
        }
        isEmpty = NO;
        vc.lblWaterMark.text = @"Search Pulse";
        vc.searchResults = nil;
        [vc.tableView reloadData];
    } else {
        if(searchText.length == 1){
            [self performSelector:@selector(doSearch) withObject:searchText afterDelay:0.3f];
        } else {
            [self doFilter];
        }
    }
}

- (IBAction)onSearch:(id)sender {
    if([self validateFields]){
        isEmpty = NO;
        [self doSearch];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(BOOL)validateFields{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if([_searchController.searchBar.text isEqualToString:@""] || _searchController.searchBar.text == nil){
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_SEARCH closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    return YES;
}

-(void)doSearch{
    checkNetworkReachability();
    
    if(isEmpty == YES){
        return;
    }
    
    UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
    
    // Present SearchResultsTableViewController as the topViewController
    SearchResultsTableViewController *vc = (SearchResultsTableViewController *)navController.topViewController;
    
    [self setBusy:YES];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SEARCH_URL, self.searchController.searchBar.text];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
        
        if (error == nil && [data length] > 0){
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                NSArray *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                if([JSONValue isKindOfClass:[NSNull class]]){
                    [self setBusy:NO];
                    showServerError();
                    return;
                }
                if([JSONValue isKindOfClass:[NSArray class]]){
                    
                    if( arrUsers.count > 0){
                        [arrUsers removeAllObjects];
                    }
                    
                    if([JSONValue count] > 0){
                        for (int i = 0; i < JSONValue.count; i++) {
                            
                            NSMutableDictionary *dictResult;
                            dictResult = [JSONValue objectAtIndex:i];
                            NSMutableDictionary *dictSearch = [[NSMutableDictionary alloc]init];
                            
                            if([dictResult objectForKey:@"id"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"id"];
                            } else {
                                [dictSearch setValue:[dictResult objectForKey:@"id"] forKey:@"id"];
                            }
                            if([dictResult objectForKey:@"account_url"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"account_url"];
                            } else {
                                [dictSearch setValue:[dictResult objectForKey:@"account_url"] forKey:@"account_url"];
                            }
                            if([dictResult objectForKey:@"full_name"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"full_name"];
                            } else {
                                [dictSearch setValue:[dictResult objectForKey:@"full_name"] forKey:@"full_name"];
                            }
                            if([dictResult objectForKey:@"profile_pic"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"profile_pic"];
                            } else {
                                [dictSearch setValue:[dictResult objectForKey:@"profile_pic"] forKey:@"profile_pic"];
                            }
                            
                            [arrUsers addObject:dictSearch];
                        }
                        
                        lastCount = (int)[_searchController.searchBar.text length];
                        vc.lblWaterMark.text = @"";
                        [self showUsers];
                    } else {
                        isEmpty = YES;
                        vc.lblWaterMark.text = @"0 results found";
                        [self showUsers];
                    }
                } else {
                    showServerError();
                }
            });
        }
    });
    [self setBusy:NO];
}

-(void)showUsers{
    UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
    
    // Present SearchResultsTableViewController as the topViewController
    SearchResultsTableViewController *vc = (SearchResultsTableViewController *)navController.topViewController;
    
    vc.searchController = _searchController;
    
    if([_searchController.searchBar.text length] == 0){
        if(arrUsers.count > 0){
            [arrUsers removeAllObjects];
        }
        vc.lblWaterMark.text = @"";
    }
    [self doFilter];
}

-(void)doFilter{
    UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;

    // Present SearchResultsTableViewController as the topViewController
    SearchResultsTableViewController *vc = (SearchResultsTableViewController *)navController.topViewController;
    
    vc.searchController = _searchController;
    
    isFiltered = YES;
    arrFilteredUsers = nil;
    NSString *searchString = _searchController.searchBar.text;
    
    if([searchString length] == 0){
        if(arrUsers.count > 0){
            [arrUsers removeAllObjects];
        }
        isEmpty = NO;
        vc.lblWaterMark.text = @"";
        [vc.tableView reloadData];
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"full_name beginswith[c] %@", searchString];
    arrFilteredUsers = [arrUsers filteredArrayUsingPredicate:predicate];

    // Update searchResults
    vc.searchResults = arrFilteredUsers;
    
    if(arrFilteredUsers.count > 0){
        vc.lblWaterMark.text = @"";
    } else {
        vc.lblWaterMark.text = @"0 results found";
    }

    [vc.tableView reloadData];
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
