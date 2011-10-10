//
//  CRColorPicker.h
//  SimpleColorPicker
//
//  Created by ICRG LABS on 16/01/11.
//

#import <UIKit/UIKit.h>

@class CRColorPicker;

@protocol CRColorPickerDelegate <NSObject>

-(void)selectedColor:(UIColor*)inColor fromColorPicker:(CRColorPicker *)inColorPicker;

@end

@interface CRColorPicker : UIControl {
	UIImageView *sourceColorImageView; //The imageview from where we pick the color source
	id <CRColorPickerDelegate> delegate; //The delegate
	UIColor *currentColor; //the current color picked
	UIImageView *knobView;  //the knob slider
	
	CGPoint mTouchStartPoint, mColorPoint;
}

@property(nonatomic, retain) UIImageView *sourceColorImageView;
@property(nonatomic, assign) id<CRColorPickerDelegate> delegate;
@property(nonatomic, retain) UIColor *currentColor;

@property(nonatomic, retain) UIImageView *knobView;

-(void)arrange;
-(void)changeColor;
-(UIColor*)pixelColorAt:(CGPoint)point colorSource:(UIImage*)inImage;
-(CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage;
@end
