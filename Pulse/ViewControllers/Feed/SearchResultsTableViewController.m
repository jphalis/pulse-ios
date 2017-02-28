//
//  SearchResultsTableViewController.m
//  Pulse
//

#import "AccountViewController.h"
#import "SearchResultsTableViewController.h"
#import "TableViewCellSearch.h"
#import "UserInviteViewController.h"


@interface SearchResultsTableViewController () {
    UserInviteViewController *userInviteViewController;
}

@property (nonatomic, strong) NSArray *array;

@end

@implementation SearchResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    userInviteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserInviteViewController"];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.searchController.searchBar.hidden = NO;
    [self.searchController.searchBar becomeFirstResponder];
    [super viewWillAppear:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCellSearch *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell" forIndexPath:indexPath];

    NSMutableDictionary *dictUser;

    dictUser = [_searchResults objectAtIndex:indexPath.row];

    cell.userFullName.text = [dictUser objectForKey:@"user__full_name"];
    [cell.userProfilePic loadImageFromURL:[dictUser objectForKey:@"user__profile_pic"] withTempImage:@"avatar_icon"];
    cell.userProfilePic.layer.cornerRadius = cell.userProfilePic.frame.size.width / 2;
    cell.userProfilePic.layer.masksToBounds = YES;

    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.searchController.definesPresentationContext = YES;
    [self.searchController.searchBar resignFirstResponder];
    self.navigationController.navigationBar.hidden = YES;
    
    NSMutableDictionary *dictUser = [_searchResults objectAtIndex:indexPath.row];
    
    if (_isInviteSearch) {
        NSMutableArray *myArray = [[NSMutableArray alloc] init];
        [myArray addObject:dictUser];
        _editInvitedUsers(myArray.mutableCopy);
        self.searchController.active = NO;
    } else {
        AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
        accountViewController.userURL = [dictUser objectForKey:@"user__account_url"];
        accountViewController.needBack = YES;
        [self.navigationController pushViewController:accountViewController animated:YES];
        self.searchController.searchBar.hidden = YES;
    }
}

@end
