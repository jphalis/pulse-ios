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
    
//    cell.userProfilePicture = [dictUser objectForKey:@"user__profile_picture"];
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    
    cell.userName.text = [dictUser objectForKey:@"user__name"];
    
    if (cell.userName.text == GetUserName){
        cell.followBtn.hidden = YES;
    } else {
        UIImage *btnImage = [UIImage imageNamed:@"plus_sign_icon.png"];
        [cell.followBtn setImage:btnImage forState:UIControlStateNormal];
    }
    
    [cell.followBtn addTarget:self action:@selector(followUser:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(IBAction)followUser:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showNotice:self title:@"Notice" subTitle:@"Follow this user." closeButtonTitle:@"OK" duration:0.0f];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showNotice:self title:@"Notice" subTitle:@"Show user account here." closeButtonTitle:@"OK" duration:0.0f];
    
//    NSDictionary *dictUserDeatil = [arrDetails objectAtIndex:indexPath.row];
    
//    AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
//    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

@end
