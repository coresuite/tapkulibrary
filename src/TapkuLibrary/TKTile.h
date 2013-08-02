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

@interface TKTile : UIImageView {
	UILabel *dot;
	UILabel *currentDay;
}
@property (nonatomic, readonly) UILabel *currentDay;
@property (nonatomic, readonly) UILabel *dot;
@property (nonatomic) CGSize shadowOffset;

+ (void) drawTileInRect:(CGRect)r day:(int)day mark:(BOOL)mark font:(UIFont*)f1 font2:(UIFont*)f2  context:(CGContextRef)context;

+ (NSString *) stringFromDayNumber:(int) day;

+ (UIImage *) imageForTileType:(TKTileType) tileType;
+ (UIFont *) fontForDateLabelForTileRect:(CGRect) tileRect;
+ (UIFont *) fontForDotLabelForTileRect:(CGRect) tileRect;

@end
