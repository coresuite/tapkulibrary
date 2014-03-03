//
//  TKCalendarMonthView.h
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
#import <UIKit/UIKit.h>
#import "TKCalendarMonthViewHeader.h"

@class TKCalendarMonthTiles;
@class TKCalendarMonthViewHeader;
@protocol TKCalendarMonthViewDelegate, TKCalendarMonthViewDataSource, TKCalendarMonthViewSizeDelegate;


@interface TKCalendarMonthView : UIView {
	TKCalendarMonthTiles *currentTile,*oldTile;
	UIImageView *shadow;
	UIScrollView *tileBox;
	BOOL sunday;

	id <TKCalendarMonthViewDelegate> __weak delegate;
	id <TKCalendarMonthViewDataSource> __weak dataSource;
	id <TKCalendarMonthViewSizeDelegate> __weak sizeDelegate;
}
@property (nonatomic, strong) NSTimeZone *timeZone;
@property (nonatomic)   TKCalendarMonthViewHeader *header;
@property (nonatomic, strong, readonly) TKCalendarMonthTiles *oldTile;
@property (nonatomic,weak) id <TKCalendarMonthViewDelegate> delegate;
@property (nonatomic,weak) id <TKCalendarMonthViewDataSource> dataSource;
@property (nonatomic,weak) id <TKCalendarMonthViewSizeDelegate> sizeDelegate;

- (id) initWithSundayAsFirst:(BOOL)sunday; // it sunday regardless right now...
- (id) initWithFrame:(CGRect) aFrame sundayAsFirst:(BOOL) s;
- (id) initWithFrame:(CGRect) aFrame sundayAsFirst:(BOOL) s timeZone:(NSTimeZone*)tz;

- (NSDate*) dateSelected;
- (NSDate*) monthDate;
- (BOOL) selectDate:(NSDate*)date;
- (void) reload;

- (CGFloat) maximumHeight;

+ (CGFloat) headerHeight;
+ (NSUInteger) rowsForMonth:(NSDate *) date;
+ (NSUInteger) rowsForMonth:(NSDate *) date timeZone:(NSTimeZone *) timeZone;
+ (CGFloat) effectiveTilesHeightForMonth:(NSDate *) month availableRect:(CGRect) rect;
+ (CGFloat) effectiveTilesHeightForMonth:(NSDate *) month timeZone:(NSTimeZone *)tz availableRect:(CGRect) rect;
@end


@protocol TKCalendarMonthViewDelegate <NSObject>

@optional
/** The highlighed date changed.
 @param monthView The calendar month view.
 @param date The highlighted date.
 */
- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date;


/** The calendar should change the current month to grid shown.
 @param monthView The calendar month view.
 @param month The month date.
 @param animated Animation flag
 @return YES if the month should change. NO otherwise
 */
- (BOOL) calendarMonthView:(TKCalendarMonthView*)monthView monthShouldChange:(NSDate*)month animated:(BOOL)animated;

/** The calendar will change the current month to grid shown.
 @param monthView The calendar month view.
 @param month The month date.
 @param animated Animation flag
 */
- (void) calendarMonthView:(TKCalendarMonthView*)monthView monthWillChange:(NSDate*)month animated:(BOOL)animated;

/** The calendar did change the current month to grid shown.
 @param monthView The calendar month view.
 @param month The month date.
 @param animated Animation flag
 */
- (void) calendarMonthView:(TKCalendarMonthView*)monthView monthDidChange:(NSDate*)month animated:(BOOL)animated;

@end

@protocol TKCalendarMonthViewDataSource <NSObject>

- (NSArray*) calendarMonthView:(UIView *)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate;

@end

@protocol TKCalendarMonthViewSizeDelegate <NSObject>

/** A data source that will correspond to marks for the calendar month grid for a particular month.
 @param monthView The calendar month grid.
 @param startDate The first date shown by the calendar month grid.
 @param lastDate The last date shown by the calendar month grid.
 @return Returns an array of NSNumber objects corresponding the number of days specified in the start and last day parameters. Each NSNumber variable will give a BOOL value that will be used to display a dot under the day.
 */
- (void) calendarMonthView:(UIView *) monthView willAnimateToFrame:(CGRect) rect animationDuration:(NSTimeInterval) interval;
@end