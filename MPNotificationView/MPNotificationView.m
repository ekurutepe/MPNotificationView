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
#define RADIANS(deg) ((deg) * M_PI / 180.0f)

static CGRect notificationRect()
{
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        return CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, kMPNotificationHeight);
    }
    
    return CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, kMPNotificationHeight);
}

NSString *kMPNotificationViewTapReceivedNotification = @"kMPNotificationViewTapReceivedNotification";

#pragma mark MPNotificationWindow

@interface MPNotificationWindow : UIWindow

@property (nonatomic, strong) NSMutableArray *notificationQueue;
@property (nonatomic, strong) UIView *currentNotification;

@end

@implementation MPNotificationWindow

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.backgroundColor = [UIColor clearColor];
        _notificationQueue = [[NSMutableArray alloc] initWithCapacity:4];
        
        UIView *topHalfBlackView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame),
                                                                            CGRectGetMinY(frame),
                                                                            CGRectGetWidth(frame),
                                                                            0.5 * CGRectGetHeight(frame))];
        
        topHalfBlackView.backgroundColor = [UIColor blackColor];
        topHalfBlackView.layer.zPosition = -100;
        topHalfBlackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:topHalfBlackView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willRotateScreen:)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification
                                                   object:nil];
        
        [self rotateNotificationWindow];
    }
    
    return self;
}

- (void) willRotateScreen:(NSNotification *)notification
{
    if (self.hidden)
    {
        double delayInSeconds = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
           [self rotateNotificationWindow]; 
        });
    }
    else
    {
        [self rotateNotificationWindowAnimated];
    }
}

- (void) rotateNotificationWindowAnimated
{
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView animateWithDuration:duration
                     animations:^{
                         self.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self rotateNotificationWindow];
                         [UIView animateWithDuration:duration
                                          animations:^{
                                              self.alpha = 1;
                                          }];
                     }];
}


- (void) rotateNotificationWindow
{
    CGRect frame = notificationRect();
    BOOL isPortrait = (frame.size.width == [UIScreen mainScreen].bounds.size.width);
    
    if (isPortrait)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            frame.size.width = kMPNotificationIPadWidth;
        }
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)
        {
            frame.origin.y = [UIScreen mainScreen].bounds.size.height - kMPNotificationHeight;
            self.transform = CGAffineTransformMakeRotation(RADIANS(180.0f));
        }
        else
        {
            self.transform = CGAffineTransformIdentity;
        }
    }
    else
    {
        frame.size.height = frame.size.width;
        frame.size.width  = kMPNotificationHeight;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            frame.size.height = kMPNotificationIPadWidth;
        }
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft)
        {
            frame.origin.x = [UIScreen mainScreen].bounds.size.width - frame.size.width;
            self.transform = CGAffineTransformMakeRotation(RADIANS(90.0f));
        }
        else
        {
            self.transform = CGAffineTransformMakeRotation(RADIANS(-90.0f));
        }
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
static CGFloat const __imagePadding = 8.0f;

#pragma mark -
#pragma mark MPNotificationView

@interface MPNotificationView ()


@property (nonatomic, strong) OBGradientView * contentView;
@property (nonatomic, copy) MPNotificationSimpleAction tapBlock;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

+ (void) showNextNotification;
+ (UIImage*) screenImageWithRect:(CGRect)rect;

@end

@implementation MPNotificationView

- (void) dealloc
{
    _delegate = nil;
    [self removeGestureRecognizer:_tapGestureRecognizer];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat notificationWidth = notificationRect().size.width;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _contentView = [[OBGradientView alloc] initWithFrame:self.bounds];
        _contentView.colors = @[(id)[[UIColor colorWithWhite:0.99f alpha:1.0f] CGColor],
                                (id)[[UIColor colorWithWhite:0.9f  alpha:1.0f] CGColor]];
        
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _contentView.layer.cornerRadius = 8.0f;
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 28, 28)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 4.0f;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        UIFont *textFont = [UIFont boldSystemFontOfSize:14.0f];
        CGRect textFrame = CGRectMake(__imagePadding + CGRectGetMaxX(_imageView.frame),
                                      2,
                                      notificationWidth - __imagePadding * 2 - CGRectGetMaxX(_imageView.frame),
                                      textFont.lineHeight);
        _textLabel = [[UILabel alloc] initWithFrame:textFrame];
        _textLabel.font = textFont;
        _textLabel.numberOfLines = 1;
        _textLabel.textAlignment = UITextAlignmentLeft;
        _textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _textLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_textLabel];
        
        UIFont *detailFont = [UIFont systemFontOfSize:13.0f];
        CGRect detailFrame = CGRectMake(CGRectGetMinX(textFrame),
                                        CGRectGetMaxY(textFrame),
                                        notificationWidth - __imagePadding * 2 - CGRectGetMaxX(_imageView.frame),
                                        detailFont.lineHeight);
        
        _detailTextLabel = [[UILabel alloc] initWithFrame:detailFrame];
        _detailTextLabel.font = detailFont;
        _detailTextLabel.numberOfLines = 1;
        _detailTextLabel.textAlignment = UITextAlignmentLeft;
        _detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _detailTextLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_detailTextLabel];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame),
                                                                      CGRectGetHeight(frame) - 1.0f,
                                                                      CGRectGetWidth(frame),
                                                                      1.0f)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
        
        [_contentView addSubview:bottomLine];
    }
    
    return self;
}

+ (MPNotificationView *) notifyWithText:(NSString*)text
                              andDetail:(NSString*)detail
{
    return [self notifyWithText:text
                         detail:detail
                    andDuration:2.0f];
}

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                            andDuration:(NSTimeInterval)duration
{
    return [self notifyWithText:text
                         detail:detail
                          image:nil
                    andDuration:duration];
}

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                                  image:(UIImage*)image
                            andDuration:(NSTimeInterval)duration
{
    return [self notifyWithText:text
                         detail:detail
                          image:image
                       duration:duration
                  andTouchBlock:nil];
}

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                               duration:(NSTimeInterval)duration
                          andTouchBlock:(MPNotificationSimpleAction)block
{
    return [self notifyWithText:text
                         detail:detail
                          image:nil
                       duration:duration
                  andTouchBlock:block];
}

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                          andTouchBlock:(MPNotificationSimpleAction)block
{
    return [self notifyWithText:text
                         detail:detail
                          image:nil
                       duration:2.0
                  andTouchBlock:block];
}

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                                  image:(UIImage*)image
                               duration:(NSTimeInterval)duration
                          andTouchBlock:(MPNotificationSimpleAction)block
{
    return [self notifyWithText:text
                         detail:detail
                          image:image
                       duration:duration
                        nibName:nil
                  andTouchBlock:block];
}

+ (MPNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                                  image:(UIImage*)image
                               duration:(NSTimeInterval)duration
                                nibName:(NSString *)nibName
                          andTouchBlock:(MPNotificationSimpleAction)block
{
    if (__notificationWindow == nil)
    {
        __notificationWindow = [[MPNotificationWindow alloc] initWithFrame:notificationRect()];
        __notificationWindow.hidden = NO;
    }
    
    MPNotificationView * notification;
    if (!nibName)
    {
        notification = [[MPNotificationView alloc] initWithFrame:__notificationWindow.bounds];
    }
    else
    {
        notification = [[NSBundle mainBundle] loadNibNamed:nibName
                                                     owner:nil
                                                   options:nil][0];
    }
    
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
    
    if (__notificationWindow.currentNotification == nil)
    {
        [self showNextNotification];
    }
    
    return notification;
}

- (void) handleTap:(UITapGestureRecognizer *)gestureRecognizer
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

+ (void) showNextNotification
{
    UIView *viewToRotateOut = nil;
    UIImage *screenshot = [self screenImageWithRect:__notificationWindow.frame];
    
    if (__notificationWindow.currentNotification)
    {
        viewToRotateOut = __notificationWindow.currentNotification;
    }
    else
    {
        viewToRotateOut = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        ((UIImageView *)viewToRotateOut).image = screenshot;
        [__notificationWindow addSubview:viewToRotateOut];
        __notificationWindow.hidden = NO;
    }
    
    UIView *viewToRotateIn = nil;
    
    if ([__notificationWindow.notificationQueue count] > 0)
    {
        viewToRotateIn = __notificationWindow.notificationQueue[0];
    }
    else
    {
        viewToRotateIn = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        ((UIImageView *)viewToRotateIn).image = screenshot;
    }
    
    viewToRotateIn.layer.anchorPointZ = 11.547f;
    viewToRotateIn.layer.doubleSided = NO;
    viewToRotateIn.layer.zPosition = 2;
    
    CATransform3D viewInStartTransform = CATransform3DMakeRotation(RADIANS(-120), 1.0, 0.0, 0.0);
    viewInStartTransform.m34 = -1.0 / 200.0;
    
    viewToRotateOut.layer.anchorPointZ = 11.547f;
    viewToRotateOut.layer.doubleSided = NO;
    viewToRotateOut.layer.zPosition = 2;
    
    CATransform3D viewOutEndTransform = CATransform3DMakeRotation(RADIANS(120), 1.0, 0.0, 0.0);
    viewOutEndTransform.m34 = -1.0 / 200.0;
    
    [__notificationWindow addSubview:viewToRotateIn];    
    __notificationWindow.backgroundColor = [UIColor blackColor];
    
    viewToRotateIn.layer.transform = viewInStartTransform;
    
    if ([viewToRotateIn isKindOfClass:[MPNotificationView class]] )
    {
        UIImageView *bgImage = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        bgImage.image = screenshot;
        [viewToRotateIn addSubview:bgImage];
        [viewToRotateIn sendSubviewToBack:bgImage];
        __notificationWindow.currentNotification = viewToRotateIn;
    }
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         viewToRotateIn.layer.transform = CATransform3DIdentity;
                         viewToRotateOut.layer.transform = viewOutEndTransform;
                     }
                     completion:^(BOOL finished) {
                         [viewToRotateOut removeFromSuperview];
                         [__notificationWindow.notificationQueue removeObject:viewToRotateOut];
                         if ([viewToRotateIn isKindOfClass:[MPNotificationView class]])
                         {
                             MPNotificationView *notification = (MPNotificationView*)viewToRotateIn;
                             [self performSelector:@selector(showNextNotification)
                                        withObject:nil
                                        afterDelay:notification.duration];
                             
                             __notificationWindow.currentNotification = notification;
                             [__notificationWindow.notificationQueue removeObject:notification];
                         }
                         else
                         {
                             [viewToRotateIn removeFromSuperview];
                             __notificationWindow.hidden = YES;
                             __notificationWindow.currentNotification = nil;
                         }
                         
                          __notificationWindow.backgroundColor = [UIColor clearColor];
                     }];
}

+ (UIImage *) screenImageWithRect:(CGRect)rect
{
    CALayer *layer = [[UIApplication sharedApplication] keyWindow].layer;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, scale);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    rect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale
                      , rect.size.width * scale, rect.size.height * scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], rect);
    UIImage *croppedScreenshot = [UIImage imageWithCGImage:imageRef
                                                     scale:screenshot.scale
                                               orientation:screenshot.imageOrientation];
    CGImageRelease(imageRef);
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationRight;
            break;
        case UIInterfaceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationLeft;
            break;
        default:
            break;
    }
    
    return [[UIImage alloc] initWithCGImage:croppedScreenshot.CGImage
                                      scale:croppedScreenshot.scale
                                orientation:imageOrientation];
}

@end
