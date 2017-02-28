//
//  PhotoViewController.h
//  Pulse
//  

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@protocol PhotoViewControllerDelegate <NSObject>

@required
-(void)removeImage;

@end

@interface PhotoViewController: UIViewController

@property (strong, nonatomic) NSString *photoUrl;
@property (nonatomic, assign) id<PhotoViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet SDIAsyncImageView *imageView;

@end
