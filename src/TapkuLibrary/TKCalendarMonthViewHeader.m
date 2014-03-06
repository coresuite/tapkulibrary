//
//  TKCalendarMonthViewHeader.m
//  coresuite-ipad
//
//  Created by Tomasz Krasnyk on 10-12-17.
//  Copyright 2010 coresystems ag. All rights reserved.
//

#import "TKCalendarMonthViewHeader.h"
#import "TKGlobal.h"

#define isIOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
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

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		// bg
        UIImage *headerImage= [[UIImage alloc] initWithCGImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/dateTile.png")].CGImage  scale:1 orientation:UIImageOrientationDownMirrored];
        UIImage *stretchedImage = [headerImage resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f)];
        UIImage *rightArrowImage = [UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/calendar_right_arrow.png")];
        UIImage *arrowImage = [UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/calendar_left_arrow.png")];
        UIColor *daysColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
        UIColor *titleColor = daysColor;
        if (isIOS7) {
            headerImage = [UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/dateTileios7.png")];
            headerImage = [headerImage performSelector:NSSelectorFromString(@"imageWithRenderingMode:") withObject:[NSNumber numberWithInteger:CSIOS7UIImageRenderingModeAlwaysTemplate]];
            
            stretchedImage = [headerImage resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 2.0f, 0.0f)];
            rightArrowImage = [rightArrowImage performSelector:NSSelectorFromString(@"imageWithRenderingMode:") withObject:[NSNumber numberWithInteger:CSIOS7UIImageRenderingModeAlwaysTemplate]];
            arrowImage = [arrowImage performSelector:NSSelectorFromString(@"imageWithRenderingMode:") withObject:[NSNumber numberWithInteger:CSIOS7UIImageRenderingModeAlwaysTemplate]];
            daysColor = [UIColor lightGrayColor];
            titleColor = [[[[UIApplication sharedApplication] delegate] window] valueForKeyPath:@"tintColor"];
        }
        
		backgroundView = [[UIImageView alloc] initWithImage:stretchedImage];
		[self addSubview:backgroundView];
		
		// arrows
		rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		rightArrow.tag = 1;
		[rightArrow setImage:rightArrowImage forState:0];
		[self addSubview:rightArrow];
		
		leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		leftArrow.tag = 0;
		[leftArrow setImage:arrowImage forState:0];
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
			label.font = [UIFont systemFontOfSize:11];
			label.backgroundColor = [UIColor clearColor];
			label.textColor = daysColor;
			[dayLabelsTmp addObject:label];
			[self addSubview:label];
		}
		dayLabels = dayLabelsTmp;
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];

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

@end
