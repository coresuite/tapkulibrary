//
//  TKCalendarMonthViewHeader.h
//  coresuite-ipad
//
//  Created by Tomasz Krasnyk on 10-12-17.
//  Copyright 2010 coresystems ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TKCalendarMonthViewHeader : UIView <UIAppearance> {
	UIImageView *backgroundView;
	UIButton *leftArrow;
	UIButton *rightArrow;
	UILabel	 *titleView;
	NSArray *dayLabels;
    
    CGFloat tileWidth;
    CGFloat tileStartOffset;
}
@property (nonatomic) CGFloat tileWidth;
@property (nonatomic) CGFloat tileStartOffset;
@property (nonatomic, readonly) NSArray *dayLabels;
@property (nonatomic, readonly) UIButton *leftArrow;
@property (nonatomic, readonly) UIButton *rightArrow;
@property (nonatomic, readonly) UILabel *titleView;
@property (nonatomic)           UIView  *accessoryView;
@property (nonatomic) UIImage *backgroundImage;

- (void) setBackgroundViewColor:(UIColor *)bkgColor UI_APPEARANCE_SELECTOR;
- (void) setTitleColor:(UIColor *)titleColor UI_APPEARANCE_SELECTOR;
- (void) setRightArrowImage:(UIImage *)rightArrowImage UI_APPEARANCE_SELECTOR;
- (void) setLeftArrowImage:(UIImage *)leftArrowImage UI_APPEARANCE_SELECTOR;

@end
