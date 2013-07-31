//
//  TKCalendarMonthViewHeader.h
//  coresuite-ipad
//
//  Created by Tomasz Krasnyk on 10-12-17.
//  Copyright 2010 coresystems ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TKCalendarMonthViewHeader : UIView {
	UIImageView *backgroundView;
	UIButton *leftArrow;
	UIButton *rightArrow;
	UILabel	 *titleView;
	NSArray *dayLabels;
}
@property (nonatomic, readonly) NSArray *dayLabels;
@property (nonatomic, readonly) UIButton *leftArrow;
@property (nonatomic, readonly) UIButton *rightArrow;
@property (nonatomic, readonly) UILabel *titleView;
@property (nonatomic)           UIView  *accessoryView;
@property (nonatomic) UIImage *backgroundImage;

@end
