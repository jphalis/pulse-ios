//
//  EventsViewController.m
//  Pulse
//

#import "AppDelegate.h"
#import "CollectionViewCellImage.h"
#import "defs.h"
#import "EventsViewController.h"
#import "GlobalFunctions.h"
#import "PartyClass.h"
#import "SCLAlertView.h"
#import "SDIAsyncImageView.h"
//#import "PartyViewController.h"
#import "UIViewControllerAdditions.h"


@interface EventsViewController () <UICollectionViewDelegateFlowLayout> {
    AppDelegate *appDelegate;
    
    NSInteger partyCount;
    NSMutableArray *arrParties;
//  PartyViewController *partyViewController;
    UIRefreshControl *refreshControl;
    NSInteger *tapCellIndex;
}

- (IBAction)onBack:(id)sender;

@end

@implementation EventsViewController

- (void)viewDidLoad {
    [self getPartyDetails];

    [super viewDidLoad];
    
    arrParties = [[NSMutableArray alloc]init];

//    partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
//    partyViewController.delegate = self;
//    
    appDelegate = [AppDelegate getDelegate];
    
//    tapCellIndex = -1;
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [_collectionVW addSubview:refreshControl];
    _collectionVW.alwaysBounceVertical = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Show the tabbar
    appDelegate.tabbar.tabView.hidden = NO;
    
    [super viewWillAppear:YES];
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

#pragma mark - Functions

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)startRefresh{
    if(arrParties.count > 0){
        [arrParties removeAllObjects];
    }

    [self getPartyDetails];
}

-(void)scrollToTop{
    [UIView animateWithDuration:0.5 animations:^(void){
        [_collectionVW scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }];
}

-(void)getPartyDetails {
    checkNetworkReachability();
    [self setBusy:NO];
    
    [appDelegate showHUDAddedToView:self.view message:@""];

    NSString *urlString = [NSString stringWithFormat:@"%@", PARTIESOWNURL];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:60];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", GetUserEmail, GetUserPassword];
    NSData *plainData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64String];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [_request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(error != nil){
            [appDelegate hideHUDForView2:self.view];
        }
        if([data length] > 0 && error == nil){
            [appDelegate hideHUDForView2:self.view];
            
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]]){
                partyCount = [[JSONValue objectForKey:@"count"]integerValue];
                
                NSArray *arrPartyResult = [JSONValue objectForKey:@"results"];

                for (int i = 0; i < arrPartyResult.count; i++) {
                    PartyClass *partyClass = [[PartyClass alloc]init];
                    int partyId = [[[arrPartyResult objectAtIndex:i]valueForKey:@"id"]intValue];
                    partyClass.partyId = [NSString stringWithFormat:@"%d", partyId];
                    partyClass.partyType = [[arrPartyResult objectAtIndex:i]valueForKey:@"party_type"];
                    partyClass.partyName = [[arrPartyResult objectAtIndex:i]valueForKey:@"name"];
                    partyClass.partyAddress = [[arrPartyResult objectAtIndex:i]valueForKey:@"location"];
                    partyClass.partySize = [[arrPartyResult objectAtIndex:i]valueForKey:@"party_size"];
                    int partyMonth = [[[arrPartyResult objectAtIndex:i]valueForKey:@"party_month"]intValue];
                    partyClass.partyMonth = [NSString stringWithFormat:@"%d", partyMonth];
                    int partyDay = [[[arrPartyResult objectAtIndex:i]valueForKey:@"party_day"]intValue];
                    partyClass.partyDay = [NSString stringWithFormat:@"%d", partyDay];
                    partyClass.partyStartTime = [[arrPartyResult objectAtIndex:i]valueForKey:@"start_time"];
                    partyClass.partyEndTime = [[arrPartyResult objectAtIndex:i]valueForKey:@"end_time"];
                    partyClass.partyDescription = [[arrPartyResult objectAtIndex:i]valueForKey:@"description"];
                    partyClass.partyAttendingCount = [[arrPartyResult objectAtIndex:i]valueForKey:@"attendees_count"];
                    partyClass.partyRequestCount = [[arrPartyResult objectAtIndex:i]valueForKey:@"attendees_count"];
                    
                    if([[arrPartyResult objectAtIndex:i]valueForKey:@"user_profile_pic"] == [NSNull null]){
                        partyClass.partyUserProfilePicture = @"";
                    } else {
                        NSString *str = [[arrPartyResult objectAtIndex:i]valueForKey:@"user_profile_pic"];
                        partyClass.partyUserProfilePicture = [NSString stringWithFormat:@"https://oby.s3.amazonaws.com/media/%@", str];
                    }
                    
                    if([[arrPartyResult objectAtIndex:i]valueForKey:@"image"] == [NSNull null]){
                        partyClass.partyImage = @"";
                    } else {
                        NSString *str2 = [[arrPartyResult objectAtIndex:i]valueForKey:@"image"];
                        partyClass.partyImage = [NSString stringWithFormat:@"https://oby.s3.amazonaws.com/media/%@", str2];
                    }

                    [arrParties addObject:partyClass];
                }
                [appDelegate hideHUDForView2:self.view];
                [self showParties];
            } else {
                [appDelegate hideHUDForView2:self.view];
            }
        } else {
            [appDelegate hideHUDForView2:self.view];
            showServerError();
        }
    }];
}

-(void)showParties{
    [refreshControl endRefreshing];
    [_collectionVW reloadData];
}

#pragma mark - Collection View

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [arrParties count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth =  [[UIScreen mainScreen] bounds].size.width;
    return CGSizeMake(cellWidth, 100);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCellImage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EventCell" forIndexPath:indexPath];
    
    PartyClass *partyClass = [arrParties objectAtIndex:indexPath.row];

    NSInteger monthNumber = [partyClass.partyMonth integerValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(monthNumber-1)];
    cell.partyDate.text = [NSString stringWithFormat:@"%@ %@, 2016", monthName, partyClass.partyDay];
    cell.partyTime.text = [NSString stringWithFormat:@"%@ - %@", partyClass.partyStartTime, partyClass.partyEndTime];
    [cell.userProfilePicture loadImageFromURL:partyClass.partyUserProfilePicture withTempImage:@"avatar_icon"];
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    cell.partyName.text = partyClass.partyName;
    cell.partyAddress.text = partyClass.partyAddress;
    [cell.partyPicture loadImageFromURL:partyClass.partyImage withTempImage:@"grid_icon"];
    cell.partyAttending.text = partyClass.partyAttendingCount;
    cell.partyRequests.text = partyClass.partyRequestCount;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    CollectionViewCellImage *currentCell = (CollectionViewCellImage *)[collectionView cellForItemAtIndexPath:indexPath];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInFromLeft;
    alert.hideAnimationType = SlideOutToBottom;
    [alert showInfo:self title:@"Notice" subTitle:@"View party screen" closeButtonTitle:@"OK" duration:0.0f];
    
//    tapCellIndex = indexPath.row;
//    PartyClass *partyClass = [arrParties objectAtIndex:indexPath.row];
//    
//    partyViewController.photoURL = partyClass.photo;
//    partyViewController.photoDeleteURL = partyClass.photo_url;
//    
//    [appDelegate.window addSubview:partyViewController.view];
}

@end
