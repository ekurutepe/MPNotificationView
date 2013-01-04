/*
 Copyright (c) 2010 Ole Begemann
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

/*
 OBGradientView.h
 
 Created by Ole Begemann
 April, 2010
 */


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


/*
 OBGradientView is a simple UIView wrapper for CAGradientLayer. It is a plain UIView whose layer
 is a CAGradientLayer. It is useful if using a view is more convenient than using a layer, e.g.
 because you want to use autoresizing masks.
 
 OBGradientView exposes all of the layer's gradient-related properties.
 The getters and setters just forward the calls to the layer so the syntax is just the same as
 for CAGradientLayer's properties itself. See the documentation for CAGradientLayer for details:
 http://developer.apple.com/iphone/library/documentation/GraphicsImaging/Reference/CAGradientLayer_class/Reference/Reference.html
 
 The one exception to this is the colors property: in addition to an array of CGColorRefs,
 it also accepts an array of UIColor objects. Likewise, the getter returns an array of UIColors.
 If you need CGColorRefs, access gradientLayer.colors instead.
 */


@interface OBGradientView : UIView {
}

// Returns the view's layer. Useful if you want to access CAGradientLayer-specific properties
// because you can omit the typecast.
@property (nonatomic, readonly) CAGradientLayer *gradientLayer;

// Gradient-related properties are forwarded to layer.
// colors also accepts array of UIColor objects (in addition to array of CGColorRefs).
@property (nonatomic, retain) NSArray *colors;
@property (nonatomic, retain) NSArray *locations;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic, copy) NSString *type;

@end
