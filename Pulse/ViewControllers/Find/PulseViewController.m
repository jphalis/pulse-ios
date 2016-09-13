//
//  PulseViewController.m
//  Pulse
//


#import "AppDelegate.h"
#import "defs.h"
#import "FindViewController.h"
#import "PulseViewController.h"


@interface PulseViewController (){
    AppDelegate *appDelegate;
    
    UIButton *button;
    UIButton *buttonTop;
    UIView *c;
    UIView *f;
}

@end

@implementation PulseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = [AppDelegate getDelegate];
}

-(void)viewWillAppear:(BOOL)animated{
    // Remove label on back button
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Show the tabbar
    appDelegate.tabbar.tabView.hidden = NO;
    
    [super viewWillAppear:YES];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 100);
    button.center = self.view.center;
    
    buttonTop = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonTop.frame = CGRectMake(0, 0, 100, 100);
    buttonTop.center = self.view.center;

    if ([[GetUserProPic lastPathComponent] isEqual:[NSNull null]]){
        NSURL *url = [NSURL URLWithString:GetUserProPic];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        [buttonTop setBackgroundImage:image forState:UIControlStateNormal];
        [buttonTop setBackgroundImage:image forState:UIControlStateSelected];
    } else {
        [buttonTop setBackgroundImage:[UIImage imageNamed:@"avatar_icon"] forState:UIControlStateNormal];
        [buttonTop setBackgroundImage:[UIImage imageNamed:@"avatar_icon"] forState:UIControlStateSelected];
    }
//    [button setTitle:@"Button" forState:UIControlStateNormal];
    
    c = [[UIView alloc] initWithFrame:button.bounds];
    c.backgroundColor = [UIColor colorWithRed:(171/255.0) green:(14/255.0) blue:(27/255.0) alpha:1.0];
    c.layer.cornerRadius = 50;
    [button addSubview:c];
    [button sendSubviewToBack:c];
    
    f = [[UIView alloc] initWithFrame:button.bounds];
    f.backgroundColor = [[UIColor colorWithRed:(171/255.0) green:(14/255.0) blue:(27/255.0) alpha:1.0] colorWithAlphaComponent:0.3];
    f.layer.cornerRadius = 50;
    [button addSubview:f];
    [button sendSubviewToBack:f];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(startPulse:)];
    [buttonTop addGestureRecognizer:singleFingerTap];
    
    [self.view addSubview:button];
    [self.view addSubview:buttonTop];
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

- (void)startPulse:(UITapGestureRecognizer *)gestureRecognizer{
    _descriptionLabel.text = @"Searching your area...";

    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = .5;
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.1];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = MAXFLOAT;
    [c.layer addAnimation:pulseAnimation forKey:@"a"];
    [button.titleLabel.layer addAnimation:pulseAnimation forKey:@"a"];
    
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.toValue = @0;
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.toValue = @2;
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[fade, pulse];
    group.duration = 1.0;
    group.repeatCount = MAXFLOAT;
    [f.layer addAnimation:group forKey:@"g"];
    
    [self performSelector:@selector(pushView) withObject:nil afterDelay:3.0];
}

- (void)pushView {
    FindViewController *findViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindViewController"];
    [self.navigationController pushViewController:findViewController animated:YES];
}

@end
