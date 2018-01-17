/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTSVGImageViewManager.h"

#import <UIKit/UIKit.h>

#import <React/RCTConvert.h>

#import "RCTImageLoader.h"
#import "RCTImageShadowView.h"
#import "SVGImageView.h"

@implementation RCTSVGImageViewManager

RCT_EXPORT_MODULE()

- (RCTShadowView *)shadowView
{
  return [RCTImageShadowView new];
}

- (UIView *)view
{
  NSString *urlstring = @"https://en.wikipedia.org/wiki/Scalable_Vector_Graphics#/media/File:SVG_logo.svg";
  NSURL *url = [NSURL URLWithString:urlstring];
  
  return [[SVGImageView alloc] initWithContentsOfURL:url];
}

RCT_EXPORT_VIEW_PROPERTY(url, NSString);

@end
