/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>
#import "SVGImageView.h"
#import <React/RCTResizeMode.h>

@class RCTBridge;
@class RCTImageSource;

@interface RCTSVGImageView : UIView

- (instancetype) initWithBridge:(RCTBridge *) bridge;
@property (nonatomic, copy) SVGImageView * imageView
@property (nonatomic, copy) NSArray<RCTImageSource *> *imageSources;
@property (nonatomic, assign) RCTResizeMode resizeMode;

@end
