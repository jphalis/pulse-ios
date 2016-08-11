//
//  FindViewController.m
//  Pulse
//

#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "AppDelegate.h"
#import "CollectionViewCellImage.h"
#import "defs.h"
#import "FindViewController.h"
#import "GlobalFunctions.h"
#import "PartyClass.h"
#import "SCLAlertView.h"
//#import "SinglePartyViewController.h"
#import "UIViewControllerAdditions.h"


@interface FindViewController () <MKMapViewDelegate, CLLocationManagerDelegate,UICollectionViewDelegateFlowLayout> {
    AppDelegate *appDelegate;
    
    NSMutableArray *arrParties;
//    SinglePartyViewController *singlePartyViewController;
    UIRefreshControl *refreshControl;
    NSInteger *tapCellIndex;
}

@end

@implementation FindViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrParties = [[NSMutableArray alloc]init];

//    singlePartyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePartyViewController"];
//    singlePartyViewController.delegate = self;
//    
    appDelegate = [AppDelegate getDelegate];
    
    _mapView.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
//    tapCellIndex = -1;
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh)
             forControlEvents:UIControlEventValueChanged];
    [_collectionVW addSubview:refreshControl];
    _collectionVW.alwaysBounceVertical = YES;
    
    [self getPartyDetails];
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
    [self getPartyDetails];
}

-(void)scrollToTop{
    [UIView animateWithDuration:0.5 animations:^(void){
        [_collectionVW scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }];
}

-(void)getPartyDetails {
    [refreshControl endRefreshing];
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
//    return [arrParties count];
    return 1;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth =  [[UIScreen mainScreen] bounds].size.width;
    return CGSizeMake(cellWidth, 100);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCellImage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FindCell" forIndexPath:indexPath];
    
    cell.partyDate.text = @"August 25, 2016";
    cell.partyTime.text = @"4:00 PM - 8:00PM";
    
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    cell.partyName.text = @"JP Birthday";
    cell.partyAddress.text = @"Hoboken, NJ";
    cell.partyAttending.text = @"21";
    cell.partyRequests.text = @"100";
    
//    PartyClass *partyClass = [arrParties objectAtIndex:indexPath.row];
//    
//    NSInteger monthNumber = [partyClass.partyMonth integerValue];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(monthNumber-1)];
//    cell.partyDate.text = [NSString stringWithFormat:@"%@ %@, 2016", monthName, partyClass.partyDay];
//    cell.partyTime.text = [NSString stringWithFormat:@"%@ - %@", partyClass.partyStartTime, partyClass.partyEndTime];
//
////    cell.userProfilePicture = partyClass.partyUserProfilePicture;
//    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.frame.size.width / 2;
//    cell.userProfilePicture.layer.masksToBounds = YES;

//    cell.partyName.text = partyClass.partyName;
//    cell.partyAddress.text = partyClass.partyAddress;
////    cell.partyPicture = partyClass.partyImage;
//    cell.numberAttending.text = partyClass.partyAttendingCount;
//    cell.numberRequests.text = partyClass.partyRequestCount;
    
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
//    singlePartyViewController.photoURL = partyClass.photo;
//    singePartyViewController.photoDeleteURL = partyClass.photo_url;
//    
//    [appDelegate.window addSubview:singlePartyViewController.view];
}

@end
