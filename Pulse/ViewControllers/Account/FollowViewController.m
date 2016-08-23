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
        UIImage *btnImage = [UIImage imageNamed:@"plus_sign_icon.png"];
        [cell.followBtn setImage:btnImage forState:UIControlStateNormal];
    }
    
    [cell.followBtn addTarget:self action:@selector(followUser:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
    [cell.contentView addSubview:bottomBorder];
    
    return cell;
}

-(IBAction)followUser:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showNotice:self title:@"Notice" subTitle:[NSString stringWithFormat:@"Follow %@", _userName] closeButtonTitle:@"OK" duration:0.0f];
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
