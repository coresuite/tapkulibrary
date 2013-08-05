//
//  TKCalendarMonthViewHeader.m
//  coresuite-ipad
//
//  Created by Tomasz Krasnyk on 10-12-17.
//  Copyright 2010 coresystems ag. All rights reserved.
//

#import "TKCalendarMonthViewHeader.h"
#import "TKGlobal.h"

@implementation TKCalendarMonthViewHeader
@synthesize leftArrow;
@synthesize rightArrow;
@synthesize titleView;
@synthesize accessoryView;
@synthesize dayLabels;
@dynamic backgroundImage;

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
		backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/topBar.png")]];
		[self addSubview:backgroundView];
		
		// arrows
		rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		rightArrow.tag = 1;
		[rightArrow setImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/calendar_right_arrow.png")] forState:0];
		[self addSubview:rightArrow];
		
		leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		leftArrow.tag = 0;
		[leftArrow setImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/calendar_left_arrow.png")] forState:0];
		[self addSubview:leftArrow];
		
		// title
		titleView = [[UILabel alloc] initWithFrame:CGRectZero];
		titleView.textAlignment = UITextAlignmentCenter;
		titleView.backgroundColor = [UIColor clearColor];
		titleView.font = [UIFont boldSystemFontOfSize:22];
		titleView.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
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
			label.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
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
    
	CGFloat fCalendarHeaderDaysLabelsWidth = floorf(CGRectGetWidth(self.bounds) / 7);
	CGFloat fDayLabelHeight = 15.0f;
	NSInteger labelIndex = 0;
	for (UILabel *dayLabel in dayLabels) {
		dayLabel.frame = CGRectMake(fCalendarHeaderDaysLabelsWidth * labelIndex, CGRectGetHeight(self.bounds) - fDayLabelHeight, fCalendarHeaderDaysLabelsWidth, fDayLabelHeight);
		++labelIndex;
	}
	
	backgroundView.frame = self.bounds;
}



@end
