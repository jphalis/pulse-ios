//
//  FollowViewController.m
//


#import "AccountViewController.h"
#import "AppDelegate.h"
#import "defs.h"
#import "FollowViewController.h"
#import "GlobalFunctions.h"
#import "ProfileClass.h"
#import "SCLAlertView.h"
#import "SDIAsyncImageView.h"
#import "TableViewCellAccount.h"


@interface FollowViewController (){
    AppDelegate *appDelegate;
}

- (IBAction)onBack:(id)sender;

@end

@implementation FollowViewController

@synthesize arrDetails, pageTitle;

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
    
    _pageTitleLabel.text = pageTitle;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
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

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrDetails count];    //count number of row from counting array hear catagory is An Array
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TableViewCellAccount *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowCell" forIndexPath:indexPath];
    
    NSMutableDictionary *dictUser = [arrDetails objectAtIndex:indexPath.row];
    
    _userName = [dictUser objectForKey:@"user__full_name"];
    _userId = [dictUser objectForKey:@"user__id"];
    
    [cell.userProfilePicture loadImageFromURL:[dictUser objectForKey:@"user__profile_pic"] withTempImage:@"avatar_icon"];
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    
    cell.userName.text = [dictUser objectForKey:@"user__full_name"];
    
    if (cell.userName.text == GetUserName){
        cell.followBtn.hidden = YES;
    } else {
        if ([appDelegate.arrFollowing containsObject:_userName]){
            UIImage *followImage = [UIImage imageNamed:@"checkmark_icon.png"];
            [cell.followBtn setImage:followImage forState:UIControlStateNormal];
        } else {
            UIImage *followImage = [UIImage imageNamed:@"plus_sign_icon.png"];
            [cell.followBtn setImage:followImage forState:UIControlStateNormal];
        }
    }
    
    [cell.followBtn addTarget:self action:@selector(followUser:) forControlEvents:UIControlEventTouchUpInside];
    cell.followBtn.tag = indexPath.row;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
    return cell;
}

-(IBAction)followUser:(UIButton *)sender {
    checkNetworkReachability();
    [self setBusy:YES];

    NSString *strURL = [NSString stringWithFormat:@"%@%@/", FOLLOWURL, _userId];
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
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if ([data length] > 0 && error == nil){
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

            if(JSONValue != nil){

                if([[JSONValue allKeys]count] > 1){

                    if ([appDelegate.arrFollowing containsObject:_userName]){
                        UIImage *followImage = [UIImage imageNamed:@"plus_sign_icon.png"];
                        [sender setImage:followImage forState:UIControlStateNormal];
                        
                        for(int i = 0; i < appDelegate.arrFollowing.count; i++){
                            if([[appDelegate.arrFollowing objectAtIndex:i]isEqualToString:_userName]){
                                [appDelegate.arrFollowing removeObjectAtIndex:i];
                            }
                        }
                        
                        NSInteger row = sender.tag;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                        [_tblVW beginUpdates];
                        [_tblVW reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
                        [_tblVW endUpdates];
                    } else {
                        UIImage *followImage = [UIImage imageNamed:@"checkmark_icon.png"];
                        [sender setImage:followImage forState:UIControlStateNormal];
                        
                        [appDelegate.arrFollowing addObject:_userName];
                        
                        NSInteger row = sender.tag;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                        [_tblVW beginUpdates];
                        [_tblVW reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                        [_tblVW endUpdates];
                    }
                }
            }
        } else {
            showServerError();
        }
        [self setBusy:NO];
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
    accountViewController.userURL = [NSString stringWithFormat:@"%@%@/", PROFILEURL, _userId];
    accountViewController.needBack = YES;
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

@end
