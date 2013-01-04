//
//  MPNotificationView.m
//  Moped
//
//  Created by Engin Kurutepe on 1/2/13.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import "MPNotificationView.h"
#import "OBGradientView.h"

#define kMPNotificationHeight   40.0f

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
        
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
 
        [self rotateStatusBarWithFrame:[NSValue valueWithCGRect:statusBarFrame]];

    }
    return self;
}

- (void)willRotateScreen:(NSNotification *)notification {
    NSValue *frameValue = [notification.userInfo valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    
    NSLog(@"will rotate to: %@", NSStringFromCGRect([frameValue CGRectValue]) );
    if (NO == self.hidden) {
        [self rotateStatusBarAnimatedWithFrame:frameValue];
    } else {
        [self rotateStatusBarWithFrame:frameValue];
    }
}

- (void)rotateStatusBarAnimatedWithFrame:(NSValue *)frameValue {
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self rotateStatusBarWithFrame:frameValue];
        [UIView animateWithDuration:duration animations:^{
            self.alpha = 1;
        }];
    }];
}


- (void)rotateStatusBarWithFrame:(NSValue *)frameValue {
    CGRect frame = [frameValue CGRectValue];

    if (frame.size.height == 20) {
        frame.size.height = kMPNotificationHeight;
        NSLog(@"portrait frame: %@", NSStringFromCGRect(frame));
        if (frame.origin.y > 0) {
            // upside down
            self.transform = CGAffineTransformMakeRotation(M_PI);
        }
        else {
            self.transform = CGAffineTransformIdentity;
        }
    }
    else if (frame.size.width == 20) {
        frame.size.width = kMPNotificationHeight;
        if (frame.origin.x > 0) {
            frame.origin.x = 280;
            self.transform = CGAffineTransformMakeRotation(M_PI * 90.0f / 180.0f);
        }
        else {
            self.transform = CGAffineTransformMakeRotation(M_PI * (-90.0f) / 180.0f);
        }
        NSLog(@"landscape frame: %@", NSStringFromCGRect(frame));
    }
    
    self.frame = frame;
    
}

@end



static MPNotificationWindow * __notificationWindow = nil;

#pragma mark -
#pragma mark MPNotificationView

@interface MPNotificationView ()


@property (nonatomic, strong) OBGradientView * contentView;

+ (void) showNextNotification;
+ (UIImage*) screenImageWithRect:(CGRect)rect;

@end

@implementation MPNotificationView

- (id)initWithFrame:(CGRect)frame
{
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    CGFloat statusBarWidth = (isPortrait) ? statusBarFrame.size.width : statusBarFrame.size.height;


    
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



+ (MPNotificationView*) notifyWithText:(NSString*)text andDetail:(NSString*)detail
{
    return [self notifyWithText:text andDetail:detail andDuration:2.0];
}

+ (MPNotificationView*) notifyWithText:(NSString*)text andDetail:(NSString*)detail andDuration:(NSTimeInterval)duration
{
    return [self notifyWithText:text detail:detail image:nil andDuration:duration];
}

+ (MPNotificationView*) notifyWithText:(NSString*)text
                 detail:(NSString*)detail
                  image:(UIImage*)image
            andDuration:(NSTimeInterval)duration
{
    
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;

    if (__notificationWindow == nil) {
        BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
        if (isPortrait) {
            statusBarFrame.size.height = kMPNotificationHeight;
        }
        else {
            statusBarFrame.size.width = kMPNotificationHeight;
        }
        __notificationWindow = [[MPNotificationWindow alloc] initWithFrame:statusBarFrame];
        __notificationWindow.hidden = NO;
    }

    MPNotificationView * notification = [[MPNotificationView alloc] initWithFrame:__notificationWindow.bounds];
    
    notification.textLabel.text = text;
    notification.detailTextLabel.text = detail;
    notification.imageView.image = image;
    notification.duration = duration;
    
    [__notificationWindow.notificationQueue addObject:notification];
    
    if (__notificationWindow.currentNotification == nil) {
        [self showNextNotification];
    }
    
    return notification;
}

+ (void) showNextNotification {
    

    UIView * viewToRotateOut = nil;
    
    if (__notificationWindow.currentNotification) {
        viewToRotateOut = __notificationWindow.currentNotification;

    }
    else {
        viewToRotateOut = [[UIImageView alloc] initWithImage:
                           [self screenImageWithRect:__notificationWindow.frame]];
        viewToRotateOut.frame = __notificationWindow.bounds;
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
                     animations:^{
                         viewToRotateIn.layer.transform = CATransform3DIdentity;
                         viewToRotateOut.layer.transform = viewOutEndTransform;
                     }
                     completion:^(BOOL finished) {
                         __notificationWindow.backgroundColor = [UIColor clearColor];
                         [viewToRotateOut removeFromSuperview];
                         if ([__notificationWindow.notificationQueue containsObject:viewToRotateOut]) {
                             [__notificationWindow.notificationQueue removeObject:viewToRotateOut];
                         }
                         if ([viewToRotateIn isKindOfClass:[MPNotificationView class]] ){
                             MPNotificationView * notification = (MPNotificationView*)viewToRotateIn;
                             
                             int64_t delayInSeconds = notification.duration;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 [self showNextNotification];
                             });
                             
                             __notificationWindow.currentNotification = notification;
                             [__notificationWindow.notificationQueue removeObject:notification];
                             
                         }
                         else {
                             [viewToRotateIn removeFromSuperview];
                             __notificationWindow.hidden = YES;
                             __notificationWindow.currentNotification = nil;
                         }
        
                     }];
    

}

+ (UIImage*) screenImageWithRect:(CGRect)rect
{

    CALayer * layer = [[UIApplication sharedApplication] keyWindow].layer;
    
    UIGraphicsBeginImageContext(layer.frame.size);

    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], rect);
    UIImage *croppedScreenshot = [UIImage imageWithCGImage:imageRef];
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
