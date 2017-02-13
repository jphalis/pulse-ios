//
//  CustomTabViewController.m
//  Pulse
//

#import "AccountViewController.h"
#import "AppDelegate.h"
#import "CreateViewController.h"
#import "CustomTabViewController.h"
#import "defs.h"
#import "HomeViewController.h"
#import "NotificationsViewController.h"
#import "PulseViewController.h"


enum {
    TABHOME = 10,
    TABFIND,
    TABCREATE,
    TABNOTIFICATIONS,
    TABACCOUNT,
};

@interface CustomTabViewController (){
    AppDelegate *appDelegate;
    
    id specialViewController;
    NSInteger previousIndex ;
    UINavigationController *prevController;
    NSInteger currentIndex;
    NSTimer *timer;
}

- (IBAction)onTabSelectionChange:(id)sender;

@end

@implementation CustomTabViewController
@synthesize tabView;

- (void)viewDidLoad {
    appDelegate = (AppDelegate *)[AppDelegate getDelegate];
    self.navigationController.navigationBarHidden = YES;

    [self Initialize];
    [self LoadTabBar];
    
    UIButton *btnSender = (UIButton*) [self.view viewWithTag:10];
    [self onTabSelectionChange:btnSender];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)Initialize{
    prevController = nil;
    previousIndex = -1;
    currentIndex = -1;
    
    appDelegate.arrViewControllers = [[NSMutableArray alloc]init];
    appDelegate.tabbar = self;
    
    [self getArrFollowing];
    
//    if ([timer isValid]) {
//        [timer invalidate], timer = nil;
//    }
//    
//    timer = [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(getArrFollowing) userInfo:nil repeats:YES];
}

-(void)getArrFollowing {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@%ld/", PROFILEURL, (long)GetUserID];
        
        NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                 timeoutInterval:60];
        
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
        [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
        [_request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if ([data length] > 0 && error == nil) {
                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                if ([JSONValue isKindOfClass:[NSDictionary class]]) {
                    
                    if ([JSONValue objectForKey:@"follower"] != [NSNull null]) {
                        NSDictionary *dictFollower = [JSONValue objectForKey:@"follower"];
                        NSMutableArray *arrFollowing = [dictFollower objectForKey:@"get_following_info"];
                        
                        for (int j = 0; j < arrFollowing.count; j++) {
                            NSMutableDictionary *dictFollowerInfo = [[NSMutableDictionary alloc]init];
                            NSDictionary *dictUserDetail = [arrFollowing objectAtIndex:j];
                            
                            if ([dictUserDetail objectForKey:@"user__profile_pic"] == [NSNull null]) {
                                [dictFollowerInfo setObject:@"" forKey:@"user__profile_pic"];
                            } else {
                                [dictFollowerInfo setValue:[dictUserDetail objectForKey:@"user__profile_pic"] forKey:@"user__profile_pic"];
                            }
                            if ([dictUserDetail objectForKey:@"user__full_name"] == [NSNull null]) {
                                [dictFollowerInfo setObject:@"" forKey:@"user__full_name"];
                            } else {
                                [dictFollowerInfo setObject:[dictUserDetail objectForKey:@"user__full_name"] forKey:@"user__full_name"];
                            }
                            
                            if ([dictUserDetail objectForKey:@"user__id"] == [NSNull null]) {
                                [dictFollowerInfo setObject:@"" forKey:@"user__id"];
                            } else {
                                [dictFollowerInfo setObject:[NSString stringWithFormat:@"%@",[dictUserDetail objectForKey:@"user__id"]] forKey:@"user__id"];
                            }
                            
                            NSString *fullName = [dictFollowerInfo objectForKey:@"user__full_name"];
                            [dictFollowerInfo setValue:fullName forKey:@"user__full_name"];
                            
                            [appDelegate.arrFollowing addObject:dictFollowerInfo];
                        }
                    }
                    
                    if ([JSONValue objectForKey:@"profile_pic"] != [NSNull null]) {
                        SetUserProPic([JSONValue objectForKey:@"profile_pic"]);
                    }
                }
            }
        }];
    });
}

-(void)LoadTabBar {
    HomeViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    PulseViewController *pulseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PulseViewController"];
    CreateViewController *createViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateViewController"];
    NotificationsViewController *notificationsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
    AccountViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountViewController"];
    
    UINavigationController *navController1 = [[UINavigationController alloc]initWithRootViewController:homeViewController];
    UINavigationController *navController2 = [[UINavigationController alloc]initWithRootViewController:pulseViewController];
    UINavigationController *navController3 = [[UINavigationController alloc]initWithRootViewController:createViewController];
    UINavigationController *navController4 = [[UINavigationController alloc]initWithRootViewController:notificationsViewController];
    UINavigationController *navController5 = [[UINavigationController alloc]initWithRootViewController:accountViewController];
    
    [self PushViewController:navController1];
    [self PushViewController:navController2];
    [self PushViewController:navController3];
    [self PushViewController:navController4];
    [self PushViewController:navController5];
}

-(void)PushViewController:(UINavigationController *)nvc {
    nvc.navigationBarHidden = YES;
    [appDelegate.arrViewControllers addObject:nvc];
}

-(void)PresentSpecialViewController:(UIViewController *)vc {
    if (prevController != nil) {
        [prevController.view removeFromSuperview];
    }
    specialViewController = vc;
    CGRect frame = vc.view.frame;
    frame.origin = CGPointMake(0, 0);
    frame.size.height = frame.size.height;
    vc.view.frame = frame;
    [self.view addSubview:vc.view];
//    [self.view bringSubviewToFront:self.tabView];
    prevController = specialViewController;
}

-(void)presentThisView:(UINavigationController*)naVController {
    if (prevController != nil) {
        [prevController.view removeFromSuperview];
    }

    prevController = naVController;
    CGRect frame = prevController.view.frame;
    frame.origin = CGPointMake(0, 0);
    frame.size.height = frame.size.height;
    prevController.view.frame = frame;
    
    [self.view addSubview:prevController.view];
    [self.view bringSubviewToFront:tabView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onTabSelectionChange:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
    previousIndex = currentIndex;
    currentIndex = btn.tag;
    
    if (btn.tag == previousIndex) {
       // return;
    } else {
        if (previousIndex != 0) {
            UIButton *btnpreviousIndex = (UIButton*)[tabView viewWithTag:previousIndex];
            
            if (btnpreviousIndex != nil && previousIndex != -1) {
                [btnpreviousIndex setSelected:NO];
                NSArray *viewsToRemove = [btnpreviousIndex subviews];
                [[viewsToRemove lastObject] removeFromSuperview];
            }
            
            [btn setSelected:YES];

            UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, btn.frame.size.height - 4.0f, btn.frame.size.width, 4)];
            bottomBorder.backgroundColor = [UIColor colorWithRed:(171/255.0) green:(14/255.0) blue:(27/255.0) alpha:1.0];
//            if (currentIndex == 12){
//                bottomBorder.backgroundColor = [UIColor colorWithRed:(41/255.0) green:(46/255.0) blue:(50/255.0) alpha:1.0];
//            } else {
//                bottomBorder.backgroundColor = [UIColor colorWithRed:(171/255.0) green:(14/255.0) blue:(27/255.0) alpha:1.0];
//            }
            [btn addSubview:bottomBorder];
        }
    }
    appDelegate.currentTab = currentIndex;
    
    switch (currentIndex) {
        case TABHOME: {
            UINavigationController *navController = [appDelegate.arrViewControllers objectAtIndex:0];
            navController.navigationBarHidden = YES;
            [navController popToRootViewControllerAnimated:NO];
            [self presentThisView: navController];
            break;
        }
        case TABFIND: {
            UINavigationController *navController = [appDelegate.arrViewControllers objectAtIndex:1];
            [self presentThisView: navController];
            break;
        }
        case TABCREATE: {
            UINavigationController *navController = [appDelegate.arrViewControllers objectAtIndex:2];
            [self presentThisView: navController];
            break;
        }
        case TABNOTIFICATIONS: {
            UINavigationController *navController = [appDelegate.arrViewControllers objectAtIndex:3];
            [self presentThisView: navController];
            break;
        }
        case TABACCOUNT: {
            UINavigationController *navController = [appDelegate.arrViewControllers objectAtIndex:4];
            [self presentThisView: navController];
            break;
        }
        default:
            break;
    }
}

@end
