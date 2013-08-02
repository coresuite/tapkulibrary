//
//  TKTile.m
//  coresuite-ipad
//
//  Created by Tomasz Krasnyk on 10-12-19.
//  Copyright 2010 coresystems ag. All rights reserved.
//

#import "TKTile.h"
#import "TKGlobal.h"

// iPhone values
//#define dotFontSize 18.0
//#define dateFontSize 22.0

static NSString * const dotStirng = @"•";

static void convertDateLabelRectToDotRect(CGRect *dateLabelRect, UIFont *dotFont, NSString *dotText) {
	CGFloat dotHeight = dotFont.lineHeight;
	(*dateLabelRect).size.height = dotHeight;
	(*dateLabelRect).origin.y = CGRectGetMaxY(*dateLabelRect) - floorf(dotHeight / 5.0f);
}

@interface TKTile()
+ (CGRect) rectForLabelForTileRect:(CGRect) tileRect labelFont:(UIFont *) font;
@end


@implementation TKTile
@synthesize currentDay;
@synthesize dot;

- (void) setShadowOffset:(CGSize) newOffset {
	currentDay.shadowOffset = newOffset;
	dot.shadowOffset = newOffset;
}

- (CGSize) shadowOffset {
	return currentDay.shadowOffset;
}

- (id) initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		// day label
		currentDay = [[UILabel alloc] initWithFrame:self.bounds];
		currentDay.text = @"1";
		currentDay.textColor = [UIColor whiteColor];
		currentDay.backgroundColor = [UIColor clearColor];
		currentDay.font = [TKTile fontForDateLabelForTileRect:frame];
		currentDay.textAlignment = UITextAlignmentCenter;
		currentDay.shadowColor = [UIColor darkGrayColor];
		currentDay.shadowOffset = CGSizeMake(0, -1);
		[self addSubview:currentDay];
		
		dot = [[UILabel alloc] initWithFrame:self.bounds];
		dot.text = dotStirng;
		dot.textColor = [UIColor whiteColor];
		dot.backgroundColor = [UIColor clearColor];
		dot.font = [TKTile fontForDotLabelForTileRect:frame];
		dot.textAlignment = UITextAlignmentCenter;
		dot.shadowColor = [UIColor darkGrayColor];
		dot.shadowOffset = CGSizeMake(0, -1);
		[self addSubview:dot];
	}
	return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	// THIS CODE HAS TO BE IN SYNC with method +drawTileInRect:day:mark:font:font2:
	// this piece is responsible for selected tile which is UIView, other tiles are drawn
	
    currentDay.font = [TKTile fontForDateLabelForTileRect:self.bounds];
    dot.font = [TKTile fontForDotLabelForTileRect:self.bounds];
    
	CGRect r = self.bounds;
	CGFloat fDrawingAndUIViewPositioningDifference = 1.0f; // diference between drawn text and label of the same frame
	
	// label
	CGRect rectForDay = [TKTile rectForLabelForTileRect:r labelFont:currentDay.font];
	rectForDay.origin.y += fDrawingAndUIViewPositioningDifference;		
	currentDay.frame = rectForDay;
	rectForDay.origin.y -= fDrawingAndUIViewPositioningDifference;
	
	// dot
	convertDateLabelRectToDotRect(&rectForDay, dot.font, dot.text);
	rectForDay.origin.y += fDrawingAndUIViewPositioningDifference;
	dot.frame = rectForDay;
}

+ (NSString *) stringFromDayNumber:(int) day {
    static NSNumberFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSNumberFormatter alloc] init];
    }
    return [formatter stringFromNumber:@(day)];
}

+ (void) drawTileInRect:(CGRect)tileRect day:(int)day mark:(BOOL)mark font:(UIFont*)f1 font2:(UIFont*)f2 context:(CGContextRef)context {
	NSString *str = [TKTile stringFromDayNumber:day];
	
	CGRect r = [TKTile rectForLabelForTileRect:tileRect labelFont:f1];
	
    //TODO: new line!
    CGContextSetPatternPhase(context, CGSizeMake(r.origin.x, r.origin.y - 2));
    
	[str drawInRect: r
		   withFont: f1
	  lineBreakMode: UILineBreakModeWordWrap 
		  alignment: UITextAlignmentCenter];
	
	if(mark){
		convertDateLabelRectToDotRect(&r, f2, dotStirng);
		
		[dotStirng drawInRect:r
				withFont: f2
		   lineBreakMode: UILineBreakModeWordWrap 
			   alignment: UITextAlignmentCenter];
	}
}

+ (UIImage *) imageForTileType:(TKTileType) tileType {
	UIImage *imageToReturn = [UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/Month Calendar Date Tile.png")]; // not selected
	if (tileType == TKTileTypeSelected) {
		imageToReturn = [UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/Month Calendar Date Tile Selected.png")];
	} else if (tileType == TKTileTypeSelectedToday) {
		imageToReturn = [UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/Month Calendar Today Selected Tile.png")];
	} else if (tileType == TKTileTypeDarken) {
		imageToReturn = [UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/Month Calendar Date Tile Gray.png")];
	} else if(tileType == TKTileTypeToday) {
		imageToReturn = [UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/Month Calendar Today Tile.png")];
	}


	return imageToReturn;
}

#pragma mark -
#pragma mark Private 

+ (CGRect) rectForLabelForTileRect:(CGRect) tileRect labelFont:(UIFont *) font {
	CGFloat textHeight = font.lineHeight;
	CGFloat y = floorf((CGRectGetHeight(tileRect) - textHeight) / 2.0f) - floorf(textHeight / 9.0f);
	return CGRectMake(CGRectGetMinX(tileRect), CGRectGetMinY(tileRect) + y, CGRectGetWidth(tileRect), textHeight);
}

+ (UIFont *) fontForDateLabelForTileRect:(CGRect) tileRect {
	CGFloat tileheight = CGRectGetHeight(tileRect);
	return [UIFont boldSystemFontOfSize:floorf(tileheight / 2.0f)];
}

+ (UIFont *) fontForDotLabelForTileRect:(CGRect) tileRect {
	CGFloat tileheight = CGRectGetHeight(tileRect);
	return [UIFont boldSystemFontOfSize:floorf(tileheight / 2.5f)];
}

@end
