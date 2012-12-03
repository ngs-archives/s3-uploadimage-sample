#import "UIImage+shrinking.h"

@implementation UIImage (shrinking)

- (UIImage*)imageByShrinkingWithSize:(CGSize)size {
  CGFloat widthRatio  = size.width  / self.size.width;
  CGFloat heightRatio = size.height / self.size.height;

  CGFloat ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio;

  if (ratio >= 1.0) {
    return self;
  }

  CGRect rect = CGRectMake(0, 0,
                           self.size.width  * ratio,
                           self.size.height * ratio);

  UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);

  [self drawInRect:rect];

  UIImage* shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();

  return shrinkedImage;
}

@end
