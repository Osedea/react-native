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
#import "RCTSVGImageView.h"

@implementation RCTSVGImageViewManager

RCT_EXPORT_MODULE()

- (RCTShadowView *)shadowView
{
  return [RCTImageShadowView new];
}

- (UIView *)view
{
  return [[RCTSVGImageView alloc] initWithBridge:self.bridge];
}

RCT_EXPORT_VIEW_PROPERTY(resizeMode, RCTResizeMode)
RCT_REMAP_VIEW_PROPERTY(source, imageSources, NSArray<RCTImageSource *>);
RCT_CUSTOM_VIEW_PROPERTY(tintColor, UIColor, RCTSVGImageView)
{
  view.fillColor = [RCTConvert UIColor:json] ?: defaultView.tintColor;
}

RCT_EXPORT_METHOD(prefetchImage:(NSString *)url)
{
  if (!url) {
    reject(@"E_INVALID_URI", @"Cannot prefetch an image for an empty URI", nil);
    return;
  }

  [view initWithContentsOfURL:url];
}

@end
