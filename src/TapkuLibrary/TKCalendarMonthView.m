//
//  TKCalendarMonthView.m
//  Created by Devin Ross on 6/10/10.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKCalendarMonthView.h"

#import "TKCalendarMonthTiles.h"

#define kCalendImagesPath @"TapkuLibrary.bundle/Images/calendar/"

static const CGFloat fCalendarHeaderHeight = 44.0f;

@interface TKCalendarMonthView (private)
@property (readonly) UIScrollView *tileBox;
@property (readonly) UIImageView *shadow;

- (NSDate*) firstOfMonthFromDate:(NSDate*)date;
- (NSDate*) nextMonthFromDate:(NSDate*)date;
- (NSDate*) previousMonthFromDate:(NSDate*)date;

@end


@implementation TKCalendarMonthView (privateMeth)

- (NSDate *) firstOfMonthFromDate:(NSDate*)date {
	TKDateInformation info = [date dateInformation];
	info.day = 1;
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	return [NSDate dateFromDateInformation:info];
}

- (NSDate*) nextMonthFromDate:(NSDate*)date {	
	TKDateInformation info = [date dateInformation];
	info.month++;
	if(info.month>12){
		info.month = 1;
		info.year++;
	}
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	
	return [NSDate dateFromDateInformation:info];
	
}

- (NSDate*) previousMonthFromDate:(NSDate*)date {
	TKDateInformation info = [date dateInformation];
	info.month--;
	if(info.month<1){
		info.month = 12;
		info.year--;
	}
	
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	return [NSDate dateFromDateInformation:info];
}

@end

@implementation TKCalendarMonthView
@synthesize delegate, dataSource, sizeDelegate;
@synthesize header;

+ (int) rowsForMonth:(NSDate *) date {
    return [TKCalendarMonthTiles rowsForMonth:date startDayOnSunday:YES];
}

- (CGFloat) maximumHeight {
	return CGRectGetHeight(header.bounds) + CGRectGetHeight(currentTile.selectedImageView.bounds) * 6;
}

+ (BOOL) sundayShouldBeFirst {
	BOOL sundayAsFirst = YES;
	
	NSLocale *prefLocale = [NSLocale autoupdatingCurrentLocale];
	NSCalendar *prefCalendar = [prefLocale objectForKey:NSLocaleCalendar];
	
	NSUInteger weekday = [prefCalendar firstWeekday];
	if(weekday == 2){
		sundayAsFirst = NO;
	}
	return sundayAsFirst;
}

- (id) init {
	return [self initWithSundayAsFirst:[TKCalendarMonthView sundayShouldBeFirst]];
}

- (id) initWithFrame:(CGRect)aFrame {
	return [self initWithFrame:aFrame sundayAsFirst:[TKCalendarMonthView sundayShouldBeFirst]];
}

- (id) initWithSundayAsFirst:(BOOL)sunday {
	return [self initWithFrame:CGRectZero sundayAsFirst:[TKCalendarMonthView sundayShouldBeFirst]];
}

- (id) initWithFrame:(CGRect) aFrame sundayAsFirst:(BOOL) s {
    if ((self = [super initWithFrame:aFrame])) {
        sunday = s;
        
        NSDate *month = [self firstOfMonthFromDate:[NSDate date]];
        
        currentTile = [[TKCalendarMonthTiles alloc] initWithFrame:CGRectZero month:month marks:nil startOnSunday:sunday];
        [currentTile setTarget:self action:@selector(tile:)];
        
        [self addSubview:self.header];
        [self.tileBox addSubview:currentTile];
        [self addSubview:self.tileBox];
        [self addSubview:self.shadow];
        
        self.backgroundColor = [UIColor grayColor];
        
        NSDate *date = [NSDate date];
        self.header.titleView.text = [NSString stringWithFormat:@"%@ %@",[date month],[date year]];
        
        // setup actions
        [self.header.rightArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
        [self.header.leftArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
        
        NSMutableArray *ar = [[NSMutableArray alloc] init];
        NSInteger startDateOffset = 0;
        if (!sunday) {
            startDateOffset = 1;
        }
        NSDate *startingDate = [NSDate dateWithTimeIntervalSince1970:3*24*60*60 + startDateOffset * 24*60*60 + 2];
        for (NSInteger i = 0; i < 7; ++i) {
            // name of a day of the week of 0 date is Thu
            [ar addObject:[startingDate day]];
            startingDate = [startingDate dateByAddingTimeInterval:24*60*60 + 1];
        }
        int i = 0;
        for(NSString *s in ar){
            UILabel *dayLabel = [self.header.dayLabels objectAtIndex:i];
            dayLabel.text = s;
            i++;
        }

    }
	
	return self;
}

- (void) changeMonthAnimation:(UIView*)sender {
	
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [self nextMonthFromDate:currentTile.monthDate] : [self previousMonthFromDate:currentTile.monthDate];
	
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:nextMonth startOnSunday:sunday];
	NSArray *ar = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    
    // TODO correct frame
    TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithFrame:[currentTile frame] month:nextMonth marks:ar startOnSunday:sunday];
	[newTile setTarget:self action:@selector(tile:)];
	
	
	int overlap =  0;
	
	if(isNext){
		overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : fCalendarHeaderHeight;
	}else{
		overlap = [currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? fCalendarHeaderHeight : 0;
	}
	
	float y = isNext ? currentTile.bounds.size.height - overlap : newTile.bounds.size.height * -1 + overlap;
	
	newTile.frame = CGRectMake(0, y, newTile.frame.size.width, newTile.frame.size.height);
	[self.tileBox addSubview:newTile];
	[self.tileBox bringSubviewToFront:currentTile];

	
	self.userInteractionEnabled = NO;
	
	NSTimeInterval animationDuration = 0.4;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(animationEnded)];
	[UIView setAnimationDuration:animationDuration];
	
	currentTile.alpha = 0.0;
	CGFloat outsideShadowHeight = 21.0f;
	if(isNext){
		currentTile.frame = CGRectMake(0, -1 * currentTile.bounds.size.height + overlap, currentTile.frame.size.width, currentTile.frame.size.height);
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
	} else {
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		currentTile.frame = CGRectMake(0,  newTile.frame.size.height - overlap, currentTile.frame.size.width, currentTile.frame.size.height);
	}
	self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+outsideShadowHeight, self.shadow.frame.size.width, self.shadow.frame.size.height);
	
	[self.sizeDelegate calendarMonthView:self willAnimateToFrame:newTile.frame animationDuration:animationDuration];
	
	[UIView commitAnimations];
	
	oldTile = currentTile;
	currentTile = newTile;
	self.header.titleView.text = [NSString stringWithFormat:@"%@ %@",[nextMonth month],[nextMonth year]];
    [self.header setNeedsLayout];
}

- (void) changeMonth:(UIButton *)sender{
	
	[self changeMonthAnimation:sender];
	if([delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:)])
		[delegate calendarMonthView:self monthDidChange:currentTile.monthDate];

}
- (void) animationEnded {
	self.userInteractionEnabled = YES;
	oldTile = nil;
}

- (NSDate*) dateSelected {
	return [currentTile dateSelected];
}

- (NSDate*) monthDate {
	return [currentTile monthDate];
}

- (void) selectDate:(NSDate*)date{
	TKDateInformation info = [date dateInformation];
	NSDate *month = [self firstOfMonthFromDate:date];
	
	if([month isEqualToDate:[currentTile monthDate]]){
		[currentTile selectDay:info.day];
		return;
	} else {
		
		NSDate *month = [self firstOfMonthFromDate:date];
		NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:month startOnSunday:sunday];
		NSArray *data = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
        
        // TODO correct frame
        TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithFrame:[currentTile frame] month:month marks:data startOnSunday:sunday];
		[newTile setTarget:self action:@selector(tile:)];
		[currentTile removeFromSuperview];
		currentTile = newTile;
		[self.tileBox addSubview:currentTile];
		self.tileBox.frame = CGRectMake(0, fCalendarHeaderHeight, newTile.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);

        CGFloat outsideShadowHeight = 21.0f;
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+outsideShadowHeight, self.shadow.frame.size.width, self.shadow.frame.size.height);

	
		self.header.titleView.text = [NSString stringWithFormat:@"%@ %@",[month month],[month year]];
		
		[currentTile selectDay:info.day];
	}
}
- (void) reload {
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:[currentTile monthDate] startOnSunday:sunday];
	NSArray *ar = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	
    TKCalendarMonthTiles *refresh = [[TKCalendarMonthTiles alloc] initWithFrame:[currentTile frame] month:[currentTile monthDate] marks:ar startOnSunday:sunday];
	[refresh setTarget:self action:@selector(tile:)];
	
	[self.tileBox addSubview:refresh];
	[currentTile removeFromSuperview];
	currentTile = refresh;
}

- (void) tile:(NSArray*)ar{
	
	if([ar count] < 2){
		
		NSDate *d = [currentTile monthDate];
		TKDateInformation info = [d dateInformation];
		info.day = [[ar objectAtIndex:0] intValue];
		
		NSDate *select = [NSDate dateFromDateInformation:info];
		if([delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
			[delegate calendarMonthView:self didSelectDate:select];
	}else{
		
		int direction = [[ar lastObject] intValue];
		UIButton *b = direction > 1 ? self.header.rightArrow : self.header.leftArrow;
		
		
		[self changeMonthAnimation:b];
		
		int day = [[ar objectAtIndex:0] intValue];
		//[currentTile selectDay:day];
	
		// thanks rafael
		TKDateInformation info = [[currentTile monthDate] dateInformation];
		info.day = day;
		NSDate *dateForMonth = [NSDate  dateFromDateInformation:info]; 
		[currentTile selectDay:day];
		
		if([delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:)])
			[delegate calendarMonthView:self monthDidChange:dateForMonth];

		
	}
	
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    int rows = [TKCalendarMonthView rowsForMonth:[currentTile monthDate]];
    CGFloat height = (CGRectGetWidth(self.bounds) / 7.0f) * rows;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat shadowImageHeight = [shadow image].size.height;

    CGFloat outsideShadowHeight = 21.0f;
    header.frame = CGRectMake(0.0f, 0.0f, width, fCalendarHeaderHeight);
    tileBox.frame = CGRectMake(0, fCalendarHeaderHeight, CGRectGetWidth(self.bounds), height);
    shadow.frame = CGRectMake(0, CGRectGetHeight(self.frame) - shadowImageHeight + outsideShadowHeight, width, shadowImageHeight);
    
    currentTile.frame = CGRectMake(0.0f, 0.0f, width, height);
}

- (TKCalendarMonthViewHeader *) header {
	if (!header) {
		header = [[TKCalendarMonthViewHeader alloc] initWithFrame:CGRectZero];
	}
	return header;
}

- (UIScrollView *) tileBox {
	if(!tileBox){
		tileBox = [[UIScrollView alloc] initWithFrame:CGRectZero];
	}
	return tileBox;
}

- (UIImageView *) shadow {
	if(shadow==nil){
		shadow = [[UIImageView alloc] initWithImage:[UIImage imageFromPath:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Shadow.png")]];
	}
	return shadow;
}



@end
