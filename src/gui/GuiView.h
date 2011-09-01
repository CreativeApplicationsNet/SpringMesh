/*
 *  GuiView.h
 *  SpringMesh
 *
 *  Created by Ricardo Sanchez on 14/07/2011.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

#include "testApp.h"

@interface GuiView : UIViewController <UIPopoverControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	
	testApp                     *app;
    
    IBOutlet UIToolbar          *toolBar;
    
    IBOutlet UIView             *physicsView;
    IBOutlet UIView             *meshView;
    IBOutlet UIView             *infoView;
	
    IBOutlet UISwitch           *textureSwitch;
	IBOutlet UISwitch           *fillsSwitch;
	IBOutlet UISwitch           *wiresSwitch;
	IBOutlet UISwitch           *pointsSwitch;
    IBOutlet UISwitch           *attractionSwitch;
    IBOutlet UISwitch           *gravitySwitch;
    
    IBOutlet UISwitch           *addBlendSwitch;
    IBOutlet UISwitch           *screenBlendSwitch;
    
    IBOutlet UISlider           *springDampingSlider;
    IBOutlet UISlider           *springFrequencySlider;
    IBOutlet UISlider           *forceRadiusSlider;
    IBOutlet UISlider           *adjustPointsSlider;
    
    IBOutlet UISlider           *colorRSlider;
    IBOutlet UISlider           *colorGSlider;
    IBOutlet UISlider           *colorBSlider;
    IBOutlet UISlider           *colorASlider;
    
    IBOutlet UIWebView          *webView;
    
    IBOutlet UIButton           *grabImageButton;
    
    UIImagePickerController     *imgPicker;
    UIPopoverController         *popover;
    UIImage                     *pickedImage;
}



@property (nonatomic, retain) UISlider *springDampingSlider;
@property (nonatomic, retain) UISlider *springFrequencySlider;
@property (nonatomic, retain) UISlider *forceRadiusSlider;
@property (nonatomic, retain) UISlider *adjustPointsSlider;
@property (nonatomic, retain) UISwitch *attractionSwitch;
@property (nonatomic, retain) UISwitch *gravitySwitch;

@property (nonatomic, retain) UISwitch *addBlendSwitch;
@property (nonatomic, retain) UISwitch *screenBlendSwitch;

@property (nonatomic, retain) UISwitch *textureSwitch;
@property (nonatomic, retain) UISwitch *fillsSwitch;
@property (nonatomic, retain) UISwitch *wiresSwitch;
@property (nonatomic, retain) UISwitch *pointsSwitch;
@property (nonatomic, retain) UISlider *colorRSlider;
@property (nonatomic, retain) UISlider *colorGSlider;
@property (nonatomic, retain) UISlider *colorBSlider;
@property (nonatomic, retain) UISlider *colorASlider;

@property (nonatomic, retain) UIButton *grabImageButton;

@property (nonatomic, retain) UIImagePickerController *imgPicker;



-(IBAction)adjustSpringDamping:(id)sender;
-(IBAction)adjustSpringFrequency:(id)sender;
-(IBAction)adjustForceRadius:(id)sender;
-(IBAction)adjustPoints:(id)sender;


-(IBAction)adjustColorR:(id)sender;
-(IBAction)adjustColorG:(id)sender;
-(IBAction)adjustColorB:(id)sender;
-(IBAction)adjustColorA:(id)sender;


-(IBAction)renderSwitchHandler:(id)sender;
-(IBAction)attractionSwitchHandler:(id)sender;
-(IBAction)gravitySwitchHandler:(id)sender;


-(void)hideView:(UIView *)v;
-(void)showView:(UIView *)v;
-(IBAction)showHidePhysicsView:(id)sender;
-(IBAction)showHideMeshView:(id)sender;
-(IBAction)showHideInfoView:(id)sender;
-(IBAction)hideGUIView:(id)sender;
-(IBAction)runRandom:(id)sender;


-(IBAction)save:(id)sender;

-(IBAction)grabImage:(id)sender;

-(IBAction)saveSettings:(id)sender;

-(IBAction)linkCAN:(id)sender;
-(IBAction)linkRicardo:(id)sender;

@end