//
//  TKCalendarMonthView.m
//  Created by Devin Ross on 6/9/10.
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

#import "TKCalendarMonthTiles.h"
#import "TKGlobal.h"
#import "NSDate+CalendarGrid.h"
#import "NSDate+TKCategory.h"
#import <objc/message.h>

@interface NSArray(TKCalendarExtensions)
- (BOOL) isMarkAtIndex:(NSUInteger) index;
@end

@implementation NSArray(TKCalendarExtensions)

- (BOOL) isMarkAtIndex:(NSUInteger) index {
    BOOL mark = NO;
    NSUInteger count = [self count];
    if (count > 0 && index < count) {
        mark = [self[index] boolValue];
    }
    return mark;
}

@end


@interface TKCalendarMonthTiles (private)
@property (readonly) TKTile *selectedImageView;
@end

@implementation TKCalendarMonthTiles {
    UIColor *gradientColor;
    UIColor *grayGradientColor;
}
@synthesize monthDate;
@synthesize visibleDayRows;

#pragma mark Accessibility Container methods

- (BOOL) isAccessibilityElement{
    return NO;
}

- (NSArray *) accessibleElements{
    if (_accessibleElements!=nil) return _accessibleElements;
    
    _accessibleElements = [[NSMutableArray alloc] init];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateStyle:NSDateFormatterFullStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	[formatter setTimeZone:self.timeZone];
	
	NSDate *firstDate = (self.datesArray)[0];
	
	for(NSInteger i=0; i < marks.count; i++){
		UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
		
		NSDate *day = [NSDate dateWithTimeIntervalSinceReferenceDate:[firstDate timeIntervalSinceReferenceDate]+(24*60*60*i)+5];
		element.accessibilityLabel = [formatter stringForObjectValue:day];
		
		CGRect r = [self convertRect:[self rectForCellAtIndex:i tileWidth:self.tileWidth tileHeight:[self tileHeight]]
                              toView:self.window];
		r.origin.y -= 6;
		
		element.accessibilityFrame = r;
		element.accessibilityTraits = UIAccessibilityTraitButton;
		element.accessibilityValue = [(marks)[i] boolValue] ? @"Has Events" : @"No Events";
		[_accessibleElements addObject:element];
	}
	
    return _accessibleElements;
}
- (NSInteger) accessibilityElementCount{
    return [self accessibleElements].count;
}
- (id) accessibilityElementAtIndex:(NSInteger)index{
    return [self accessibleElements][index];
}
- (NSInteger) indexOfAccessibilityElement:(id)element{
    return [[self accessibleElements] indexOfObject:element];
}

#pragma mark - Measurements

- (CGFloat) tileWidth {
    return CGRectGetWidth(self.bounds) / 7.0f;
}

- (CGFloat) tileHeight {
    return floorf(CGRectGetHeight(self.bounds) / visibleDayRows);
}

- (CGRect) rectForTileAtIndexPath:(NSIndexPath *) indexPath {
	CGFloat x = (indexPath.section * self.tileWidth);
	CGFloat y = (indexPath.row * self.tileHeight)-1;
    return CGRectMake(x, y, self.tileWidth, self.tileHeight);
}

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday {
    return [self rangeOfDatesInMonthGrid:date startOnSunday:sunday timeZone:[NSTimeZone defaultTimeZone]];
}

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday timeZone:(NSTimeZone*)timeZone {
    NSDate *firstDate, *lastDate;
	NSDateComponents *info = [date dateComponentsWithTimeZone:timeZone];
	
	info.day = 1; info.hour = info.minute = info.second = 0;
	
	NSDate *currentMonth = [NSDate dateWithDateComponents:info];
	info = [currentMonth dateComponentsWithTimeZone:timeZone];
	
	NSDate *previousMonth = [currentMonth previousMonthWithTimeZone:timeZone];
	NSDate *nextMonth = [currentMonth nextMonthWithTimeZone:timeZone];
	
	if(info.weekday > 1 && sunday){
		NSDateComponents *info2 = [previousMonth dateComponentsWithTimeZone:timeZone];
		
		NSInteger preDayCnt = [previousMonth daysBetweenDate:currentMonth];
		info2.day = preDayCnt - info.weekday + 2;
		firstDate = [NSDate dateWithDateComponents:info2];
	} else if(!sunday && info.weekday != 2){
		NSDateComponents *info2 = [previousMonth dateComponentsWithTimeZone:timeZone];
		NSInteger preDayCnt = [previousMonth daysBetweenDate:currentMonth];
		if(info.weekday==1){
			info2.day = preDayCnt - 5;
		} else {
			info2.day = preDayCnt - info.weekday + 3;
		}
		firstDate = [NSDate dateWithDateComponents:info2];
	} else {
		firstDate = currentMonth;
	}
	
	NSInteger daysInMonth = [currentMonth daysBetweenDate:nextMonth];
	info.day = daysInMonth;
	NSDate *lastInMonth = [NSDate dateWithDateComponents:info];
	NSDateComponents *lastDateInfo = [lastInMonth dateComponentsWithTimeZone:timeZone];
	
	if(lastDateInfo.weekday < 7 && sunday){
		lastDateInfo.day = 7 - lastDateInfo.weekday;
		lastDateInfo.month++;
		lastDateInfo.weekday = 0;
		if(lastDateInfo.month>12){
			lastDateInfo.month = 1;
			lastDateInfo.year++;
		}
		lastDate = [NSDate dateWithDateComponents:lastDateInfo];
        
	} else if (!sunday && lastDateInfo.weekday != 1){
		
		
		lastDateInfo.day = 8 - lastDateInfo.weekday;
		lastDateInfo.month++;
		if(lastDateInfo.month > 12){
            lastDateInfo.month = 1; lastDateInfo.year++;
        }
		lastDate = [NSDate dateWithDateComponents:lastDateInfo];
        
	} else {
		lastDate = lastInMonth;
	}
	
	return @[firstDate,lastDate];
}

+ (NSUInteger) rowsForMonth:(NSDate *) date startDayOnSunday:(BOOL) sunday timeZone:(NSTimeZone*)timeZone {    
    NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:date startOnSunday:sunday timeZone:timeZone];
    
    NSUInteger numberOfDaysBetween = [dates[0] daysBetweenDate:[dates lastObject]];
    NSUInteger rows = (numberOfDaysBetween / 7) + 1;
    return rows;
}

- (id) initWithFrame:(CGRect)frame month:(NSDate *)date marks:(NSArray*)markArray startOnSunday:(BOOL)sunday timeZone:(NSTimeZone*)timeZone
{
    if ((self = [super initWithFrame:frame])) {
        gradientColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/color_gradient.png")]];
		grayGradientColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/color_gradient_gray.png")]];
        
        self.contentMode = UIViewContentModeRedraw;
        self.timeZone = timeZone;
        firstOfPrev = -1;
        marks = markArray;
        monthDate = date;
        startOnSunday = sunday;
		
        NSDateComponents *dateInfo = [self.monthDate dateComponentsWithTimeZone:self.timeZone];
        firstWeekday = dateInfo.weekday;
        NSDate *prev = [self.monthDate previousMonthWithTimeZone:self.timeZone];
        daysInMonth = [[self.monthDate nextMonthWithTimeZone:self.timeZone] daysBetweenDate:self.monthDate];
        
        NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:date startOnSunday:sunday timeZone:self.timeZone];
        self.datesArray = dates;
        
        NSDateComponents *todayInfo = [[NSDate date] dateComponentsWithTimeZone:self.timeZone];
        today = dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year ? todayInfo.day : -5;
        
        NSInteger preDayCnt = [prev daysBetweenDate:self.monthDate];
        if(firstWeekday>1 && sunday){
            firstOfPrev = preDayCnt - firstWeekday+2;
            lastOfPrev = preDayCnt;
        } else if (!sunday && firstWeekday != 2){
            if(firstWeekday ==1){
                firstOfPrev = preDayCnt - 5;
            } else {
                firstOfPrev = preDayCnt - firstWeekday+3;
            }
            lastOfPrev = preDayCnt;
        }
        NSUInteger numberOfDaysBetween = [dates[0] daysBetweenDate:[dates lastObject]];
        NSUInteger rows = (numberOfDaysBetween / 7) + 1;
        
        visibleDayRows = rows;
        
        self.multipleTouchEnabled = NO;
        
        return self;
    }
    return self;
}

- (void) setTarget:(id)t action:(SEL)a{
	target = t;
	action = a;
}

- (CGRect) rectForCellAtIndex:(int)index tileWidth:(CGFloat) width tileHeight:(CGFloat) height {
	int row = index / 7;
	int col = index % 7;
	
	return CGRectMake(col * width, row * height, width, height);
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    selectedImageView.frame = [self rectForTileAtIndexPath:selectedBox];
}

- (void) drawRect:(CGRect)rect {
    CGFloat tileHeight = [self tileHeight];
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIImage *tile = [TKTile imageForTileType:TKTileTypeNotSelected];
	CGRect r = CGRectMake(0, 0, self.tileWidth, tileHeight);
	CGContextDrawTiledImage(context, r, tile.CGImage);
	UIFont *dateFont = [TKTile fontForDateLabelForTileRect:r];
	UIFont *dotFont =[TKTile fontForDotLabelForTileRect:r];
	
	if(today > 0){
		int pre = firstOfPrev > 0 ? lastOfPrev - firstOfPrev + 1 : 0;
		int index = today +  pre-1;
		CGRect r = [self rectForCellAtIndex:index tileWidth:self.tileWidth tileHeight:tileHeight];
		r.origin.y -= 1.0f;
		[[TKTile imageForTileType:TKTileTypeToday] drawInRect:r];
	}
	
    float myColorValues[] = {1, 1, 1, .8};
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef whiteColor = CGColorCreate(myColorSpace, myColorValues);
	CGContextSetShadowWithColor(context, CGSizeMake(0,1), 0, whiteColor);
    
	float darkColorValues[] = {0, 0, 0, .5};
    CGColorRef darkColor = CGColorCreate(myColorSpace, darkColorValues);
    
    int index = 0;
	UIColor *color = grayGradientColor;
	if(firstOfPrev > 0){
		[color set];
		for(int i = firstOfPrev;i<= lastOfPrev;i++){
			r = [self rectForCellAtIndex:index tileWidth:self.tileWidth tileHeight:tileHeight];
			[TKTile drawTileInRect:r day:i mark:[marks isMarkAtIndex:index] font:dateFont font2:dotFont context:context];
			index++;
		}
	}
	
	color = gradientColor;
	[color set];
	for(int i=1; i <= daysInMonth; i++){
		r = [self rectForCellAtIndex:index tileWidth:self.tileWidth tileHeight:tileHeight];
		if(today == i) {
            CGContextSetShadowWithColor(context, CGSizeMake(0,-1), 0, darkColor);
			[[UIColor whiteColor] set];
        }
		[TKTile drawTileInRect:r day:i mark:[marks isMarkAtIndex:index] font:dateFont font2:dotFont context:context];
		if(today == i){
			CGContextSetShadowWithColor(context, CGSizeMake(0,1), 0, whiteColor);
			[color set];
		}
		index++;
	}
	
	[grayGradientColor set];
	NSInteger i = 1;
	while(index % 7 != 0){
		r = [self rectForCellAtIndex:index tileWidth:self.tileWidth tileHeight:tileHeight];
		[TKTile drawTileInRect:r day:i mark:[marks isMarkAtIndex:index] font:dateFont font2:dotFont context:context];
		i++;
		index++;
	}
}

- (BOOL) selectDay:(NSInteger)day{
	int pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
	
	int tot = day + pre;
	int row = tot / 7;
	int column = (tot % 7)-1;
	
	selectedDay = day;
	selectedPortion = 1;
	
	if(day == today){
		self.selectedImageView.shadowOffset = CGSizeMake(0, -1);
		self.selectedImageView.image = [TKTile imageForTileType:TKTileTypeSelectedToday];
		markWasOnToday = YES;
	} else if (markWasOnToday) {
		self.selectedImageView.shadowOffset = CGSizeMake(0, -1);
		self.selectedImageView.image = [TKTile imageForTileType:TKTileTypeSelected];
		markWasOnToday = NO;
	}
	
	[self addSubview:self.selectedImageView];
	self.selectedImageView.currentDay.text = [TKTile stringFromDayNumber:@(day)];
    BOOL hasDot = [[marks objectAtIndex: row * 7 + column ] boolValue];
	self.selectedImageView.dot.hidden = !hasDot;
    
    if(column < 0){
		column = 6;
		row--;
	}
    selectedBox = [NSIndexPath indexPathForRow:row inSection:column];
	self.selectedImageView.frame = [self rectForTileAtIndexPath:selectedBox];
    return hasDot;
}

- (NSDate*) dateSelected {
	if(selectedDay < 1 || selectedPortion != 1) return nil;
	
	NSDateComponents *info = [monthDate dateComponentsWithTimeZone:self.timeZone];
	info.hour = 0; info.minute = 0; info.second = 0;
	info.day = selectedDay;
	NSDate *d = [NSDate dateWithDateComponents:info];

	return d;
}

- (void) reactToTouch:(UITouch*)touch down:(BOOL)down {
	CGPoint p = [touch locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;
    if(p.x > self.bounds.size.width || p.x < 0) return;
	
	NSInteger column = p.x / self.tileWidth, row = p.y / self.tileHeight;
	NSInteger day = 1, portion = 0;
	
	if(row == (int) (self.bounds.size.height / self.tileHeight)) row--;
	
    NSInteger fir = firstWeekday - 1;
    if(!startOnSunday && fir == 0) fir = 7;
	if(!startOnSunday) fir--;
    if(row == 0 && column < fir){
		day = firstOfPrev + column;
	} else {
		portion = 1;
		day = row * 7 + column  - firstWeekday+2;
		if(!startOnSunday) day++;
		if(!startOnSunday && fir==6) day -= 7;
        
	}
	if(portion > 0 && day > daysInMonth){
		portion = 2;
		day = day - daysInMonth;
	}
	
	if(portion != 1){
		self.selectedImageView.image = [TKTile imageForTileType:TKTileTypeDarken];
        self.selectedImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
		markWasOnToday = YES;
	} else if(portion==1 && day == today) {
		self.selectedImageView.shadowOffset = CGSizeMake(0, -1);
		self.selectedImageView.image = [TKTile imageForTileType:TKTileTypeSelectedToday];
		markWasOnToday = YES;
	} else if(markWasOnToday) {
		self.selectedImageView.shadowOffset = CGSizeMake(0, -1);
		self.selectedImageView.image = [TKTile imageForTileType:TKTileTypeSelected];
		markWasOnToday = NO;
	}
	
	[self addSubview:self.selectedImageView];
	self.selectedImageView.currentDay.text = [TKTile stringFromDayNumber:@(day)];
	self.selectedImageView.dot.hidden = ![[marks objectAtIndex: row * 7 + column] boolValue];
	
    selectedBox = [NSIndexPath indexPathForRow:row inSection:column];
	self.selectedImageView.frame = [self rectForTileAtIndexPath:selectedBox];
	
	if (day == selectedDay && selectedPortion == portion) return;
	
	
	
	if (portion == 1){
		selectedDay = day;
		selectedPortion = portion;
        objc_msgSend(target, action, @[@(day)]);

	} else if(down){
        objc_msgSend(target, action, @[@(day),@(portion)]);
		selectedDay = day;
		selectedPortion = portion;
	}

}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	//[super touchesBegan:touches withEvent:event];
	[self reactToTouch:[touches anyObject] down:NO];
} 
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[self reactToTouch:[touches anyObject] down:NO];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[self reactToTouch:[touches anyObject] down:YES];
}

- (TKTile *) selectedImageView {
	if(selectedImageView==nil){
		selectedImageView = [[TKTile alloc] initWithFrame:CGRectZero];
        selectedImageView.layer.magnificationFilter = kCAFilterNearest;
		selectedImageView.image = [TKTile imageForTileType:TKTileTypeSelected];
	}
	return selectedImageView;
}



@end
