//
//  UIColor+Background.h
//  movies
//
//  Copyright © 2018-2020 jhale. All rights reserved
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//
//  Created by Jerry Hale on 5/27/18.

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface UIColor (Theme)
+(UIColor *)themeColor:(NSUInteger)rgbHexValue;
@end

IB_DESIGNABLE
@interface UIView (Theme)
-(void)setBorderColor:(UIColor *)color;
-(void)setBorderWidth:(CGFloat)width;
-(void)setCornerRadius:(CGFloat)radius;
@end

IB_DESIGNABLE
@interface UISearchBar (Theme)
-(void)setBorderColor:(UIColor *)color;
-(void)setBorderWidth:(CGFloat)width;
-(void)setCornerRadius:(CGFloat)radius;
@end

IB_DESIGNABLE
@interface UILabel (Theme)
-(void)setBackColor:(UIColor *)color;
-(void)setBorderColor:(UIColor *)color;
-(void)setBorderWidth:(CGFloat)width;
-(void)setCornerRadius:(CGFloat)radius;
@end

IB_DESIGNABLE
@interface UITableView (Theme)
-(void)setBorderColor:(UIColor *)color;
-(void)setBorderWidth:(CGFloat)width;
-(void)setCornerRadius:(CGFloat)radius;
@end
