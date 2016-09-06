//
//  FindViewController.m
//  Pulse
//

#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "AppDelegate.h"
#import "CollectionViewCellParty.h"
#import "defs.h"
#import "FindViewController.h"
#import "GlobalFunctions.h"
#import "PartyClass.h"
#import "SCLAlertView.h"
#import "SDIAsyncImageView.h"
#import "PartyViewController.h"
#import "UIViewControllerAdditions.h"


@interface FindViewController () <MKMapViewDelegate, CLLocationManagerDelegate,UICollectionViewDelegateFlowLayout> {
    AppDelegate *appDelegate;
    
    NSInteger partyCount;
    NSMutableArray *arrParties;
    UIRefreshControl *refreshControl;
    NSInteger tapCellIndex;
}

@end

@implementation FindViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

- (void)viewDidLoad {
    [self getPartyDetails];

    [super viewDidLoad];
    
    arrParties = [[NSMutableArray alloc]init];
    appDelegate = [AppDelegate getDelegate];
    
    _mapView.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    tapCellIndex = -1;
    
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
    
    // Initialize map
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        ) {
        [locationManager requestWhenInUseAuthorization];
    } else {
        [locationManager startUpdatingLocation];
    }
    locationManager.distanceFilter = kCLDistanceFilterNone;
    // locationManager.distanceFilter = 250;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    _mapView.showsUserLocation = YES;
    [_mapView setMapType:MKMapTypeStandard];
    [_mapView setZoomEnabled:YES];
    [_mapView setScrollEnabled:YES];
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

    NSString *urlString = [NSString stringWithFormat:@"%@", PARTIESURL];
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
                    partyClass.partyAttendingCount = [NSString abbreviateNumber:[[[arrPartyResult objectAtIndex:i]valueForKey:@"attendees_count"]intValue]];
                    partyClass.partyRequestCount = [NSString abbreviateNumber:[[[arrPartyResult objectAtIndex:i]valueForKey:@"requesters_count"]intValue]];
                    
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
                                NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"profile_pic"]];
                                [dictAttendeeInfo setValue:proflURL forKey:@"user__profile_pic"];
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
                                NSString *proflURL = [NSString stringWithFormat:@"%@%@",@"https://oby.s3.amazonaws.com/media/",[dictUserDetail objectForKey:@"profile_pic"]];
                                [dictRequesterInfo setValue:proflURL forKey:@"user__profile_pic"];
                            }
                            
                            if([dictUserDetail objectForKey:@"full_name"] == [NSNull null]){
                                [dictRequesterInfo setObject:@"" forKey:@"user__full_name"];
                            } else {
                                [dictRequesterInfo setObject:[dictUserDetail objectForKey:@"full_name"] forKey:@"user__full_name"];
                            }
                            
                            [partyClass.arrRequested addObject:dictRequesterInfo];
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

#pragma mark - Map

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 5000, 5000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)locationServiceStatus {
    
    switch (locationServiceStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            // NSLog(@"User still thinking..");
        } break;
        case kCLAuthorizationStatusDenied: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorized"
                                                            message:@"This app needs you to authorize locations services to work."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [locationManager startUpdatingLocation];
        } break;
        default:
            break;
    }
}

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
}

- (NSString *)deviceLat {
    return [NSString stringWithFormat:@"%f", locationManager.location.coordinate.latitude];
}

- (NSString *)deviceLon {
    return [NSString stringWithFormat:@"%f", locationManager.location.coordinate.longitude];
}

- (NSString *)deviceAlt {
    return [NSString stringWithFormat:@"%f", locationManager.location.altitude];
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
    CollectionViewCellParty *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FindCell" forIndexPath:indexPath];
    
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
    
    tapCellIndex = indexPath.row;
    PartyClass *partyClass = [arrParties objectAtIndex:indexPath.row];
    
    PartyViewController *partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
    partyViewController.partyId = partyClass.partyId;
    //    partyViewController.partyInvite = partyClass.PartyInviteType;
    partyViewController.partyType = partyClass.partyType;
    partyViewController.partyName = partyClass.partyName;
    partyViewController.partyAddress = partyClass.partyAddress;
    partyViewController.partySize = partyClass.partySize;
    partyViewController.partyMonth = partyClass.partyMonth;
    partyViewController.partyDay = partyClass.partyDay;
    partyViewController.partyStartTime = partyClass.partyStartTime;
    partyViewController.partyEndTime = partyClass.partyEndTime;
    partyViewController.partyImage = partyClass.partyImage;
    partyViewController.partyDescription = partyClass.partyDescription;
    partyViewController.partyAttending = partyClass.partyAttendingCount;
    partyViewController.partyRequests = partyClass.partyRequestCount;
    partyViewController.usersAttending = partyClass.arrAttending.copy;
    partyViewController.usersRequested = partyClass.arrRequested.copy;

    [self.navigationController pushViewController:partyViewController animated:YES];
}

@end
