/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTSVGImageView.h"

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTImageSource.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>

#import "RCTImageBlurUtils.h"
#import "RCTImageLoader.h"
#import "RCTImageUtils.h"

/**
 * Determines whether an image of `currentSize` should be reloaded for display
 * at `idealSize`.
 */
static BOOL RCTShouldReloadImageForSizeChange(CGSize currentSize, CGSize idealSize)
{
  static const CGFloat upscaleThreshold = 1.2;
  static const CGFloat downscaleThreshold = 0.5;

  CGFloat widthMultiplier = idealSize.width / currentSize.width;
  CGFloat heightMultiplier = idealSize.height / currentSize.height;

  return widthMultiplier > upscaleThreshold || widthMultiplier < downscaleThreshold ||
    heightMultiplier > upscaleThreshold || heightMultiplier < downscaleThreshold;
}

/**
 * See RCTConvert (ImageSource). We want to send down the source as a similar
 * JSON parameter.
 */
static NSDictionary *onLoadParamsForSource(RCTImageSource *source)
{
  NSDictionary *dict = @{
    @"width": @(source.size.width),
    @"height": @(source.size.height),
    @"url": source.request.URL.absoluteString,
  };
  return @{ @"source": dict };
}

@implementation RCTSVGImageView
{
  // Weak reference back to the bridge, for image loading
  __weak RCTBridge *_bridge;

  // The image source that's currently displayed
  RCTImageSource *_imageSource;

  // The image source that's being loaded from the network
  RCTImageSource *_pendingImageSource;

  // Size of the image loaded / being loaded, so we can determine when to issue a reload to accommodate a changing size.
  CGSize _targetSize;

  // A block that can be invoked to cancel the most recent call to -reloadImage, if any
  RCTImageLoaderCancellationBlock _reloadImageCancellationBlock;

  // Whether the latest change of props requires the image to be reloaded
  BOOL _needsReload;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
  if ((self = [super init])) {
    _bridge = bridge;
    [self.addSubview: imageview];
  }
  return self;
}

RCT_NOT_IMPLEMENTED(- (instancetype)init)

- (void)updateWithImage:(SVGImageView *)image
{
  if (!image) {
    super.image = nil;
    return;
  }

  // Apply rendering mode
  // if (_renderingMode != image.renderingMode) {
  //   image = [image imageWithRenderingMode:_renderingMode];
  // }

  if (_resizeMode == RCTResizeModeRepeat) {
    image = [image resizableImageWithCapInsets:_capInsets resizingMode:SVGImageViewResizingModeTile];
  } else if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, _capInsets)) {
    // Applying capInsets of 0 will switch the "resizingMode" of the image to "tile" which is undesired
    image = [image resizableImageWithCapInsets:_capInsets resizingMode:SVGImageViewResizingModeStretch];
  }

  // Apply trilinear filtering to smooth out mis-sized images
  self.layer.minificationFilter = kCAFilterTrilinear;
  self.layer.magnificationFilter = kCAFilterTrilinear;

  super.image = image;
}

- (void)setImage:(SVGImageView *)image
{
  image = image ?: _defaultImage;
  if (image != self.image) {
    [self updateWithImage:image];
  }
}

- (void)setImageSources:(NSArray<RCTImageSource *> *)imageSources
{
  if (![imageSources isEqual:_imageSources]) {
    _imageSources = [imageSources copy];
    _needsReload = YES;
  }
}

- (void)setResizeMode:(RCTResizeMode)resizeMode
{
  if (_resizeMode != resizeMode) {
    _resizeMode = resizeMode;

    if (_resizeMode == RCTResizeModeRepeat) {
      // Repeat resize mode is handled by the SVGImageView. Use scale to fill
      // so the repeated image fills the SVGImageView.
      self.contentMode = UIViewContentModeScaleToFill;
    } else {
      self.contentMode = (UIViewContentMode)resizeMode;
    }

    if ([self shouldReloadImageSourceAfterResize]) {
      _needsReload = YES;
    }
  }
}

- (void)cancelImageLoad
{
  RCTImageLoaderCancellationBlock previousCancellationBlock = _reloadImageCancellationBlock;
  if (previousCancellationBlock) {
    previousCancellationBlock();
    _reloadImageCancellationBlock = nil;
  }

  _pendingImageSource = nil;
}

- (void)clearImage
{
  [self cancelImageLoad];
  [self.layer removeAnimationForKey:@"contents"];
  self.image = nil;
  _imageSource = nil;
}

- (void)clearImageIfDetached
{
  if (!self.window) {
    [self clearImage];
  }
}

- (BOOL)shouldChangeImageSource
{
  // We need to reload if the desired image source is different from the current image
  // source AND the image load that's pending
  RCTImageSource *desiredImageSource = _imageSources.firstObject;
  return ![desiredImageSource isEqual:_imageSource] &&
         ![desiredImageSource isEqual:_pendingImageSource];
}

- (void)reloadImage
{
  [self cancelImageLoad];
  _needsReload = NO;
  self.updat
  RCTImageSource *source = [self imageSourceForSize:self.frame.size];
  _pendingImageSource = source;

  if (source && self.frame.size.width > 0 && self.frame.size.height > 0) {
    SVGImageView* view = [SVGImageView [initWithContentsOfURL:source.request.URL.absoluteString]];

    return view;
  } else {
    [self clearImage];
  }
}

- (void)reactSetFrame:(CGRect)frame
{
  [super reactSetFrame:frame];

  // If we didn't load an image yet, or the new frame triggers a different image source
  // to be loaded, reload to swap to the proper image source.
  if ([self shouldChangeImageSource]) {
    _targetSize = frame.size;
    [self reloadImage];
  } else if ([self shouldReloadImageSourceAfterResize]) {
    CGSize imageSize = self.image.size;
    CGFloat imageScale = self.image.scale;
    CGSize idealSize = RCTTargetSize(imageSize, imageScale, frame.size, RCTScreenScale(),
                                     (RCTResizeMode)self.contentMode, YES);

    // Don't reload if the current image or target image size is close enough
    if (!RCTShouldReloadImageForSizeChange(imageSize, idealSize) ||
        !RCTShouldReloadImageForSizeChange(_targetSize, idealSize)) {
      return;
    }

    // Don't reload if the current image size is the maximum size of the image source
    CGSize imageSourceSize = _imageSource.size;
    if (imageSize.width * imageScale == imageSourceSize.width * _imageSource.scale &&
        imageSize.height * imageScale == imageSourceSize.height * _imageSource.scale) {
      return;
    }

    RCTLogInfo(@"Reloading image %@ as size %@", _imageSource.request.URL.absoluteString, NSStringFromCGSize(idealSize));

    // If the existing image or an image being loaded are not the right
    // size, reload the asset in case there is a better size available.
    _targetSize = idealSize;
    [self reloadImage];
  }
}

- (void)didSetProps:(NSArray<NSString *> *)changedProps
{
  if (_needsReload) {
    [self reloadImage];
  }
}

- (void)didMoveToWindow
{
  [super didMoveToWindow];

  if (!self.window) {
    // Cancel loading the image if we've moved offscreen. In addition to helping
    // prioritise image requests that are actually on-screen, this removes
    // requests that have gotten "stuck" from the queue, unblocking other images
    // from loading.
    [self cancelImageLoad];
  } else if ([self shouldChangeImageSource]) {
    [self reloadImage];
  }
}

@end
