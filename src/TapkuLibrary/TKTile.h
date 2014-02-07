//
//  TKTile.h
//  coresuite-ipad
//
//  Created by Tomasz Krasnyk on 10-12-19.
//  Copyright 2010 coresystems ag. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	TKTileTypeNotSelected = 0,
	TKTileTypeSelected,
	TKTileTypeSelectedToday,
	TKTileTypeToday,
	TKTileTypeDarken
} TKTileType;

@interface TKTile : UIImageView<UIAppearance> {
	UILabel *dot;
	UILabel *currentDay;
}
@property (nonatomic, readonly) UILabel *currentDay;
@property (nonatomic, readonly) UILabel *dot;
@property (nonatomic) CGSize shadowOffset;

+ (void) drawTileInRect:(CGRect)tileRect day:(NSInteger)day mark:(BOOL)mark font:(UIFont*)f1 font2:(UIFont*)f2 context:(CGContextRef)context
                isToday:(BOOL) isToday isOtherMonthDay:(BOOL)isOtherMonthDay;

+ (NSString *) stringFromDayNumber:(NSInteger) day;

+ (UIImage *) imageForTileType:(TKTileType) tileType size:(CGSize)size;
+ (UIFont *) fontForDateLabelForTileRect:(CGRect) tileRect;
+ (UIFont *) fontForDotLabelForTileRect:(CGRect) tileRect;

+ (CGFloat) tileStartOffsetForTilesWidth:(CGFloat)tilesWidth;
+ (CGFloat) effectiveTileWidthForTilesWidth:(CGFloat)tilesWidth;

- (void) setDayLabelTextColor:(UIColor *)textColor
                 forTileType:(TKTileType)tileType UI_APPEARANCE_SELECTOR;
- (void) setSelectionBgColor:(UIColor *)bgColor UI_APPEARANCE_SELECTOR;
- (void) setDotColor:(UIColor *)dotColor UI_APPEARANCE_SELECTOR;
- (void) setSeparatorColor:(UIColor *) sepColor UI_APPEARANCE_SELECTOR;
@end
