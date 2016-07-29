







#import "UIImage+Epodreczniki.h"

@implementation UIImage (Epodreczniki)

- (UIImage *)imageWithColor:(UIColor *)color {
    UIImage *tmpImage = self;

    UIGraphicsBeginImageContextWithOptions(tmpImage.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, tmpImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, tmpImage.size.width, tmpImage.size.height);

    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, tmpImage.CGImage);

    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [color setFill];
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
}

@end
