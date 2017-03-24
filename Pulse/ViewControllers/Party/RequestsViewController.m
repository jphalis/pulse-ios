//
//  RequestsViewController.m
//


#import "AccountViewController.h"
#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "ProfileClass.h"
#import "RequestsViewController.h"
#import "SCLAlertView.h"
#import "SDIAsyncImageView.h"
#import "TableViewCellRequests.h"
#import "TWMessageBarManager.h"


@interface RequestsViewController () {
    AppDelegate *appDelegate;
}

- (IBAction)onBack:(id)sender;

@end

@implementation RequestsViewController

@synthesize arrDetails;

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    // Hide navigation bar
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrDetails count];    //count number of row from counting array hear catagory is An Array
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCellRequests *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestCell" forIndexPath:indexPath];
    
    NSMutableDictionary *dictUser = [arrDetails objectAtIndex:indexPath.row];
    
    [cell.userProfilePicture loadImageFromURL:[dictUser objectForKey:@"user__profile_pic"] withTempImage:@"avatar_icon"];
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    cell.userName.text = [dictUser objectForKey:@"user__full_name"];
    
    [cell.approveBtn addTarget:self action:@selector(approveUser:) forControlEvents:UIControlEventTouchUpInside];
    [cell.approveBtn setTag: indexPath.row];
    [cell.denyBtn addTarget:self action:@selector(denyUser:) forControlEvents:UIControlEventTouchUpInside];
    [cell.denyBtn setTag: indexPath.row];
    
    [[cell.approveBtn imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [[cell.denyBtn imageView] setContentMode: UIViewContentModeScaleAspectFit];
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
    return cell;
}

-(IBAction)approveUser:(UIButton *)sender {
    checkNetworkReachability();
    [self setBusy:YES];
    
    NSInteger row = sender.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    NSMutableDictionary *dictUser = [arrDetails objectAtIndex:indexPath.row];

    NSString *strURL = [NSString stringWithFormat:@"%@%@/%@/", PARTYACCEPTURL, _partyId, [dictUser objectForKey:@"user__id"]];
    NSURL *url = [NSURL URLWithString:strURL];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60];
    [urlRequest setHTTPMethod:@"POST"];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        
        if ([data length] > 0 && error == nil) {
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

            if(JSONValue != nil) {
                
                if([[JSONValue allKeys]count] > 1) {
                    BOOL lastRow = FALSE;
                    if ([_tblVW numberOfRowsInSection:[indexPath section]] == 1 ) {
                        lastRow = TRUE;
                    }
                    [arrDetails removeObjectAtIndex:indexPath.row];
                    [_tblVW beginUpdates];
                    
                    [_tblVW deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

                    if (lastRow) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    [_tblVW endUpdates];
                    [_tblVW reloadData];
                    
                    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Success"
                                                                   description:APPROVE_USER
                                                                          type:TWMessageBarMessageTypeSuccess
                                                                      duration:2.0];
                }
            }
        } else {
            showServerError();
        }
        [self setBusy:NO];
    }];
}

-(IBAction)denyUser:(UIButton *)sender {
    checkNetworkReachability();
    [self setBusy:YES];
    
    NSInteger row = sender.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    NSMutableDictionary *dictUser = [arrDetails objectAtIndex:indexPath.row];
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@/%@/", PARTYDENYURL, _partyId, [dictUser objectForKey:@"user__id"]];
    NSURL *url = [NSURL URLWithString:strURL];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60];
    [urlRequest setHTTPMethod:@"POST"];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         if ([data length] > 0 && error == nil) {
             NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             
             if(JSONValue != nil) {
                 
                 if([[JSONValue allKeys]count] > 1) {
                     BOOL lastRow = FALSE;
                     if ([_tblVW numberOfRowsInSection:[indexPath section]] == 1 ) {
                         lastRow = TRUE;
                     }
                     [arrDetails removeObjectAtIndex:indexPath.row];
                     [_tblVW beginUpdates];
                     
                     [_tblVW deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                     
                     if (lastRow) {
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                     [_tblVW endUpdates];
                     [_tblVW reloadData];
                     
                     [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Success"
                                                                    description:DENY_USER
                                                                           type:TWMessageBarMessageTypeInfo
                                                                       duration:2.0];
                 }
             }
         } else {
             showServerError();
         }
         [self setBusy:NO];
     }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dictUser = [arrDetails objectAtIndex:indexPath.row];
    
    AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
    accountViewController.userURL = [NSString stringWithFormat:@"%@%@/", PROFILEURL, [dictUser objectForKey:@"user__id"]];
    accountViewController.needBack = YES;
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

@end
