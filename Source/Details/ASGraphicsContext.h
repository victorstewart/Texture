//
//  ASGraphicsContext.h
//  Texture
//
//  Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/ASBaseDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A wrapper for the UIKit drawing APIs. If you are in ASExperimentalDrawing, and you have iOS >= 10, we will create
 * a UIGraphicsRenderer with an appropriate format. Otherwise, we will use UIGraphicsBeginImageContext et al.
 */
AS_EXTERN UIImage *ASGraphicsCreateImageWithOptions(CGSize size, BOOL opaque, CGFloat scale, void (^NS_NOESCAPE work)());

NS_ASSUME_NONNULL_END
