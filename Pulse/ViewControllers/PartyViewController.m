//
//  PartyViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "PartyViewController.h"
#import "SCLAlertView.h"
#import "UIViewControllerAdditions.h"


@interface PartyViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation PartyViewController

@synthesize usersAttending;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
    
    // Go back when swipe right
    UISwipeGestureRecognizer *viewRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    viewRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:viewRight];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Hide the tabbar
    appDelegate.tabbar.tabView.hidden = YES;
    
    [super viewWillAppear:YES];
    
    [_partyImageField loadImageFromURL:_partyImage withTempImage:@"camera_icon"];
    _partyImageField.layer.borderWidth = 4;
    _partyImageField.layer.borderColor = [[UIColor whiteColor] CGColor];
    _partyImageField.layer.cornerRadius = 10;
    _partyImageField.layer.masksToBounds = YES;
    
    NSInteger monthNumber = [_partyMonth integerValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(monthNumber-1)];
    _partyDateTimeField.text = [NSString stringWithFormat:@"%@ %@, 2016  %@-%@", monthName, _partyDay, _partyStartTime, _partyEndTime];
    
    _partyNameField.text = _partyName;
    _partyAddressField.text = _partyAddress;
    _partyAttendingField.text = _partyAttending;
    _partyRequestsField.text = _partyRequests;
    _partyDescriptionField.text = _partyDescription;
    
    if ([[usersAttending valueForKey:@"user__full_name"] containsObject: GetUserName]) {
        [_attendBtn setTitle:@"Going!" forState:UIControlStateNormal];
    } else {
        [_attendBtn setTitle:@"Let's go!" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

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

#pragma mark - Functions

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAttend:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showInfo:self title:@"Notice" subTitle:@"Attend party functionality." closeButtonTitle:@"OK" duration:0.0f];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString *strURL = [NSString stringWithFormat:@"%@%@/", ATTENDURL, _partyId];
//        NSURL *url = [NSURL URLWithString:strURL];
//        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
//        [urlRequest setTimeoutInterval:60];
//        [urlRequest setHTTPMethod:@"POST"];
//        NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
//        NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
//        NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
//        [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
//        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
//        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
//            
//            if ([data length] > 0 && error == nil){
//                NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//                if(JSONValue != nil){
//                    /*
//                     int likecount=(int)[photoClass.like_count integerValue];
//                     if(photoClass.isLike){
//                     likecount--;
//                     }else{
//                     likecount++;
//                     }
//                     
//                     photoClass.like_count=[NSString stringWithFormat:@"%d",likecount];
//                     photoClass.isLike=!photoClass.isLike;
//                     
//                     selectCell.imgLike.image=[UIImage imageNamed:@"like_icon"];
//                     if(photoClass.isLike){
//                     selectCell.imgLike.image=[UIImage imageNamed:@"likeselect"];
//                     }
//                     selectCell.lblLikes.text=[NSString stringWithFormat:@"%@",photoClass.like_count];
//                     */
//                    // [collectionVWHome reloadData];
//                }
//            } else {
//                [self showMessage:SERVER_ERROR];
//            }
//        }];
//        [self setBusy:NO];
//    });
}

@end
