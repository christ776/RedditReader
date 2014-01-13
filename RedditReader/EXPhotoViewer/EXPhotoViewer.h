//
//  EXPhotoViewer.h
//  JustSayin'
//
//  Created by Julio Andrés Carrettoni on 08/11/13.
//  Copyright (c) 2013 Cloudtlalk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EXPhotoViewer : UIViewController <UIScrollViewDelegate>{
    IBOutlet UIScrollView *zoomeableScrollView;
    IBOutlet UIImageView *theImageView;
    IBOutlet UIView *dimView;
}

+ (void) showImageFrom:(UIImageView*) image;
+ (void) showImageFrom:(UIImageView*) imageView withProgressIndicator:(UIView*) progressIndicator;

@end
