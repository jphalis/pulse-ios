//
//  EventsViewController.m
//  Pulse
//

#import "AppDelegate.h"
#import "CollectionViewCellParty.h"
#import "defs.h"
#import "EventsViewController.h"
#import "GlobalFunctions.h"
#import "PartyClass.h"
#import "SCLAlertView.h"
#import "SDIAsyncImageView.h"
#import "PartyViewController.h"
#import "UIViewControllerAdditions.h"


@interface EventsViewController () <UICollectionViewDelegateFlowLayout> {
    AppDelegate *appDelegate;
    
    NSInteger partyCount;
    NSMutableArray *arrParties;
    PartyViewController *partyViewController;
    UIRefreshControl *refreshControl;
//    NSInteger tapCellIndex;
}

- (IBAction)onBack:(id)sender;

@end

@implementation EventsViewController

- (void)viewDidLoad {
    [self getPartyDetails];

    [super viewDidLoad];
    
    arrParties = [[NSMutableArray alloc]init];

    partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];

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

    NSString *urlString = [NSString stringWithFormat:@"%@%@/", PARTIESURL, _userId];
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
                    partyClass.partyUrl = [[arrPartyResult objectAtIndex:i]valueForKey:@"party_url"];
                    partyClass.partyCreator = [[arrPartyResult objectAtIndex:i]valueForKey:@"user"];
                    partyClass.partyType = [[arrPartyResult objectAtIndex:i]valueForKey:@"party_type"];
                    partyClass.partyInvite = [[arrPartyResult objectAtIndex:i]valueForKey:@"invite_type"];
                    partyClass.partyName = [[arrPartyResult objectAtIndex:i]valueForKey:@"name"];
                    partyClass.partyAddress = [[arrPartyResult objectAtIndex:i]valueForKey:@"location"];
                    partyClass.partySize = [[arrPartyResult objectAtIndex:i]valueForKey:@"party_size"];
                    int partyMonth = [[[arrPartyResult objectAtIndex:i]valueForKey:@"party_month"]intValue];
                    partyClass.partyMonth = [NSString stringWithFormat:@"%d", partyMonth];
                    int partyDay = [[[arrPartyResult objectAtIndex:i]valueForKey:@"party_day"]intValue];
                    partyClass.partyDay = [NSString stringWithFormat:@"%d", partyDay];
                    int partyYear = [[[arrPartyResult objectAtIndex:i]valueForKey:@"party_year"]intValue];
                    partyClass.partyYear = [NSString stringWithFormat:@"%d", partyYear];
                    partyClass.partyStartTime = [[arrPartyResult objectAtIndex:i]valueForKey:@"start_time"];
                    if([[arrPartyResult objectAtIndex:i]valueForKey:@"end_time"] != [NSNull null]){
                        partyClass.partyEndTime = [[arrPartyResult objectAtIndex:i]valueForKey:@"end_time"];
                    } else {
                        partyClass.partyEndTime = @"?";
                    }
                    partyClass.partyDescription = [[arrPartyResult objectAtIndex:i]valueForKey:@"description"];
                    partyClass.partyAttendingCount = [[arrPartyResult objectAtIndex:i]valueForKey:@"attendees_count"];
                    partyClass.partyRequestCount = [[arrPartyResult objectAtIndex:i]valueForKey:@"requesters_count"];
                    
                    if([[arrPartyResult objectAtIndex:i]valueForKey:@"user_profile_pic"] == [NSNull null]){
                        partyClass.partyUserProfilePicture = @"";
                    } else {
                        partyClass.partyUserProfilePicture = [[arrPartyResult objectAtIndex:i]valueForKey:@"user_profile_pic"];                    }
                    
                    if([[arrPartyResult objectAtIndex:i]valueForKey:@"image"] == [NSNull null]){
                        partyClass.partyImage = @"";
                    } else {
                        partyClass.partyImage = [[arrPartyResult objectAtIndex:i]valueForKey:@"image"];
                    }
                    
                    if([[arrPartyResult objectAtIndex:i]valueForKey:@"get_attendees_info"] == [NSNull null]){
                        
                    } else {
                        NSMutableArray *arrAttendee = [[arrPartyResult objectAtIndex:i]valueForKey:@"get_attendees_info"];
                        
                        partyClass.arrAttending = [[NSMutableArray alloc]init];
                        
                        for(int j = 0; j < arrAttendee.count; j++){
                            NSMutableDictionary *dictAttendeeInfo = [[NSMutableDictionary alloc]init];
                            NSDictionary *dictUserDetail = [arrAttendee objectAtIndex:j];
                            
                            if([dictUserDetail objectForKey:@"profile_pic"] == [NSNull null]){
                                [dictAttendeeInfo setObject:@"" forKey:@"user__profile_pic"];
                            } else {
                                [dictAttendeeInfo setValue:[dictUserDetail objectForKey:@"profile_pic"] forKey:@"user__profile_pic"];
                            }
                            
                            if([dictUserDetail objectForKey:@"id"] == [NSNull null]){
                                [dictAttendeeInfo setObject:@"" forKey:@"user__id"];
                            } else {
                                [dictAttendeeInfo setObject:[NSString stringWithFormat:@"%@",[dictUserDetail objectForKey:@"id"]] forKey:@"user__id"];
                            }
                            
                            if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]){
                                [dictAttendeeInfo setObject:@"" forKey:@"user__full_name"];
                            } else {
                                [dictAttendeeInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                            }
                            
                            [partyClass.arrAttending addObject:dictAttendeeInfo];
                        }
                    }
                    
                    if([[arrPartyResult objectAtIndex:i]valueForKey:@"get_requesters_info"] == [NSNull null]){
                        
                    } else {
                        NSMutableArray *arrRequester = [[arrPartyResult objectAtIndex:i]valueForKey:@"get_requesters_info"];
                        
                        partyClass.arrRequested = [[NSMutableArray alloc]init];
                        
                        for(int j = 0; j < arrRequester.count; j++){
                            NSMutableDictionary *dictRequesterInfo = [[NSMutableDictionary alloc]init];
                            NSDictionary *dictUserDetail = [arrRequester objectAtIndex:j];
                            
                            if([dictUserDetail objectForKey:@"profile_pic"] == [NSNull null]){
                                [dictRequesterInfo setObject:@"" forKey:@"user__profile_pic"];
                            } else {
                                [dictRequesterInfo setValue:[dictUserDetail objectForKey:@"profile_pic"] forKey:@"user__profile_pic"];
                            }
                            
                            if([dictUserDetail objectForKey:@"id"] == [NSNull null]){
                                [dictRequesterInfo setObject:@"" forKey:@"user__id"];
                            } else {
                                [dictRequesterInfo setObject:[NSString stringWithFormat:@"%@",[dictUserDetail objectForKey:@"id"]] forKey:@"user__id"];
                            }
                            
                            if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]){
                                [dictRequesterInfo setObject:@"" forKey:@"user__full_name"];
                            } else {
                                [dictRequesterInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                            }
                            
                            [partyClass.arrRequested addObject:dictRequesterInfo];
                        }
                    }
                    
                    if([[arrPartyResult objectAtIndex:i]valueForKey:@"get_invited_users_info"] == [NSNull null]){
                        
                    } else {
                        NSMutableArray *arrInvited = [[arrPartyResult objectAtIndex:i]valueForKey:@"get_invited_users_info"];
                        
                        partyClass.arrInvited = [[NSMutableArray alloc]init];
                        
                        for(int j = 0; j < arrInvited.count; j++){
                            NSMutableDictionary *dictInvitedInfo = [[NSMutableDictionary alloc]init];
                            NSDictionary *dictUserDetail = [arrInvited objectAtIndex:j];
                            
                            if([dictUserDetail objectForKey:@"profile_pic"] == [NSNull null]){
                                [dictInvitedInfo setObject:@"" forKey:@"user__profile_pic"];
                            } else {
                                [dictInvitedInfo setValue:[dictUserDetail objectForKey:@"profile_pic"] forKey:@"user__profile_pic"];
                            }
                            
                            if([dictUserDetail objectForKey:@"id"] == [NSNull null]){
                                [dictInvitedInfo setObject:@"" forKey:@"user__id"];
                            } else {
                                [dictInvitedInfo setObject:[NSString stringWithFormat:@"%@",[dictUserDetail objectForKey:@"id"]] forKey:@"user__id"];
                            }
                            
                            if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]){
                                [dictInvitedInfo setObject:@"" forKey:@"user__full_name"];
                            } else {
                                [dictInvitedInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                            }
                            
                            [partyClass.arrInvited addObject:dictInvitedInfo];
                        }
                    }
                    
                    if([[arrPartyResult objectAtIndex:i]valueForKey:@"get_likers_info"] == [NSNull null]){
                        
                    } else {
                        NSMutableArray *arrLiked = [[arrPartyResult objectAtIndex:i]valueForKey:@"get_likers_info"];
                        
                        partyClass.arrLiked = [[NSMutableArray alloc]init];
                        
                        for(int j = 0; j < arrLiked.count; j++){
                            NSMutableDictionary *dictLikerInfo = [[NSMutableDictionary alloc]init];
                            NSDictionary *dictUserDetail = [arrLiked objectAtIndex:j];
                            
                            if([dictUserDetail objectForKey:@"id"] == [NSNull null]){
                                [dictLikerInfo setObject:@"" forKey:@"user__id"];
                            } else {
                                [dictLikerInfo setObject:[NSString stringWithFormat:@"%@",[dictUserDetail objectForKey:@"id"]] forKey:@"user__id"];
                            }
                            
                            if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]){
                                [dictLikerInfo setObject:@"" forKey:@"user__full_name"];
                            } else {
                                [dictLikerInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                            }
                            
                            [partyClass.arrLiked addObject:dictLikerInfo];
                        }
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
    CollectionViewCellParty *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EventCell" forIndexPath:indexPath];
    
    PartyClass *partyClass = [arrParties objectAtIndex:indexPath.row];

    NSInteger monthNumber = [partyClass.partyMonth integerValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(monthNumber-1)];
    cell.partyDate.text = [NSString stringWithFormat:@"%@ %@, %@", monthName, partyClass.partyDay, partyClass.partyYear];
    cell.partyTime.text = [NSString stringWithFormat:@"%@ - %@", partyClass.partyStartTime, partyClass.partyEndTime];
    [cell.userProfilePicture loadImageFromURL:partyClass.partyUserProfilePicture withTempImage:@"avatar_icon"];
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    cell.partyName.text = partyClass.partyName;
    cell.partyAddress.text = partyClass.partyAddress;
    [cell.partyPicture loadImageFromURL:partyClass.partyImage withTempImage:@"balloons_icon"];
    cell.partyAttending.text = partyClass.partyAttendingCount;
    cell.partyRequests.text = partyClass.partyRequestCount;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    tapCellIndex = indexPath.row;
    PartyClass *partyClass = [arrParties objectAtIndex:indexPath.row];
    
    partyViewController.partyId = partyClass.partyId;
//    partyViewController.partyUrl = partyClass.partyUrl;
    partyViewController.partyCreator = partyClass.partyCreator;
    partyViewController.partyInvite = partyClass.partyInvite;
    partyViewController.partyType = partyClass.partyType;
    partyViewController.partyName = partyClass.partyName;
    partyViewController.partyAddress = partyClass.partyAddress;
    partyViewController.partySize = partyClass.partySize;
    partyViewController.partyMonth = partyClass.partyMonth;
    partyViewController.partyDay = partyClass.partyDay;
    partyViewController.partyYear = partyClass.partyYear;
    partyViewController.partyStartTime = partyClass.partyStartTime;
    partyViewController.partyEndTime = partyClass.partyEndTime;
    partyViewController.partyImage = partyClass.partyImage;
    partyViewController.partyDescription = partyClass.partyDescription;
    partyViewController.partyAttending = partyClass.partyAttendingCount;
    partyViewController.partyRequests = partyClass.partyRequestCount;
    partyViewController.usersAttending = partyClass.arrAttending.mutableCopy;
    partyViewController.usersRequested = partyClass.arrRequested.mutableCopy;
    partyViewController.usersLiked = partyClass.arrLiked.mutableCopy;
    
    [self.navigationController pushViewController:partyViewController animated:YES];
}

@end
