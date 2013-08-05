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
#import "NSDate+TKCategory.h"
#import "NSDate+CalendarGrid.h"
#import "TKGlobal.h"

@interface TKCalendarMonthView (private)
@property (readonly) UIScrollView *tileBox;
@property (readonly) UIImageView *shadow;

@end

@implementation TKCalendarMonthView
@synthesize delegate, dataSource, sizeDelegate;
@synthesize header;
@synthesize timeZone;

+ (CGFloat) headerHeight {
    return 44.0f;
}

+ (NSUInteger) rowsForMonth:(NSDate *) date {
    return [self rowsForMonth:date timeZone:[NSTimeZone defaultTimeZone]];
}

+ (NSUInteger) rowsForMonth:(NSDate *) date timeZone:(NSTimeZone *) timeZone {
    return [TKCalendarMonthTiles rowsForMonth:date startDayOnSunday:YES timeZone:timeZone];
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
    return [self initWithFrame:aFrame sundayAsFirst:s timeZone:[NSTimeZone defaultTimeZone]];
}

- (id) initWithFrame:(CGRect) aFrame sundayAsFirst:(BOOL) s timeZone:(NSTimeZone*)tz {
    if ((self = [super initWithFrame:aFrame])) {
        self.timeZone = tz;
        sunday = s;
        
        NSDate *month = [[NSDate date] firstOfMonthWithTimeZone:tz];
        
        currentTile = [[TKCalendarMonthTiles alloc] initWithFrame:CGRectZero month:month marks:nil startOnSunday:sunday timeZone:tz];
        [currentTile setTarget:self action:@selector(tile:)];
        
        [self addSubview:self.header];
        [self.tileBox addSubview:currentTile];
        [self addSubview:self.tileBox];
        [self addSubview:self.shadow];
        
        self.backgroundColor = [UIColor grayColor];
        
        self.header.titleView.text = [month monthYearStringWithTimeZone:tz];
        
        // setup actions
        [self.header.rightArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
        [self.header.leftArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
        
        NSMutableArray *ar = [[NSMutableArray alloc] init];
        NSInteger startDateOffset = 0;
        if (!sunday) {
            startDateOffset = 1;
        }
        NSDate *startingDate = [NSDate dateWithTimeIntervalSince1970:3*24*60*60 + startDateOffset * 24*60*60 + 2];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"E"];
        for (NSInteger i = 0; i < 7; ++i) {
            // name of a day of the week of 0 date is Thu
            NSString *str = [dateFormatter stringFromDate:startingDate];
            [ar addObject:str];
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
	NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonthWithTimeZone:self.timeZone] : [currentTile.monthDate previousMonthWithTimeZone:self.timeZone];
	
    NSDateComponents *nextInfo = [nextMonth dateComponentsWithTimeZone:self.timeZone];
	NSDate *localNextMonth = [NSDate dateWithDateComponents:nextInfo];
    
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:nextMonth startOnSunday:sunday timeZone:self.timeZone];
	NSArray *ar = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    
    // TODO correct frame
    TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithFrame:[currentTile frame] month:nextMonth marks:ar startOnSunday:sunday timeZone:self.timeZone];
	[newTile setTarget:self action:@selector(tile:)];
	
	int overlap =  0;
	if(isNext){
		overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : [TKCalendarMonthView headerHeight];
	} else {
		overlap = [currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? [TKCalendarMonthView headerHeight] : 0;
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
	self.header.titleView.text = [localNextMonth monthYearStringWithTimeZone:self.timeZone];
    [self.header setNeedsLayout];
}

- (NSDate*) _dateForMonthChange:(UIView*)sender {
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonthWithTimeZone:self.timeZone] : [currentTile.monthDate previousMonthWithTimeZone:self.timeZone];
	
	NSDateComponents *nextInfo = [nextMonth dateComponentsWithTimeZone:self.timeZone];
	NSDate *localNextMonth = [NSDate dateWithDateComponents:nextInfo];
	
	return localNextMonth;
}

- (void) changeMonth:(UIButton *)sender{
    NSDate *newDate = [self _dateForMonthChange:sender];
	if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] &&
        ![self.delegate calendarMonthView:self monthShouldChange:newDate animated:YES]) {
        return;
    }
	if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)]) {
        [self.delegate calendarMonthView:self monthWillChange:newDate animated:YES];
    }
    
	[self changeMonthAnimation:sender];
    
    if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)]) {
        [self.delegate calendarMonthView:self monthDidChange:currentTile.monthDate animated:YES];
    }
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

- (BOOL) selectDate:(NSDate*)date {
    if(date == nil) date = [NSDate date];
    
    NSDateComponents *info = [date dateComponentsWithTimeZone:self.timeZone];
	NSDate *month = [date firstOfMonthWithTimeZone:self.timeZone];
	
    BOOL ret = NO;
	if([month isEqualToDate:[currentTile monthDate]]){
		ret = [currentTile selectDay:info.day];
	} else {
        if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] &&
            ![self.delegate calendarMonthView:self monthShouldChange:month animated:YES])
        {
            return NO;
        }
		
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] ) {
            [self.delegate calendarMonthView:self monthWillChange:month animated:YES];
        }
        
		NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:month startOnSunday:sunday timeZone:self.timeZone];
		NSArray *data = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
        
        // TODO correct frame
        TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithFrame:[currentTile frame] month:month marks:data startOnSunday:sunday timeZone:self.timeZone];
		[newTile setTarget:self action:@selector(tile:)];
		[currentTile removeFromSuperview];
		currentTile = newTile;
		[self.tileBox addSubview:currentTile];
		self.tileBox.frame = CGRectMake(0, [TKCalendarMonthView headerHeight], newTile.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);

        CGFloat outsideShadowHeight = 21.0f;
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+outsideShadowHeight, self.shadow.frame.size.width, self.shadow.frame.size.height);

	
		self.header.titleView.text = [month monthYearStringWithTimeZone:self.timeZone];
		
		ret = [currentTile selectDay:info.day];
        
        if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)]) {
            [self.delegate calendarMonthView:self monthDidChange:date animated:NO];
        }
	}
    if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)]) {
        [self.delegate calendarMonthView:self didSelectDate:[self dateSelected]];
    }
    
    return ret;
}
- (void) reload {
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:[currentTile monthDate] startOnSunday:sunday timeZone:self.timeZone];
	NSArray *ar = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	
    TKCalendarMonthTiles *refresh = [[TKCalendarMonthTiles alloc] initWithFrame:[currentTile frame] month:[currentTile monthDate] marks:ar startOnSunday:sunday timeZone:self.timeZone];
	[refresh setTarget:self action:@selector(tile:)];
	
	[self.tileBox addSubview:refresh];
	[currentTile removeFromSuperview];
	currentTile = refresh;
}

- (void) tile:(NSArray*)ar{
	if([ar count] < 2){
        if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)]) {
            [self.delegate calendarMonthView:self didSelectDate:[self dateSelected]];
        }
	} else {
		NSInteger direction = [[ar lastObject] intValue];
		UIButton *b = direction > 1 ? self.header.rightArrow : self.header.leftArrow;
		
        NSDate* newMonth = [self _dateForMonthChange:b];
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] &&
            ![self.delegate calendarMonthView:self monthShouldChange:newMonth animated:YES])
        {
            return;
        }
		
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)]) {
            [self.delegate calendarMonthView:self monthWillChange:newMonth animated:YES];
        }
        
		[self changeMonthAnimation:b];
		
		NSInteger day = [[ar objectAtIndex:0] intValue];
        NSDateComponents *info = [[currentTile monthDate] dateComponentsWithTimeZone:self.timeZone];
		info.day = day;
        NSDate *dateForMonth = [NSDate dateWithDateComponents:info];
		if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)]) {
            [self.delegate calendarMonthView:self didSelectDate:dateForMonth];
        }
		if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)]) {
            [self.delegate calendarMonthView:self monthDidChange:dateForMonth animated:YES];
        }
		[currentTile selectDay:day];
	}
	
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    int rows = [TKCalendarMonthView rowsForMonth:[currentTile monthDate]];
    CGFloat height = [TKTile effectiveTileWidthForTilesWidth:CGRectGetWidth(self.bounds)] * rows;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat shadowImageHeight = [shadow image].size.height;
    CGFloat tilesOffset = [TKTile tileStartOffsetForTilesWidth:self.bounds.size.width];

    CGFloat outsideShadowHeight = 21.0f;
    header.frame = CGRectMake(0.0f, 0.0f, width, [TKCalendarMonthView headerHeight]);
    tileBox.frame = CGRectMake(tilesOffset, [TKCalendarMonthView headerHeight], CGRectGetWidth(self.bounds), height);
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
		shadow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/Month Calendar Shadow.png")]];
	}
	return shadow;
}



@end
