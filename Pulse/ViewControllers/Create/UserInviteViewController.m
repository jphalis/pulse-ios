//
//  UserInviteViewController.m
//


#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "InviteCreateViewController.h"
#import "SCLAlertView.h"
#import "SDIAsyncImageView.h"
#import "SearchResultsTableViewController.h"
#import "TableViewCellInvite.h"
#import "UserInviteViewController.h"


@interface UserInviteViewController () {
    AppDelegate *appDelegate;
    InviteCreateViewController *inviteCreateViewController;
    NSMutableArray *selectedRows;
    int lastCount;
    BOOL isFiltered;
    BOOL isEmpty;
}

@end

@implementation UserInviteViewController

@synthesize arrDetails, arrUsers, arrFilteredUsers, myArray;

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    [self initializeSearchController];
    
    arrUsers = [[NSMutableArray alloc] init];
    arrFilteredUsers = [[NSArray alloc] init];
    myArray = [[NSMutableArray alloc] init];
    selectedRows = [[NSMutableArray alloc] init];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    inviteCreateViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteCreateViewController"];
    UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
    SearchResultsTableViewController *vc = (SearchResultsTableViewController *)navController.topViewController;
    
    vc.editInvitedUsers = ^(NSMutableArray *response) {
        myArray = response;
        
        for (int i = 0; i < myArray.count; i++) {
            NSString *user_id = [NSString stringWithFormat:@"%@", [[myArray objectAtIndex:i] objectForKey:@"user__id"]];
            
            if ( !([[selectedRows valueForKey:@"user__id"] containsObject:user_id]) ) {
                [selectedRows addObject:[myArray objectAtIndex:i]];
            }

            if ( !([[arrDetails valueForKey:@"user__id"] containsObject:user_id]) ) {
                [arrDetails insertObject:[myArray objectAtIndex:i] atIndex:0];
            }
        }
        
        [_tblVW reloadData];
    };
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    // Hide navigation bar
    self.navigationController.navigationBarHidden = YES;
    
    [_tblVW reloadData];
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

#pragma mark - Search

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

// Called when the search bar becomes first responder
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    searchController.searchResultsController.view.hidden = NO;
    
    UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
    
    // Present SearchResultsTableViewController as the topViewController
    SearchResultsTableViewController *vc = (SearchResultsTableViewController *)navController.topViewController;
    
    vc.searchController = _searchController;
    
    NSString *searchText = self.searchController.searchBar.text;
    
    if ([searchText length] == 0 || searchText == nil){
        isFiltered = NO;
        if (arrUsers.count > 0){
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

-(BOOL)validateFields{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    if ([_searchController.searchBar.text isEqualToString:@""] || _searchController.searchBar.text == nil) {
        alert.showAnimationType = SlideInFromLeft;
        alert.hideAnimationType = SlideOutToBottom;
        [alert showNotice:self title:@"Notice" subTitle:EMPTY_SEARCH closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    return YES;
}

- (IBAction)onSearch:(id)sender {
    if ([self validateFields]) {
        isEmpty = NO;
        [self doSearch];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)doSearch{
    checkNetworkReachability();
    
    if (isEmpty == YES){
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
                
                if ([JSONValue isKindOfClass:[NSNull class]]){
                    [self setBusy:NO];
                    showServerError();
                    return;
                }
                if ([JSONValue isKindOfClass:[NSArray class]]){
                    
                    if (arrUsers.count > 0){
                        [arrUsers removeAllObjects];
                    }
                    
                    if([JSONValue count] > 0){
                        for (int i = 0; i < JSONValue.count; i++) {
                            
                            NSMutableDictionary *dictResult;
                            dictResult = [JSONValue objectAtIndex:i];
                            NSMutableDictionary *dictSearch = [[NSMutableDictionary alloc]init];
                            
                            if([dictResult objectForKey:@"id"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"user__id"];
                            } else {
                                NSString *user_id = [NSString stringWithFormat:@"%@", [dictResult objectForKey:@"id"]];
                                [dictSearch setValue:user_id forKey:@"user__id"];
                            }
                            if([dictResult objectForKey:@"account_url"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"user__account_url"];
                            } else {
                                [dictSearch setValue:[dictResult objectForKey:@"account_url"] forKey:@"user__account_url"];
                            }
                            if([dictResult objectForKey:@"full_name"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"user__full_name"];
                            } else {
                                [dictSearch setValue:[dictResult objectForKey:@"full_name"] forKey:@"user__full_name"];
                            }
                            if([dictResult objectForKey:@"profile_pic"] == [NSNull null]){
                                [dictSearch setValue:@"" forKey:@"user__profile_pic"];
                            } else {
                                [dictSearch setValue:[dictResult objectForKey:@"profile_pic"] forKey:@"user__profile_pic"];
                            }
                            
                            [arrUsers addObject:dictSearch];
                        }
                        
                        lastCount = (int)[_searchController.searchBar.text length];
                        vc.lblWaterMark.text = @"";
                        [self showUsers];
                    } else {
                        isEmpty = YES;
                        vc.lblWaterMark.text = @"0 results found";
                    }
                } else {
                    showServerError();
                }
            });
        }
    });
    [self setBusy:NO];
}

-(void)showUsers {
    UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
    
    // Present SearchResultsTableViewController as the topViewController
    SearchResultsTableViewController *vc = (SearchResultsTableViewController *)navController.topViewController;
    
    vc.searchController = _searchController;
    
    if ([_searchController.searchBar.text length] == 0) {
        if (arrUsers.count > 0) {
            [arrUsers removeAllObjects];
        }
        vc.lblWaterMark.text = @"";
    }
    [self doFilter];
}

-(void)doFilter {
    UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
    
    // Present SearchResultsTableViewController as the topViewController
    SearchResultsTableViewController *vc = (SearchResultsTableViewController *)navController.topViewController;
    
    vc.searchController = _searchController;
    
    isFiltered = YES;
    arrFilteredUsers = nil;
    NSString *searchString = _searchController.searchBar.text;
    
    if ([searchString length] == 0) {
        if (arrUsers.count > 0) {
            [arrUsers removeAllObjects];
        }
        isEmpty = NO;
        vc.lblWaterMark.text = @"";
        [vc.tableView reloadData];
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user__full_name beginswith[c] %@", searchString];
    arrFilteredUsers = [arrUsers filteredArrayUsingPredicate:predicate];
    
    // Update searchResults
    vc.searchResults = arrFilteredUsers;
    vc.isInviteSearch = YES;
    
    if (arrFilteredUsers.count > 0){
        vc.lblWaterMark.text = @"";
    } else {
        vc.lblWaterMark.text = @"0 results found";
    }
    
    [vc.tableView reloadData];
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrDetails count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCellInvite *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteCell" forIndexPath:indexPath];
    
    NSMutableDictionary *dictUser = [arrDetails objectAtIndex:indexPath.row];
    
    [cell.userProfilePicture loadImageFromURL:[dictUser objectForKey:@"user__profile_pic"] withTempImage:@"avatar_icon"];
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    cell.userName.text = [dictUser objectForKey:@"user__full_name"];
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];

    cell.accessoryType = ([self isRowSelectedOnTableView:tableView atIndexPath:indexPath]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    if ([[selectedRows valueForKey:@"user__id"] containsObject:[dictUser objectForKey:@"user__id"]] || [[selectedRows valueForKey:@"user__id"] containsObject:[NSNumber numberWithInteger:[[dictUser objectForKey:@"user__id"] integerValue]]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dictUser = [arrDetails objectAtIndex:indexPath.row];
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedRows addObject:dictUser];
        [myArray addObject:dictUser];
    } else {
        newCell.accessoryType = UITableViewCellAccessoryNone;
        [selectedRows removeObject:dictUser];
        [myArray removeObject:dictUser];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

#pragma mark - Functions

-(BOOL)isRowSelectedOnTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    return ([selectedRows containsObject:indexPath]) ? YES : NO;
}

- (IBAction)onAll:(id)sender {
    NSUInteger numberOfSections = [_tblVW numberOfSections];
    for (NSUInteger s = 0; s < numberOfSections; ++s) {
        NSUInteger numberOfRowsInSection = [_tblVW numberOfRowsInSection:s];
        
        for (NSUInteger r = 0; r < numberOfRowsInSection; ++r) {
            // NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:s];
            NSMutableDictionary *dictUser = [arrDetails objectAtIndex:r];
            if (![myArray containsObject:dictUser]) {
                [myArray addObject:dictUser];
            }
            if (![selectedRows containsObject:dictUser]) {
                [selectedRows addObject:dictUser];
            }
            _editInvitedUsers(myArray.mutableCopy);
        }
    }
    [_tblVW reloadData];
}

- (IBAction)onDone:(id)sender {
    _editInvitedUsers(selectedRows.mutableCopy);
    NSLog(@"selected: %@", selectedRows);
    [myArray removeAllObjects];
    [selectedRows removeAllObjects];
    [self.view removeFromSuperview];
}

@end
