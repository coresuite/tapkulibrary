//
//  TKCalendarMonthViewHeader.m
//  coresuite-ipad
//
//  Created by Tomasz Krasnyk on 10-12-17.
//  Copyright 2010 coresystems ag. All rights reserved.
//

#import "TKCalendarMonthViewHeader.h"
#import "TKGlobal.h"

#define CSIOS7UIImageRenderingModeAlwaysTemplate 2

@implementation TKCalendarMonthViewHeader
@synthesize leftArrow;
@synthesize rightArrow;
@synthesize titleView;
@synthesize accessoryView;
@synthesize dayLabels;
@synthesize tileStartOffset;
@synthesize tileWidth;
@dynamic backgroundImage;

- (void) setTileWidth:(CGFloat)aTileWidth {
    tileWidth = aTileWidth;
    [self setNeedsLayout];
}

- (void) setTileStartOffset:(CGFloat)aTileStartOffset {
    tileStartOffset = aTileStartOffset;
    [self setNeedsLayout];
}

- (void) setBackgroundImage:(UIImage *) image {
	backgroundView.image = image;
}

- (UIImage *) backgroundImage {
	return backgroundView.image;
}

- (void)setAccessoryView:(UIView *)_accessoryView {
    if (accessoryView == _accessoryView) {
        return;
    }
    [accessoryView removeFromSuperview];
    accessoryView = nil;
    accessoryView = _accessoryView;
    [self addSubview:accessoryView];
    [self setNeedsLayout];
}

#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		// bg
        UIImage *headerImage= [[UIImage alloc] initWithCGImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/dateTile.png")].CGImage  scale:1 orientation:UIImageOrientationDownMirrored];
        UIImage *stretchedImage = [headerImage resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f)];
        UIColor *daysColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
        UIColor *titleColor = daysColor;
        
		backgroundView = [[UIImageView alloc] initWithImage:stretchedImage];
		[self addSubview:backgroundView];
		
		// arrows
		rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		rightArrow.tag = 1;
		[self addSubview:rightArrow];
		
		leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		leftArrow.tag = 0;
		[self addSubview:leftArrow];
		
		// title
		titleView = [[UILabel alloc] initWithFrame:CGRectZero];
		titleView.textAlignment = UITextAlignmentCenter;
		titleView.backgroundColor = [UIColor clearColor];
		titleView.font = [UIFont boldSystemFontOfSize:22];
		titleView.textColor = titleColor;
		[self addSubview:titleView];
		
		NSMutableArray *dayLabelsTmp = [[NSMutableArray alloc] initWithCapacity:7];
		// day labels
		for(NSInteger i = 0; i < 7; ++i){
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
			label.textAlignment = UITextAlignmentCenter;
			label.shadowColor = [UIColor whiteColor];
			label.shadowOffset = CGSizeMake(0, 1);
			label.font = [UIFont systemFontOfSize:10];
			label.backgroundColor = [UIColor clearColor];
			label.textColor = daysColor;
			[dayLabelsTmp addObject:label];
			[self addSubview:label];
		}
		dayLabels = dayLabelsTmp;
        
        _horizontalSeparator = [[UIView alloc] init];
        _horizontalSeparator.backgroundColor = [UIColor grayColor];
        [self addSubview:_horizontalSeparator];
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
    
    CGFloat separatorThickness = [[UIScreen mainScreen] scale] == 2.00 ? 0.5f : 1.0f;
    
    _horizontalSeparator.frame = CGRectMake(0.0f, CGRectGetMaxY(self.frame) - separatorThickness, CGRectGetWidth(self.bounds), separatorThickness);

	CGFloat arrowsY = 48.0f;
	CGFloat fCalendarHeaderComponentsHeight = 38.0f;
	leftArrow.frame = CGRectMake(0, 0, arrowsY, fCalendarHeaderComponentsHeight);
	rightArrow.frame = CGRectMake(CGRectGetWidth(self.bounds) - arrowsY, 0, arrowsY, fCalendarHeaderComponentsHeight);
	
	titleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), fCalendarHeaderComponentsHeight);
    
    CGSize titleViewStringSize = [titleView.text sizeWithFont:titleView.font];
    CGRect accessoryViewFrame = accessoryView.frame;
    accessoryViewFrame.origin.x = (self.bounds.size.width / 2.0f); // place the accessory into the middle of the header
    accessoryViewFrame.origin.x += roundf((titleViewStringSize.width / 2.0f)); // move it to the right, exactly half the size of the string space
    accessoryViewFrame.origin.x += 3.0f; // add a small spacer
    accessoryViewFrame.origin.y = fCalendarHeaderComponentsHeight / 2 - (fCalendarHeaderComponentsHeight / 2.0f); // position it vertically
    accessoryViewFrame.size = CGSizeMake(fCalendarHeaderComponentsHeight, fCalendarHeaderComponentsHeight);
    CGRectInset(accessoryViewFrame, -10.0f, -10.0f); // make the button a little bit more touch sensitive
    accessoryView.frame = accessoryViewFrame;
    
	CGFloat fCalendarHeaderDaysLabelsWidth = tileWidth;
	CGFloat fDayLabelHeight = 15.0f;
	NSInteger labelIndex = 0;
	for (UILabel *dayLabel in dayLabels) {
		dayLabel.frame = CGRectMake(tileStartOffset + fCalendarHeaderDaysLabelsWidth * labelIndex, CGRectGetHeight(self.bounds) - fDayLabelHeight, fCalendarHeaderDaysLabelsWidth, fDayLabelHeight);
		++labelIndex;
	}
	
	backgroundView.frame = self.bounds;
}

- (void) setBackgroundViewColor:(UIColor *)bkgColor {
    backgroundView.image = nil;
    backgroundView.backgroundColor = bkgColor;
}

- (void) setTitleColor:(UIColor *)titleColor {
    titleView.textColor = titleColor;
    for (UILabel *dayLabel in dayLabels) {
        dayLabel.textColor = titleColor;
        dayLabel.shadowOffset = CGSizeMake(0, 0);
    }
}

- (void) setRightArrowImage:(UIImage *)rightArrowImage {
    [rightArrow setImage:rightArrowImage forState:UIControlStateNormal];
}

- (void) setLeftArrowImage:(UIImage *)leftArrowImage {
    [leftArrow setImage:leftArrowImage forState:UIControlStateNormal];
}

- (void) setTitleFontAttributes:(NSDictionary *)titleAttributes {
    UIFont *fontName = titleAttributes[NSFontAttributeName];
    titleView.font = fontName;
}

- (void) setAccessoryViewColor:(UIColor *)color {
    [accessoryView setTintColor:color];
}

@end
