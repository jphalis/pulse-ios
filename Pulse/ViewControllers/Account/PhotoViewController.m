//
//  PhotoViewController.m
//

#import "AnimatedMethods.h"
#import "AppDelegate.h"
#import "AsyncImageView.h"
#import "defs.h"
#import "GlobalFunctions.h"
#import "PhotoViewController.h"
#import "SDIAsyncImageView.h"
#import "TWMessageBarManager.h"


#define ZOOM_STEP 2.0


@interface PhotoViewController ()<UIScrollViewDelegate>{
    AppDelegate *appDelegate;
}

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    appDelegate = [AppDelegate getDelegate];
    
    self.view.backgroundColor = [UIColor colorWithHue:1 saturation:1 brightness:0 alpha:0.95];
    [super viewDidLoad];
    
    // UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ClickImage:)];
    // [imageView addGestureRecognizer:tapGesture];
    
    // Do any additional setup after loading the view.
    
    // Setting up the scrollView
    _imageScrollView.bouncesZoom = YES;
    _imageScrollView.delegate = self;
    _imageScrollView.clipsToBounds = YES;
    
    // Setting up the imageView
    // [imageView loadImageFromURL:photoUrl withTempImage:@""];
   
    _imageView.userInteractionEnabled = YES;
    _imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    
    // Adding the imageView to the scrollView as subView
    // [imageScrollView addSubview:imageView];
    _imageScrollView.contentSize = CGSizeMake(_imageView.bounds.size.width, _imageView.bounds.size.height);
    _imageScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    //UITapGestureRecognizer set up
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    // Adding gesture recognizer
    [_imageView addGestureRecognizer:doubleTap];
    [_imageView addGestureRecognizer:twoFingerTap];
    
    UISwipeGestureRecognizer *viewDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown:)];
    viewDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:viewDown];
}

-(void)swipeDown:(UISwipeGestureRecognizer *)gestureRecognizer{
    CGRect toFrame = CGRectMake(0, +self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [self moveView:self.view fromFrame:self.view.frame toFrame:toFrame];
}

-(void)moveView:(UIView *)fromView fromFrame:(CGRect) fromFrame toFrame:(CGRect) toFrame{
    fromView.frame = fromFrame;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCurlDown
                     animations:^{
                         fromView.frame = toFrame;
                     }
                     completion:^(BOOL finished){
                         CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         self.view.frame = newFrame;
                         [self.delegate removeImage];
                     }
     ];
}

- (void)scrollViewDidZoom:(UIScrollView *)aScrollView {
    CGFloat offsetX = (_imageScrollView.bounds.size.width > _imageScrollView.contentSize.width)?
    (_imageScrollView.bounds.size.width - _imageScrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (_imageScrollView.bounds.size.height > _imageScrollView.contentSize.height)?
    (_imageScrollView.bounds.size.height - _imageScrollView.contentSize.height) * 0.5 : 0.0;
    _imageView.center = CGPointMake(_imageScrollView.contentSize.width * 0.5 + offsetX,
                                   _imageScrollView.contentSize.height * 0.5 + offsetY);
}

- (void)viewDidUnload {
    _imageScrollView = nil;
    _imageView = nil;
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // zoom in
    float newScale = [_imageScrollView zoomScale] * ZOOM_STEP;
    
    if (newScale > _imageScrollView.maximumZoomScale){
        newScale = _imageScrollView.minimumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [_imageScrollView zoomToRect:zoomRect animated:YES];
    } else {
        newScale = _imageScrollView.maximumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [_imageScrollView zoomToRect:zoomRect animated:YES];
    }
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [_imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [_imageScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [_imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [_imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

-(void)viewWillAppear:(BOOL)animated{
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = 1.0; //This is the minimum scale, set it to whatever you want. 1.0 = default
    _imageScrollView.maximumZoomScale = 3.0;
    _imageScrollView.minimumZoomScale = minimumScale;
    _imageScrollView.zoomScale = minimumScale;
    [_imageScrollView setContentMode:UIViewContentModeScaleAspectFit];
    // [imageView sizeToFit];
    [_imageScrollView setContentSize:CGSizeMake(_imageView.frame.size.width, _imageView.frame.size.height)];
    
    SetisFullView(YES);
    [AnimatedMethods zoomIn:self.view];
    
    SetIsImageView(YES);
    [_imageView loadImageFromURL:_photoUrl withTempImage:@"blankImage"];
    _imageView.shouldShowLoader = YES;
    
    [super viewWillAppear:YES];
    // appDelegate.tabbar.tabView.hidden=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    SetIsImageView(NO);
    _imageView.image = nil;
    [self.delegate removeImage];
}

-(void)ClickImage:(UITapGestureRecognizer *)gestureRecognizer{
    [self.delegate removeImage];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onCancelClick:(id)sender {
    [self.delegate removeImage];
}

@end
