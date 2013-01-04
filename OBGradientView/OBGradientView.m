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
 OBGradientView.m
 
 Created by Ole Begemann
 April, 2010
 */

#import "OBGradientView.h"



#pragma mark -
#pragma mark Implementation

@implementation OBGradientView

@dynamic gradientLayer;
@dynamic colors, locations, startPoint, endPoint, type;


// Make the view's layer a CAGradientLayer instance
+ (Class)layerClass 
{
    return [CAGradientLayer class];
}



// Convenience property access to the layer help omit typecasts
- (CAGradientLayer *)gradientLayer 
{
    return (CAGradientLayer *)self.layer;
}



#pragma mark -
#pragma mark Gradient-related properties

- (NSArray *)colors 
{
    NSArray *cgColors = self.gradientLayer.colors;
    if (cgColors == nil) {
        return nil;
    }
    
    // Convert CGColorRefs to UIColor objects
    NSMutableArray *uiColors = [NSMutableArray arrayWithCapacity:[cgColors count]];
    for (id cgColor in cgColors) {
        [uiColors addObject:[UIColor colorWithCGColor:(CGColorRef)cgColor]];
    }
    return [NSArray arrayWithArray:uiColors];
}


// The colors property accepts an array of CGColorRefs or UIColor objects (or mixes between the two).
// UIColors are converted to CGColor before forwarding the values to the layer.
- (void)setColors:(NSArray *)newColors 
{
    NSMutableArray *newCGColors = nil;

    if (newColors != nil) {
        newCGColors = [NSMutableArray arrayWithCapacity:[newColors count]];
        for (id color in newColors) {
            // If the array contains a UIColor, convert it to CGColor.
            // Leave all other types untouched.
            if ([color isKindOfClass:[UIColor class]]) {
                [newCGColors addObject:(id)[color CGColor]];
            } else {
                [newCGColors addObject:color];
            }
        }
    }
    
    self.gradientLayer.colors = newCGColors;
}


- (NSArray *)locations 
{
    return self.gradientLayer.locations;
}

- (void)setLocations:(NSArray *)newLocations 
{
    self.gradientLayer.locations = newLocations;
}

- (CGPoint)startPoint 
{
    return self.gradientLayer.startPoint;
}

- (void)setStartPoint:(CGPoint)newStartPoint 
{
    self.gradientLayer.startPoint = newStartPoint;
}

- (CGPoint)endPoint 
{
    return self.gradientLayer.endPoint;
}

- (void)setEndPoint:(CGPoint)newEndPoint 
{
    self.gradientLayer.endPoint = newEndPoint;
}

- (NSString *)type 
{
    return self.gradientLayer.type;
}

- (void) setType:(NSString *)newType 
{
    self.gradientLayer.type = newType;
}

@end