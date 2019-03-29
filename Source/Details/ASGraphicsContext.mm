//
//  ASGraphicsContext.mm
//  Texture
//
//  Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#import <AsyncDisplayKit/ASGraphicsContext.h>
#import <AsyncDisplayKit/ASCGImageBuffer.h>
#import <AsyncDisplayKit/ASAssert.h>
#import <AsyncDisplayKit/ASConfigurationInternal.h>
#import <AsyncDisplayKit/ASInternalHelpers.h>

NS_AVAILABLE_IOS(10)
NS_INLINE void ASConfigureExtendedRange(UIGraphicsImageRendererFormat *format)
{
  if (AS_AVAILABLE_IOS(12)) {
    // nop. We always use automatic range on iOS >= 12.
  } else {
    // Currently we never do wide color. One day we could pipe this information through from the ASImageNode if it was worth it.
    format.prefersExtendedRange = NO;
  }
}

UIImage *ASGraphicsCreateImageWithOptions(CGSize size, BOOL opaque, CGFloat scale, void (^NS_NOESCAPE work)())
{
  if (AS_AVAILABLE_IOS(10)) {
    if (ASActivateExperimentalFeature(ASExperimentalDrawing)) {
      // If they used default scale, reuse one of two default formats.
      static UIGraphicsImageRendererFormat *defaultFormat;
      static UIGraphicsImageRendererFormat *opaqueFormat;
      static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
        defaultFormat = [[UIGraphicsImageRendererFormat alloc] init];
        opaqueFormat = [[UIGraphicsImageRendererFormat alloc] init];
        opaqueFormat.opaque = YES;
        ASConfigureExtendedRange(defaultFormat);
        ASConfigureExtendedRange(opaqueFormat);
      });

      UIGraphicsImageRendererFormat *format;
      if (scale == 0 || scale == ASScreenScale()) {
        format = opaque ? opaqueFormat : defaultFormat;
      } else {
        format = [[UIGraphicsImageRendererFormat alloc] init];
        if (opaque) format.opaque = YES;
        format.scale = scale;
        ASConfigureExtendedRange(format);
      }

      return [[[UIGraphicsImageRenderer alloc] initWithSize:size format:format] imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {
        ASDisplayNodeCAssert(UIGraphicsGetCurrentContext(), @"Should have a context!");
        work();
      }];
    }
  }

  // Bad OS or experiment flag. Use UIGraphics* API.
  UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
  work();
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}
