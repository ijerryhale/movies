//	UIColor+Theme.m
// Copyright (c) 2018 Jerry Hale
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

#import "DictionaryKey.h"

#import "UIColor+Theme.h"

//	0x76D6FF

@implementation UIColor (Theme)
+(UIColor *)themeColor:(NSUInteger)rgbHexValue
{
    return([UIColor colorWithRed:((CGFloat)((rgbHexValue & 0xFF0000) >> 16)) / 255.0
							green:(((CGFloat)((rgbHexValue & 0x00FF00) >> 8))) / 255.0
							blue:(((CGFloat)(rgbHexValue & 0x00FF))) / 255.0 alpha:ALPHA_VALUE]);
}
@end

@implementation UIView (Theme)
-(void)setBorderColor:(UIColor *)color{ self.layer.borderColor = [UIColor themeColor:THEME_COLOR].CGColor; }
-(void)setBorderWidth:(CGFloat)width { self.layer.borderWidth = width; }
-(void)setCornerRadius:(CGFloat)radius { self.layer.cornerRadius = radius; self.layer.masksToBounds = radius > 0; }
@end

@implementation UIImageView (Theme)
-(void)setBorderColor:(UIColor *)color{ self.layer.borderColor = [UIColor themeColor:THEME_COLOR].CGColor; }
-(void)setBorderWidth:(CGFloat)width { self.layer.borderWidth = width; }
-(void)setCornerRadius:(CGFloat)radius { self.layer.cornerRadius = radius; self.layer.masksToBounds = radius > 0; }
@end

@implementation UILabel (Theme)
-(void)setBackColor:(UIColor *)color { self.layer.backgroundColor = [UIColor themeColor:THEME_COLOR].CGColor; }
-(void)setBorderColor:(UIColor *)color { self.layer.borderColor = [UIColor themeColor:THEME_COLOR].CGColor; }
-(void)setBorderWidth:(CGFloat)width { self.layer.borderWidth = width; }
-(void)setCornerRadius:(CGFloat)radius { self.layer.cornerRadius = radius; self.layer.masksToBounds = radius > 0;}
@end

@implementation UISearchBar (Theme)
-(void)setBorderColor:(UIColor *)color { self.layer.borderColor = [UIColor themeColor:THEME_COLOR].CGColor; }
-(void)setBorderWidth:(CGFloat)width { self.layer.borderWidth = width; }
-(void)setCornerRadius:(CGFloat)radius { self.layer.cornerRadius = radius; self.layer.masksToBounds = radius > 0; }
@end

@implementation UITableView (Theme)
-(void)setBorderColor:(UIColor *)color { self.layer.borderColor = [UIColor themeColor:THEME_COLOR].CGColor; }
-(void)setBorderWidth:(CGFloat)width { self.layer.borderWidth = width; }
-(void)setCornerRadius:(CGFloat)radius { self.layer.cornerRadius = radius; self.layer.masksToBounds = radius > 0; }
@end

