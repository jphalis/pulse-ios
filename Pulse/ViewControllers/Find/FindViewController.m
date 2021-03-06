//
//  FindViewController.m
//  Pulse
//

#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "CollectionViewCellParty.h"
#import "defs.h"
#import "FindViewController.h"
#import "GlobalFunctions.h"
#import "AnnotationClass.h"
#import "PartyClass.h"
#import "SCLAlertView.h"
#import "SDIAsyncImageView.h"
#import "PartyViewController.h"
#import "UIViewControllerAdditions.h"


@interface FindViewController () <MKMapViewDelegate, CLLocationManagerDelegate,UICollectionViewDelegateFlowLayout> {
    AppDelegate *appDelegate;
    
    NSInteger partyCount;
    NSMutableArray *arrParties;
    NSMutableArray *arrVisibleParties;
    UIRefreshControl *refreshControl;
}

@end

@implementation FindViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

- (void)viewDidLoad {
    arrParties = [[NSMutableArray alloc]init];
    arrVisibleParties = [[NSMutableArray alloc]init];
    _annotations = [[NSMutableArray alloc]init];

    [super viewDidLoad];
    
    [self getPartyDetails];
    
    appDelegate = [AppDelegate getDelegate];
    
    _mapView.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [_collectionVW addSubview:refreshControl];
    _collectionVW.alwaysBounceVertical = YES;
    
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
    
    // Show the tabbar
    appDelegate.tabbar.tabView.hidden = NO;
    
    [super viewWillAppear:YES];
    
    
    // Initialize map
    _currentLocBtn.layer.cornerRadius = 3;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        ) {
        [locationManager requestWhenInUseAuthorization];
    } else {
        [locationManager startUpdatingLocation];
    }
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    _mapView.showsUserLocation = YES;
    [_mapView setMapType:MKMapTypeStandard];
    [_mapView setZoomEnabled:YES];
    [_mapView setScrollEnabled:YES];
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 5000, 5000);
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    
    [locationManager startUpdatingLocation];
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

-(void)swipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)startRefresh {
    [self getPartyDetails];
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
        
        if (error != nil) {
            [appDelegate hideHUDForView2:self.view];
        }
        if ([data length] > 0 && error == nil) {
            [appDelegate hideHUDForView2:self.view];
            
            NSDictionary *JSONValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if([JSONValue isKindOfClass:[NSDictionary class]]){
                
                if (arrParties.count > 0) {
                    [arrParties removeAllObjects];
                }
                
                if (arrVisibleParties.count > 0) {
                    [arrVisibleParties removeAllObjects];
                }
                
                partyCount = [[JSONValue objectForKey:@"count"] integerValue];
                
                NSArray *arrPartyResult = [JSONValue objectForKey:@"results"];

                for (int i = 0; i < arrPartyResult.count; i++) {
                    PartyClass *partyClass = [[PartyClass alloc] init];
                    int partyId = [[[arrPartyResult objectAtIndex:i] valueForKey:@"id"] intValue];
                    partyClass.partyId = [NSString stringWithFormat:@"%d", partyId];
                    partyClass.partyUrl = [[arrPartyResult objectAtIndex:i] valueForKey:@"party_url"];
                    partyClass.partyCreator = [[arrPartyResult objectAtIndex:i] valueForKey:@"user"];
                    partyClass.partyType = [[arrPartyResult objectAtIndex:i] valueForKey:@"party_type"];
                    partyClass.partyInvite = [[arrPartyResult objectAtIndex:i] valueForKey:@"invite_type"];
                    partyClass.partyName = [[arrPartyResult objectAtIndex:i] valueForKey:@"name"];
                    partyClass.partyAddress = [[arrPartyResult objectAtIndex:i] valueForKey:@"location"];
                    partyClass.partyLatitude = [[arrPartyResult objectAtIndex:i] valueForKey:@"latitude"];
                    partyClass.partyLongitude = [[arrPartyResult objectAtIndex:i] valueForKey:@"longitude"];
                    partyClass.partySize = [[arrPartyResult objectAtIndex:i] valueForKey:@"party_size"];
                    int partyMonth = [[[arrPartyResult objectAtIndex:i] valueForKey:@"party_month"] intValue];
                    partyClass.partyMonth = [NSString stringWithFormat:@"%d", partyMonth];
                    int partyDay = [[[arrPartyResult objectAtIndex:i] valueForKey:@"party_day"] intValue];
                    partyClass.partyDay = [NSString stringWithFormat:@"%d", partyDay];
                    int partyYear = [[[arrPartyResult objectAtIndex:i] valueForKey:@"party_year"] intValue];
                    partyClass.partyYear = [NSString stringWithFormat:@"%d", partyYear];
                    partyClass.partyStartTime = [[arrPartyResult objectAtIndex:i] valueForKey:@"start_time"];
                    
                    if ([[arrPartyResult objectAtIndex:i] valueForKey:@"end_time"] == [NSNull null]){
                        partyClass.partyEndTime = @"?";
                    } else {
                        partyClass.partyEndTime = [[arrPartyResult objectAtIndex:i] valueForKey:@"end_time"];
                    }
                    
                    partyClass.partyDescription = [[arrPartyResult objectAtIndex:i] valueForKey:@"description"];
                    partyClass.partyAttendingCount = [NSString abbreviateNumber:[[[arrPartyResult objectAtIndex:i] valueForKey:@"attendees_count"] intValue]];
                    partyClass.partyRequestCount = [NSString abbreviateNumber:[[[arrPartyResult objectAtIndex:i] valueForKey:@"requesters_count"] intValue]];
                    
                    if([[arrPartyResult objectAtIndex:i] valueForKey:@"user_profile_pic"] == [NSNull null]){
                        partyClass.partyUserProfilePicture = @"";
                    } else {
                        partyClass.partyUserProfilePicture = [[arrPartyResult objectAtIndex:i]valueForKey:@"user_profile_pic"];
                    }
                    
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
                    
                    if ([[arrPartyResult objectAtIndex:i]valueForKey:@"get_requesters_info"] == [NSNull null]){
                        
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

-(void)showParties {
    // Pins for events
    [_mapView removeAnnotations:_mapView.annotations];
    [_annotations removeAllObjects];
    
    for(int i = 0; i < arrParties.count; i++){
        PartyClass *partyClass = [arrParties objectAtIndex:i];

        if ([partyClass.partyLatitude isEqual:[NSNull null]] || [partyClass.partyLongitude isEqual:[NSNull null]]){
            // NSLog(@"Empty coordinates");
        } else {
            double lat = [partyClass.partyLatitude doubleValue];
            double lon = [partyClass.partyLongitude doubleValue];
            
            CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude];
            CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            NSInteger distanceFromCurrentLocation = [eventLocation distanceFromLocation:currentLocation]/1609.344; // meters to miles

            if (distanceFromCurrentLocation < 10) {
                AnnotationClass *event_pin = [[AnnotationClass alloc] init];
                NSNumber *pin_lat = [NSNumber numberWithDouble:lat];
                NSNumber *pin_lon = [NSNumber numberWithDouble:lon];
                event_pin.latitude = pin_lat;
                event_pin.longitude = pin_lon;
                event_pin.title = partyClass.partyName;
                event_pin.annotationUrl = partyClass.partyUrl;
                if ([partyClass.partyInvite isEqualToString:@"Request + approval"] &&
                    ![[partyClass.arrAttending valueForKey:@"user__full_name"] containsObject:GetUserName]) {
                    // NSLog(@"Event is request + approve and user is not attending");
                } else {
                    [_mapView addAnnotation:event_pin];
                }
                [_annotations addObject:event_pin];
                [arrVisibleParties addObject:partyClass];
            }
        }
    }
    
    if (arrVisibleParties.count > 0){
        _watermarkLbl.hidden = YES;
    } else {
        _watermarkLbl.hidden = NO;
    }
    
    [_collectionVW reloadData];
    [_collectionVW layoutIfNeeded];
    [refreshControl endRefreshing];
}

#pragma mark - Map

- (IBAction)onCurrentLocation:(id)sender {
    CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 5000, 5000);
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 5000, 5000);
//    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
        if (!pinView) {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
        } else {
            pinView.annotation = annotation;
    }
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    AnnotationClass *selectedAnnotation = view.annotation;
    PartyViewController *partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
    partyViewController.partyUrl = selectedAnnotation.annotationUrl;
    [self.navigationController pushViewController:partyViewController animated:YES];
//    NSLog(@"%@", view.annotation.title);
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKPinAnnotationView *)view {
    id annotation = view.annotation;
    if(![annotation isKindOfClass:[MKUserLocation class]]) {
        view.pinColor = MKPinAnnotationColorPurple;
        // NSLog(@"%@", selectedAnnotation.title);
    }
}

#pragma mark - Collection View

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [arrVisibleParties count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth =  [[UIScreen mainScreen] bounds].size.width;
    return CGSizeMake(cellWidth, 100);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCellParty *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FindCell" forIndexPath:indexPath];

    PartyClass *partyClass = [arrVisibleParties objectAtIndex:indexPath.row];

    NSInteger monthNumber = [partyClass.partyMonth integerValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(monthNumber-1)];
    cell.partyDate.text = [NSString stringWithFormat:@"%@ %@, %@", monthName, partyClass.partyDay, partyClass.partyYear];
    cell.partyTime.text = [NSString stringWithFormat:@"%@ - %@", partyClass.partyStartTime, partyClass.partyEndTime];
    [cell.userProfilePicture loadImageFromURL:partyClass.partyUserProfilePicture withTempImage:@"avatar_icon"];
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    cell.userProfilePicture.clipsToBounds = YES;
    cell.partyName.text = partyClass.partyName;
    cell.partyAddress.text = partyClass.partyAddress;
    
    if (([partyClass.partyInvite isEqualToString:@"Invite only"] ||
         [partyClass.partyInvite isEqualToString:@"Request + approval"]) &&
        (!([partyClass.partyCreator isEqualToString:GetUserName])) &&
        (!([[partyClass.arrAttending valueForKey:@"user__full_name"] containsObject:GetUserName])))
    {
        // cell.partyAddress.hidden = YES;
        cell.partyAddress.text = @"(Location withheld)";
    }
    
    if ([partyClass.partyType isEqualToString:@"Custom"]) {
        [cell.partyPicture loadImageFromURL:partyClass.partyImage withTempImage:@"custom_icon"];
    }
    else if ([partyClass.partyType isEqualToString:@"Social"]) {
        [cell.partyPicture loadImageFromURL:partyClass.partyImage withTempImage:@"social_icon"];
    }
    else if ([partyClass.partyType isEqualToString:@"Holiday"]) {
        [cell.partyPicture loadImageFromURL:partyClass.partyImage withTempImage:@"holiday_icon"];
    }
    else if ([partyClass.partyType isEqualToString:@"Event"]) {
        [cell.partyPicture loadImageFromURL:partyClass.partyImage withTempImage:@"event_icon"];
    }
    else if ([partyClass.partyType isEqualToString:@"Rager"]) {
        [cell.partyPicture loadImageFromURL:partyClass.partyImage withTempImage:@"rager_icon"];
    }
    else if ([partyClass.partyType isEqualToString:@"Themed"]) {
        [cell.partyPicture loadImageFromURL:partyClass.partyImage withTempImage:@"themed_icon"];
    }
    else if ([partyClass.partyType isEqualToString:@"Celebration"]) {
        [cell.partyPicture loadImageFromURL:partyClass.partyImage withTempImage:@"celebration_icon"];
    }
    
    cell.partyPicture.backgroundColor = [UIColor clearColor];
    
    cell.partyAttending.text = partyClass.partyAttendingCount;
    cell.partyRequests.text = partyClass.partyRequestCount;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    PartyClass *partyClass = [arrVisibleParties objectAtIndex:indexPath.row];
    
    if ([partyClass.partyInvite isEqualToString:@"Request + approval"] &&
        ![[partyClass.arrAttending valueForKey:@"user__full_name"] containsObject:GetUserName]) {
        PartyViewController *partyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyViewController"];
        partyViewController.partyUrl = partyClass.partyUrl;
        [self.navigationController pushViewController:partyViewController animated:YES];
    } else {
        AnnotationClass *annotation = (AnnotationClass *)[_annotations objectAtIndex:indexPath.row];
        [_mapView selectAnnotation:annotation animated:YES];
    }
}

@end
