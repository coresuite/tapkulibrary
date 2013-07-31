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
#import <objc/message.h>


@interface TKCalendarMonthTiles (private)

@property (readonly) TKTile *selectedImageView;
//@property (readonly) UILabel *currentDay;
//@property (readonly) UILabel *dot;
@end

@implementation TKCalendarMonthTiles
@synthesize monthDate;
@synthesize visibleDayRows;

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

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday{
	
	NSDate *firstDate, *lastDate;
	
	TKDateInformation info = [date dateInformation];
	info.day = 1;
	NSDate *d = [NSDate dateFromDateInformation:info];
	info = [d dateInformation];
	
	if((sunday && info.weekday>1) || (!sunday && info.weekday!=2)){
		TKDateInformation info2 = info;
		

		info2.month--;
		if(info2.month<1) { info2.month = 12; info2.year--; }
		NSDate *previousMonth = [NSDate dateFromDateInformation:info2];
		int preDayCnt = [previousMonth daysInMonth];		
		info2.day = preDayCnt - info.weekday;
		if (sunday) {
			info2.day += 2;
		} else {
			if (info.weekday == 1) {
				info2.day -= 4;
			} else {
				info2.day += 3;
			}
		}
		
		firstDate = [NSDate dateFromDateInformation:info2];
		
		
		
	}else{
		firstDate = d;
	}
	
	
	
	
	int daysInMonth = [d daysInMonth];
	info.day = daysInMonth;
	NSDate *lastInMonth = [NSDate dateFromDateInformation:info];
	info = [lastInMonth dateInformation];
	
	if((sunday && info.weekday < 7) || (!sunday && info.weekday != 1)){
		if (sunday) {
			info.day = 7 - info.weekday;
		}
		else {
			info.day = 7 - info.weekday + 1;
		}
		info.month++;
		if(info.month>12){
			info.month = 1;
			info.year++;
		}
		lastDate = [NSDate dateFromDateInformation:info];
	}else{
		lastDate = lastInMonth;
	}
	
	return [NSArray arrayWithObjects:firstDate,lastDate,nil];
}

+ (int) rowsForMonth:(NSDate *) date startDayOnSunday:(BOOL) sunday {
    int firstOfPrev = -1;
    
	TKDateInformation dateInfo = [date dateInformation];
	int firstWeekday = dateInfo.weekday;
	int daysInMonth = [date daysInMonth];
    int lastOfPrev = 0;
	
	
	if((sunday && firstWeekday>1) || (!sunday && firstWeekday!=2)){
		dateInfo.month--;
		if(dateInfo.month<1) {
			dateInfo.month = 12;
			dateInfo.year--;
		}
		NSDate *previousMonth = [NSDate dateFromDateInformation:dateInfo];
		
		int preDayCnt = [previousMonth daysInMonth];
		firstOfPrev = preDayCnt - firstWeekday;
		if (sunday) {
			firstOfPrev += 2;
		} else {
			if (firstWeekday == 1) {
				firstOfPrev -= 4;
			} else {
				firstOfPrev += 3;
			}
		}
		
		lastOfPrev = preDayCnt;
	}
	
	int prevDays = (firstOfPrev == -1 ? 0 : lastOfPrev - firstOfPrev + 1);
	int row = daysInMonth + prevDays;
	row = (row / 7) + ((row % 7 == 0) ? 0:1);
    
    return row;
}

- (id) initWithFrame:(CGRect)frame month:(NSDate *) date marks:(NSArray *) markArray startOnSunday:(BOOL) sunday {
    if ((self = [super initWithFrame:frame])) {
        self.contentMode = UIViewContentModeRedraw;
        firstOfPrev = -1;
        marks = markArray;
        monthDate = date;
        startOnSunday = sunday;
		
        TKDateInformation dateInfo = [monthDate dateInformation];
        firstWeekday = dateInfo.weekday;
        daysInMonth = [date daysInMonth];
        
        
        TKDateInformation todayInfo = [[NSDate date] dateInformation];
        today = (dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year) ? todayInfo.day : 0;
        
        
        if((sunday && firstWeekday>1) || (!sunday && firstWeekday!=2)){
            dateInfo.month--;
            if(dateInfo.month<1) {
                dateInfo.month = 12;
                dateInfo.year--;
            }
            NSDate *previousMonth = [NSDate dateFromDateInformation:dateInfo];
            
            int preDayCnt = [previousMonth daysInMonth];
            firstOfPrev = preDayCnt - firstWeekday;
            if (sunday) {
                firstOfPrev += 2;
            } else {
                if (firstWeekday == 1) {
                    firstOfPrev -= 4;
                } else {
                    firstOfPrev += 3;
                }
            }
            
            lastOfPrev = preDayCnt;
        }
        
        int prevDays = (firstOfPrev == -1 ? 0 : lastOfPrev - firstOfPrev + 1);
        int row = daysInMonth + prevDays;
        row = (row / 7) + ((row % 7 == 0) ? 0:1);
        
        visibleDayRows = row;
        
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
	
	int index = 0;

	UIColor *color = [UIColor grayColor];
	
	if(firstOfPrev>0){
		[color set];
		for(int i = firstOfPrev;i<= lastOfPrev;i++){
			r = [self rectForCellAtIndex:index tileWidth:self.tileWidth tileHeight:tileHeight];
			[TKTile drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] font:dateFont font2:dotFont];
			index++;
		}
	}
	

	color = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	[color set];
	for(int i=1; i <= daysInMonth; i++){
		
		r = [self rectForCellAtIndex:index tileWidth:self.tileWidth tileHeight:tileHeight];
		if(today == i) [[UIColor whiteColor] set];
	
		[TKTile drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] font:dateFont font2:dotFont];
		if(today == i) [color set];
		index++;
	}
	
	[[UIColor grayColor] set];
	int i = 1;
	while(index % 7 != 0){
		r = [self rectForCellAtIndex:index tileWidth:self.tileWidth tileHeight:tileHeight];
		[TKTile drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] font:dateFont font2:dotFont];
		i++;
		index++;
	}
		
	
}

- (void) selectDay:(int)day{
	int pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
	
	int tot = day + pre;
	int row = tot / 7;
	int column = (tot % 7)-1;
	
	selectedDay = day;
	selectedPortion = 1;
	

	if(day == today){
		self.selectedImageView.shadowOffset = CGSizeMake(0, 1);
		self.selectedImageView.image = [TKTile imageForTileType:TKTileTypeSelectedToday];
		markWasOnToday = YES;
	} else if (markWasOnToday) {
		self.selectedImageView.shadowOffset = CGSizeMake(0, -1);
		self.selectedImageView.image = [TKTile imageForTileType:TKTileTypeSelected];
		markWasOnToday = NO;
	}
	
	[self addSubview:self.selectedImageView];
	self.selectedImageView.currentDay.text = [NSString stringWithFormat:@"%d", day];
	self.selectedImageView.dot.hidden = ![[marks objectAtIndex: row * 7 + column ] boolValue];
	
	if(column < 0){
		column = 6;
		row--;
	}
    selectedBox = [NSIndexPath indexPathForRow:row inSection:column];
	self.selectedImageView.frame = [self rectForTileAtIndexPath:selectedBox];
}

- (NSDate*) dateSelected {
	if(selectedDay < 1 || selectedPortion != 1) return nil;
	
	TKDateInformation info = [monthDate dateInformation];
	info.day = selectedDay;
	return [NSDate dateFromDateInformation:info];
}

- (void) reactToTouch:(UITouch*)touch down:(BOOL)down {
	CGPoint p = [touch locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;
	
	int column = p.x / self.tileWidth, row = p.y / self.tileHeight;
	int day = 1, portion = 0;
    column = column < 0 ? 0 : column;
    row = row < 0 ? 0 : row;
	
	if(row == (int) (self.bounds.size.height / self.tileHeight)) row --;
	
	day = row * 7 + column  - firstWeekday+(startOnSunday ? 2 : (firstWeekday == 1 ? -4 : 3));
	
	if (row==0 && day < 1) {
		day = firstOfPrev + column;
	} else {
		portion = 1;
	}
	if (portion > 0 && day > daysInMonth) {
		portion = 2;
		day = day - daysInMonth;
	}
	
	if(portion != 1){
		self.selectedImageView.image = [TKTile imageForTileType:TKTileTypeDarken];
		markWasOnToday = YES;
	} else if(portion==1 && day == today) {
		self.selectedImageView.shadowOffset = CGSizeMake(0, 1);
		self.selectedImageView.image = [TKTile imageForTileType:TKTileTypeSelectedToday];
		markWasOnToday = YES;
	} else if(markWasOnToday) {
		self.selectedImageView.shadowOffset = CGSizeMake(0, -1);
		self.selectedImageView.image = [TKTile imageForTileType:TKTileTypeSelected];
		markWasOnToday = NO;
	}
	
	[self addSubview:self.selectedImageView];
	self.selectedImageView.currentDay.text = [NSString stringWithFormat:@"%d", day];
	self.selectedImageView.dot.hidden = ![[marks objectAtIndex: row * 7 + column] boolValue];
	
    selectedBox = [NSIndexPath indexPathForRow:row inSection:column];
	self.selectedImageView.frame = [self rectForTileAtIndexPath:selectedBox];;
	
	if (day == selectedDay && selectedPortion == portion) return;
	
	
	
	if (portion == 1){
		selectedDay = day;
		selectedPortion = portion;
        objc_msgSend(target, action, [NSArray arrayWithObject:[NSNumber numberWithInt:day]]);

	} else if(down){
        objc_msgSend(target, action, [NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil]);
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
		selectedImageView.image = [TKTile imageForTileType:TKTileTypeSelected];
	}
	return selectedImageView;
}



@end
