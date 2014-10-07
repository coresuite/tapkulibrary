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

#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)

static NSString * const separatorColorKey = @"sepColor";
static NSString * const dotColor = @"dotColor";
static NSString * const selectionBgColor = @"bgColor";
static NSString * const dotStirng = @"•";
static NSMutableDictionary *appearanceInfo = nil;
static void correctYofLabelForIOS7(CGRect *dayRect, BOOL invert) {
    if (invert) {
        dayRect->origin.y = dayRect->origin.y + 4.0f;
    } else {
        dayRect->origin.y = dayRect->origin.y - 4.0f;
    }
}

static void correctYofDotForIOS7(CGRect *dotRect, BOOL invert) {
    if (invert) {
        dotRect->origin.y = dotRect->origin.y - 4.0f;
    } else {
        dotRect->origin.y = dotRect->origin.y + 4.0f;
    }
}

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
//	currentDay.shadowOffset = newOffset;
//	dot.shadowOffset = newOffset;
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
//		currentDay.shadowColor = [UIColor darkGrayColor];
//		currentDay.shadowOffset = CGSizeMake(0, -1);
		[self addSubview:currentDay];
		
		dot = [[UILabel alloc] initWithFrame:self.bounds];
		dot.text = dotStirng;
		dot.textColor = [UIColor whiteColor];
		dot.backgroundColor = [UIColor clearColor];
		dot.font = [TKTile fontForDotLabelForTileRect:frame];
		dot.textAlignment = UITextAlignmentCenter;
//		dot.shadowColor = [UIColor darkGrayColor];
//		dot.shadowOffset = CGSizeMake(0, -1);
        
        if (appearanceInfo == nil) {
            appearanceInfo = [[NSMutableDictionary alloc] init];
        }
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
	
	// label
	CGRect rectForDay = [TKTile rectForLabelForTileRect:r labelFont:currentDay.font];
    correctYofLabelForIOS7(&rectForDay, NO);
	currentDay.frame = rectForDay;
	
	// dot
	convertDateLabelRectToDotRect(&rectForDay, dot.font, dot.text);
	dot.frame = rectForDay;
}

+ (NSString *) stringFromDayNumber:(NSInteger) day {
    static NSNumberFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSNumberFormatter alloc] init];
    }
    return [formatter stringFromNumber:@(day)];
}

+ (void) drawTileInRect:(CGRect)tileRect day:(NSInteger)day mark:(BOOL)mark font:(UIFont*)f1 font2:(UIFont*)f2 context:(CGContextRef)context
                isToday:(BOOL) isToday isOtherMonthDay:(BOOL)isOtherMonthDay
{
    NSString *str = [TKTile stringFromDayNumber:day];
    
    CGRect r = [TKTile rectForLabelForTileRect:tileRect labelFont:f1];
    
    CGFloat heightCorrection = -2;
    if (r.size.height >= 27.0f) {
        heightCorrection = 4;
    }
    TKTileType type = TKTileTypeNotSelected;
    
    if (isToday) {
        type = TKTileTypeToday;
    } else if (isOtherMonthDay) {
        type = TKTileTypeDarken;
    }
    UIColor *fillColor = [appearanceInfo objectForKey:[NSString stringWithFormat:@"%d", type]];
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    
    correctYofLabelForIOS7(&r, NO);
    [str drawInRect: r
           withFont: f1
      lineBreakMode: UILineBreakModeWordWrap
          alignment: UITextAlignmentCenter];
    correctYofLabelForIOS7(&r, YES);
	
	if(mark){
		convertDateLabelRectToDotRect(&r, f2, dotStirng);
		correctYofDotForIOS7(&r, NO);
        
        UIColor *dot = [appearanceInfo objectForKey:dotColor];
        CGContextSetFillColorWithColor(context, dot.CGColor);
        
		[dotStirng drawInRect:r
				withFont: f2
		   lineBreakMode: UILineBreakModeWordWrap 
			   alignment: UITextAlignmentCenter];
	}
}

+ (CGFloat) tileStartOffsetForTilesWidth:(CGFloat)tilesWidth {
    CGFloat tileOffset = 0.0f;
    CGFloat tileWidth = tilesWidth / 7.0f;
    CGFloat leftWidth = tilesWidth - 7.0f * floorf(tileWidth);
    if (leftWidth > 0.001) {
        // width is not integral
        if (leftWidth <= 2.0f) {
            tileOffset = 1.0f;
        } else if (leftWidth <= 4) {
            tileOffset = 2.0f;
        } else if (leftWidth <= 6) {
            tileOffset = -1.0f;
        }
    }
    return tileOffset;
}

+ (CGFloat) effectiveTileWidthForTilesWidth:(CGFloat)tilesWidth {
    CGFloat effectiveTileWidth = tilesWidth / 7.0f;
    CGFloat leftWidth = tilesWidth - (7.0f * floorf(effectiveTileWidth));
    effectiveTileWidth = floorf(effectiveTileWidth);
    if (leftWidth > 0.001) {
        // width is not integral
        if (leftWidth <= 3.0f) {
            // width no change -> offset will change
        } else if (leftWidth <= 5.0f) {
            effectiveTileWidth += 1;
        }
    }
    return effectiveTileWidth;
}

+ (UIImage *) iOS7imageForTileType:(TKTileType) tileType size:(CGSize) size {
    UIImage *imageToReturn = [TKTile dayBackgroundImageWithSelectionOval:NO size:size];
	if (tileType == TKTileTypeSelected) {
        imageToReturn = [TKTile dayBackgroundImageWithSelectionOval:YES size:size];
	} else if (tileType == TKTileTypeSelectedToday) {
		imageToReturn = [TKTile dayBackgroundImageWithSelectionOval:YES size:size];
	} else if (tileType == TKTileTypeDarken) {
		imageToReturn = [UIImage imageWithContentsOfFile:TKBUNDLE(@"calendar/Month Calendar Date Tile Gray.png")];
	} else if(tileType == TKTileTypeToday) {
		imageToReturn = [TKTile dayBackgroundImageWithSelectionOval:NO size:size];
	}
    return imageToReturn;
}

+ (UIImage *) imageForTileType:(TKTileType) tileType size:(CGSize) size {
    return [TKTile iOS7imageForTileType:tileType size:size];
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

- (NSString *) description {
    NSString *totalDesc = [super description];
    NSString *s = [totalDesc stringByAppendingFormat:@"hidden: %@, alpha: %f, image: %@", self.hidden ? @"YES" : @"NO", self.alpha, self.image];
    return s;
}

#pragma mark - Appearance

- (void) setDotColor:(UIColor *)color {
    [appearanceInfo setObject:color forKey:dotColor];
}

- (void) setSelectionBgColor:(UIColor *)bgColor {
    [appearanceInfo setValue:bgColor forKey:selectionBgColor];
}

- (void) setDayLabelTextColor:(UIColor *)textColor forTileType:(TKTileType)tileType  {
    [appearanceInfo setValue:textColor forKey:[NSString stringWithFormat:@"%d", tileType]];
}

- (void) setSeparatorColor:(UIColor *) sepColor {
    [appearanceInfo setObject:sepColor forKey:separatorColorKey];
}

#pragma mark - iOS7 image generation

+ (UIImage *) dayBackgroundImageWithSelectionOval:(BOOL)selectionDrawn size:(CGSize)size {
    if (ABS(size.height) <= 0.001 || ABS(size.width) <= 0.001) {
        return nil;
    }
    CGFloat tileWidth = size.width;
    CGFloat tileHeight = size.height;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tileWidth, tileHeight), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!selectionDrawn) {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, CGRectMake(0.0f, 0.0f, tileWidth, tileHeight));
        UIColor *separatorColor = [appearanceInfo objectForKey:separatorColorKey];
        CGContextSetStrokeColorWithColor(context,  separatorColor.CGColor);
        CGContextStrokeRectWithWidth(context, CGRectMake(0.0f, tileHeight, tileWidth, 1.0f), 1.0f);
    }
    if (selectionDrawn) {
        UIColor *bgColor = [appearanceInfo objectForKey:selectionBgColor];
        CGContextSetFillColorWithColor(context, bgColor.CGColor);
        CGFloat selectionWidth = floorf(tileWidth / 1.54f); // adjusted propotionally to the size of the tile (iPhone/iPad)
        CGFloat yOffset = floorf(tileWidth / 21.0f);        // adjusted propotionally to the size of the tile (iPhone/iPad)
        CGRect rectForOval = CGRectIntegral(CGRectMake((tileWidth - selectionWidth) / 2.0f, yOffset, selectionWidth, selectionWidth));
        CGContextFillEllipseInRect(context, rectForOval);
    }
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return bgImage;
}

@end
