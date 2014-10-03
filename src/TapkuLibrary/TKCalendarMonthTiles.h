//
//  TKCalendarMonthView.h
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

#import <UIKit/UIKit.h>
#import "TKCalendarMonthTiles.h"
#import "TKTile.h"


@interface TKCalendarMonthTiles : UIView {
	
	id __weak target;
	SEL action;
	
	NSInteger firstOfPrev,lastOfPrev;
	NSArray *marks;
	NSInteger today;
	BOOL markWasOnToday;
	
	NSInteger selectedDay,selectedPortion;
	
	NSInteger firstWeekday, daysInMonth;
	TKTile *selectedImageView;
	BOOL startOnSunday;
	NSDate *monthDate;
    NSInteger visibleDayRows;
    NSIndexPath *selectedBox;
}
@property (readonly) NSInteger visibleDayRows;
@property (readonly) NSDate *monthDate;
@property (readonly) TKTile *selectedImageView;
@property (nonatomic, strong) NSArray *datesArray;
@property (nonatomic, strong) NSMutableArray *accessibleElements;
@property (nonatomic, strong) NSTimeZone *timeZone;
@property (nonatomic, strong) NSArray *marks;

- (id) initWithFrame:(CGRect)frame month:(NSDate *)date marks:(NSArray *)markArray startOnSunday:(BOOL) sunday timeZone:(NSTimeZone*)timeZone;
- (void) setTarget:(id)target action:(SEL)action;

- (BOOL) selectDay:(NSInteger)day;
- (NSDate *) dateSelected;

+ (NSArray *) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday;
+ (NSArray *) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday timeZone:(NSTimeZone*)timeZone;

+ (NSUInteger) rowsForMonth:(NSDate *) date startDayOnSunday:(BOOL) sunday timeZone:(NSTimeZone*)timeZone;

@end
