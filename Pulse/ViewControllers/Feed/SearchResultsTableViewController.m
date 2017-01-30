//
//  SearchResultsTableViewController.m
//  Pulse
//

#import "AccountViewController.h"
#import "SearchResultsTableViewController.h"
#import "TableViewCellSearch.h"


@interface SearchResultsTableViewController ()

@property (nonatomic, strong) NSArray *array;

@end

@implementation SearchResultsTableViewController

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

    cell.userFullName.text = [dictUser objectForKey:@"full_name"];
    [cell.userProfilePic loadImageFromURL:[dictUser objectForKey:@"profile_pic"] withTempImage:@"avatar_icon"];
    cell.userProfilePic.layer.cornerRadius = cell.userProfilePic.frame.size.width / 2;
    cell.userProfilePic.layer.masksToBounds = YES;

    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.searchController.definesPresentationContext = YES;
    self.searchController.searchBar.hidden = YES;
    [self.searchController.searchBar resignFirstResponder];
    
    NSMutableDictionary *dictUser;
    dictUser = [_searchResults objectAtIndex:indexPath.row];

    AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
    accountViewController.userURL = [dictUser objectForKey:@"account_url"];
    accountViewController.needBack = YES;
    [self.navigationController pushViewController:accountViewController animated:YES];
    
    self.navigationController.navigationBar.hidden = YES;
}

@end
