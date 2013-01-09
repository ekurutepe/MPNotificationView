//
//  MPNotificationView.m
//  Moped
//
//  Created by Engin Kurutepe on 1/2/13.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import "MPNotificationView.h"
#import "OBGradientView.h"

#define kMPNotificationHeight    40.0f
#define kMPNotificationIPadWidth 480.0f

static CGRect notificationRect()
{
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
    {
        return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, kMPNotificationHeight);
    }
    
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, kMPNotificationHeight);
}

NSString *kMPNotificationViewTapReceivedNotification = @"kMPNotificationViewTapReceivedNotification";

#pragma mark MPNotificationWindow
@interface MPNotificationWindow : UIWindow

@property (nonatomic, strong) NSMutableArray * notificationQueue;
@property (nonatomic, strong) UIView * currentNotification;

@end

@implementation MPNotificationWindow

- (id) initWithFrame:(CGRect)frame {
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGRect actualFrame = frame;
    if (isPortrait) {
        actualFrame.size.height = kMPNotificationHeight;
    }
    else {
        actualFrame.size.width = kMPNotificationHeight;
    }

    
    self = [super initWithFrame:actualFrame];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.notificationQueue = [[NSMutableArray alloc] initWithCapacity:4];
        self.currentNotification = nil;
        self.backgroundColor = [UIColor clearColor];
        UIView * topHalfBlackView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(actualFrame),
                                                                             CGRectGetMinY(actualFrame),
                                                                             CGRectGetWidth(actualFrame),
                                                                             0.5*CGRectGetHeight(actualFrame))];
        
        topHalfBlackView.backgroundColor = [UIColor blackColor];
        topHalfBlackView.layer.zPosition = -100;
        topHalfBlackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:topHalfBlackView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willRotateScreen:)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
        
        CGRect notificationBarFrame = notificationRect();
 
        [self rotateStatusBarWithFrame:notificationBarFrame];

    }
    return self;
}

- (void)willRotateScreen:(NSNotification *)notification
{
    CGRect notificationBarFrame = notificationRect();

    NSLog(@"will rotate to: %@", NSStringFromCGRect(notificationBarFrame) );
    if (NO == self.hidden) {
        [self rotateStatusBarAnimatedWithFrame:[NSValue valueWithCGRect:notificationBarFrame]];
    } else {
        [self rotateStatusBarWithFrame:notificationBarFrame];
    }
}

- (void)rotateStatusBarAnimatedWithFrame:(NSValue *)frameValue
{
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self rotateStatusBarWithFrame:[frameValue CGRectValue]];
        [UIView animateWithDuration:duration animations:^{
            self.alpha = 1;
        }];
    }];
}


- (void)rotateStatusBarWithFrame:(CGRect)frame
{
    BOOL isPortrait = frame.size.width == [UIScreen mainScreen].bounds.size.width;

    if (isPortrait) { // portrait
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            frame.size.width = kMPNotificationIPadWidth;
        }

        NSLog(@"portrait frame: %@", NSStringFromCGRect(frame));
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
            frame.origin.y = [UIScreen mainScreen].bounds.size.height - kMPNotificationHeight;
            self.transform = CGAffineTransformMakeRotation(M_PI);
        }
        else {
            self.transform = CGAffineTransformIdentity;
        }
    }
    else {
        frame.size.height = frame.size.width;
        frame.size.width = kMPNotificationHeight;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            frame.size.height = kMPNotificationIPadWidth;
        }
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
            frame.origin.x = [UIScreen mainScreen].bounds.size.width - frame.size.width;
            self.transform = CGAffineTransformMakeRotation(M_PI * 90.0f / 180.0f);
        }
        else {
            self.transform = CGAffineTransformMakeRotation(M_PI * (-90.0f) / 180.0f);
        }
        NSLog(@"landscape frame: %@", NSStringFromCGRect(frame));
    }
    
    self.frame = frame;
    CGPoint center = self.center;
    if (isPortrait)
    {
        center.x = CGRectGetMidX([UIScreen mainScreen].bounds);
    }
    else
    {
        center.y = CGRectGetMidY([UIScreen mainScreen].bounds);
    }
    self.center = center;
}

@end



static MPNotificationWindow * __notificationWindow = nil;

#pragma mark -
#pragma mark MPNotificationView

@interface MPNotificationView ()


@property (nonatomic, strong) OBGradientView * contentView;
@property (nonatomic, copy) MPNotificationSimpleAction tapBlock;
@property (nonatomic, strong) NSTimer *showNextNotificationTimer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

+ (void) showNextNotification;
+ (UIImage*) screenImageWithRect:(CGRect)rect;

@end

@implementation MPNotificationView

- (void)dealloc
{
    _delegate = nil;
    [self removeGestureRecognizer:_tapGestureRecognizer];
}

- (id)initWithFrame:(CGRect)frame
{
    CGRect statusBarFrame = notificationRect();
    CGFloat statusBarWidth = statusBarFrame.size.width;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.contentView = [[OBGradientView alloc] initWithFrame:self.bounds];
        self.contentView.colors = @[(id)[[UIColor colorWithWhite:0.99 alpha:1.0] CGColor],
                                    (id)[[UIColor colorWithWhite:0.9 alpha:1.0] CGColor]];
    
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.contentView.layer.cornerRadius = 8.f;
        [self addSubview:self.contentView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 28, 28)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.cornerRadius = 4.f;
        self.imageView.clipsToBounds = YES;
        
        [self addSubview:self.imageView];
        
        
        UIFont *textFont = [UIFont boldSystemFontOfSize:14.f];
        CGRect textFrame = CGRectMake(8+CGRectGetMaxX(self.imageView.frame),
                                      2,
                                      statusBarWidth - 16- CGRectGetMaxX(self.imageView.frame),
                                      textFont.lineHeight);
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.frame = textFrame;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = textFont;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.numberOfLines = 1;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.textLabel];
        
        
        UIFont *detailFont = [UIFont systemFontOfSize:13.f];
        CGRect detailFrame = CGRectMake(CGRectGetMinX(textFrame),
                                        CGRectGetMaxY(textFrame),
                                        statusBarWidth - 16 - CGRectGetMaxX(self.imageView.frame),
                                        detailFont.lineHeight);
        
        self.detailTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.detailTextLabel.frame = detailFrame;
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.font = detailFont;
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.numberOfLines = 1;
        self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.detailTextLabel];

        UIView * bottomLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame),
                                                                       CGRectGetHeight(frame)-1.0f,
                                                                       CGRectGetWidth(frame),
                                                                       1.f)];
        
        bottomLine.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
        
        [self.contentView addSubview:bottomLine];
        self.contentView.clipsToBounds = YES;

    }
    return self;
}



+ (MPNotificationView*) notifyWithText:(NSString*)text
                             andDetail:(NSString*)detail
{
    return [self notifyWithText:text detail:detail andDuration:2.0];
}

+ (MPNotificationView*) notifyWithText:(NSString*)text
                                detail:(NSString*)detail
                           andDuration:(NSTimeInterval)duration
{
    return [self notifyWithText:text detail:detail image:nil andDuration:duration];
}

+ (MPNotificationView*) notifyWithText:(NSString*)text
                                detail:(NSString*)detail
                                 image:(UIImage*)image
                           andDuration:(NSTimeInterval)duration
{
    return [self notifyWithText:text detail:detail image:image duration:duration andTouchBlock:nil];
}

+ (MPNotificationView*) notifyWithText:(NSString*)text
                                detail:(NSString*)detail
                                 image:(UIImage*)image
                              duration:(NSTimeInterval)duration
                         andTouchBlock:(MPNotificationSimpleAction)block
{
    if (__notificationWindow == nil) {
        __notificationWindow = [[MPNotificationWindow alloc] initWithFrame:notificationRect()];
        __notificationWindow.hidden = NO;
    }
    
    MPNotificationView * notification = [[MPNotificationView alloc] initWithFrame:__notificationWindow.bounds];
    
    notification.textLabel.text = text;
    notification.detailTextLabel.text = detail;
    notification.imageView.image = image;
    notification.duration = duration;
    notification.tapBlock = block;
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:notification
                                                                         action:@selector(handleTap:)];
    notification.tapGestureRecognizer = gr;
    [notification addGestureRecognizer:gr];
    
    [__notificationWindow.notificationQueue addObject:notification];
    
    if (__notificationWindow.currentNotification == nil) {
        [self showNextNotification];
    }
    
    return notification;
}

+ (MPNotificationView*) notifyWithText:(NSString*)text
                                detail:(NSString*)detail
                              duration:(NSTimeInterval)duration
                         andTouchBlock:(MPNotificationSimpleAction)block
{
    return [self notifyWithText:text detail:detail image:nil duration:duration andTouchBlock:block];
}

+ (MPNotificationView*) notifyWithText:(NSString*)text
                                detail:(NSString*)detail
                         andTouchBlock:(MPNotificationSimpleAction)block
{
    return [self notifyWithText:text detail:detail image:nil duration:2.0 andTouchBlock:block];
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (_tapBlock != nil)
    {
        _tapBlock(self);
    }
    if ([_delegate respondsToSelector:@selector(tapReceivedForNotificationView:)])
    {
        [_delegate didTapOnNotificationView:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPNotificationViewTapReceivedNotification
                                                        object:self];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:[self class]
                                             selector:@selector(showNextNotification)
                                               object:nil];
    
    [MPNotificationView showNextNotification];
}

+ (void) showNextNotification {
    

    UIView * viewToRotateOut = nil;
    
    if (__notificationWindow.currentNotification) {
        viewToRotateOut = __notificationWindow.currentNotification;

    }
    else {
        viewToRotateOut = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        ((UIImageView *)viewToRotateOut).image = [self screenImageWithRect:__notificationWindow.frame];
        [__notificationWindow addSubview:viewToRotateOut];
        __notificationWindow.hidden = NO;
    }
    
    
    UIView * viewToRotateIn = nil;
    
    
    
    if ([__notificationWindow.notificationQueue count]) {
        

        MPNotificationView * nextNotification = [__notificationWindow.notificationQueue objectAtIndex:0];
        
        viewToRotateIn = nextNotification;


    }
    else {
        viewToRotateIn = [[UIImageView alloc] initWithImage:
                          [self screenImageWithRect:__notificationWindow.frame]];
//        viewToRotateIn.transform = __notificationWindow.transform;
        viewToRotateIn.frame = __notificationWindow.bounds;
    }
    
    
    
    
    
    viewToRotateIn.layer.anchorPointZ = 11.547f;
    viewToRotateIn.layer.doubleSided = NO;
    viewToRotateIn.layer.zPosition = 2;

    
    CATransform3D viewInStartTransform = CATransform3DMakeRotation(-2*M_PI/3, 1.0, 0.0, 0.0);
    viewInStartTransform.m34 = -1.0/200.0;
    

    viewToRotateOut.layer.anchorPointZ = 11.547f;
    viewToRotateOut.layer.doubleSided = NO;
    viewToRotateOut.layer.zPosition = 2;

    CATransform3D viewOutEndTransform = CATransform3DMakeRotation(2*M_PI/3, 1.0, 0.0, 0.0);
    viewOutEndTransform.m34 = -1.0/200.0;
    
    [__notificationWindow addSubview:viewToRotateIn];
    __notificationWindow.backgroundColor = [UIColor blackColor];
    
    viewToRotateIn.layer.transform = viewInStartTransform;
    
    if ([viewToRotateIn isKindOfClass:[MPNotificationView class]] ){
        MPNotificationView * notification = (MPNotificationView*)viewToRotateIn;
        __notificationWindow.currentNotification = notification;
    }

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         viewToRotateIn.layer.transform = CATransform3DIdentity;
                         viewToRotateOut.layer.transform = viewOutEndTransform;
                     }
                     completion:^(BOOL finished) {

                         [viewToRotateOut removeFromSuperview];
                         if ([__notificationWindow.notificationQueue containsObject:viewToRotateOut]) {
                             [__notificationWindow.notificationQueue removeObject:viewToRotateOut];
                         }
                         if ([viewToRotateIn isKindOfClass:[MPNotificationView class]] ){
                             MPNotificationView * notification = (MPNotificationView*)viewToRotateIn;
                             [self performSelector:@selector(showNextNotification)
                                        withObject:nil
                                        afterDelay:notification.duration];
                             
                             __notificationWindow.currentNotification = notification;
                             [__notificationWindow.notificationQueue removeObject:notification];
                             
                         }
                         else {
                             [viewToRotateIn removeFromSuperview];
                             __notificationWindow.hidden = YES;
                             __notificationWindow.currentNotification = nil;
                         }
                         
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              __notificationWindow.backgroundColor = [UIColor clearColor];
                                          }];

        
                     }];
    

}

+ (UIImage*) screenImageWithRect:(CGRect)rect
{

    CALayer * layer = [[UIApplication sharedApplication] keyWindow].layer;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, scale);

    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    rect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], rect);
    UIImage *croppedScreenshot = [UIImage imageWithCGImage:imageRef
                                                     scale:screenshot.scale
                                               orientation:screenshot.imageOrientation];
    CGImageRelease(imageRef);


    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIImageOrientation imageOrientation;
    if (UIDeviceOrientationPortrait == orientation) {
        imageOrientation = UIImageOrientationUp;
    } else if (UIDeviceOrientationPortraitUpsideDown == orientation) {
        imageOrientation = UIImageOrientationDown;
    } else if (UIDeviceOrientationLandscapeRight == orientation) {
        imageOrientation = UIImageOrientationRight;
    } else {
        imageOrientation = UIImageOrientationLeft;
    }

    UIImage * rotatedImage = [[UIImage alloc] initWithCGImage:croppedScreenshot.CGImage
                                                        scale:croppedScreenshot.scale
                                                  orientation:imageOrientation];

    
    return rotatedImage;
}



@end
