/*
 *  GuiView.h
 *  SpringMesh
 *
 *  Created by Ricardo Sanchez on 14/07/2011.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import "CRColorPicker.h"

#include "testApp.h"

@interface GuiView : UIViewController <UIPopoverControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CRColorPickerDelegate> {	
	testApp			*app;
    
	CGRect			viewFrame;
	CGRect			infoViewFrame;
	CGRect			settingsViewFrame;
	CGRect			pageControlFrame;
	CGRect			menuFrame;
	
	BOOL			isPad, isMenuViewOpen;
	
	float			openPosY, closePosY, menuViewHeight;
	
	
	// View outlets
	IBOutlet UIView			*infoView;
	IBOutlet UIScrollView	*infoScrollView;
	
	IBOutlet UIScrollView   *settingsView;
    IBOutlet UIPageControl  *pageControl;
	
	IBOutlet UIView			*menuView;
	
	IBOutlet UIView			*view0;
	IBOutlet UIView			*view1;
	IBOutlet UIView			*view2;
	IBOutlet UIView			*view3;
	
	IBOutlet UIButton		*settingsBtn;
	IBOutlet UIButton		*randomizeBtn;
	IBOutlet UIButton		*playpauseBtn;
	IBOutlet UIButton		*saveBtn;
	IBOutlet UIButton		*infoBtn;
	
	
	// Color settings outlets
	IBOutlet CRColorPicker	*colorPickerView;
	IBOutlet UISlider		*alphaColorSlider;
	IBOutlet UISwitch		*addBlendSwitch;
	IBOutlet UISwitch		*screenBlendSwitch;
	
	
	// Mesh settings outlets
	IBOutlet UIButton		*loadTextureButton;
	IBOutlet UISwitch		*textureSwitch;
	IBOutlet UISwitch		*fillsSwitch;
	IBOutlet UISwitch		*wiresSwitch;
	IBOutlet UISwitch		*pointsSwitch;
	IBOutlet UISlider		*resolutionSlider;
	
	IBOutlet UIButton					*textureButton;
	IBOutlet UIImagePickerController	*imgPicker;
	UIPopoverController					*popover;
	UIImage								*pickedImage;
	
	// Physics settings outlets
	IBOutlet UISlider		*simulationSpeedSlider;
	IBOutlet UISwitch		*gravitySwitch;
	IBOutlet UISlider		*gravityForceSlider;
	IBOutlet UISwitch		*attractionForceSwitch;
	IBOutlet UISlider		*attractionForceSlider;
	IBOutlet UISlider		*touchRadiusSlider;
	
	// Spring settings outlets
	IBOutlet UISlider		*dampingSlider;
	IBOutlet UISlider		*frequencySlider;
	IBOutlet UISlider		*densitySlider;
	IBOutlet UISwitch		*horizontalConnSwitch;
	IBOutlet UISwitch		*verticalConnSwitch;
	
	// Links buttons
	IBOutlet UIButton		*flickrLinkButton;
	IBOutlet UIButton		*rsLinkButton;
	IBOutlet UIButton		*canLinkButton;
	IBOutlet UIButton		*ofLinkButton;
}


// View outlets
@property (nonatomic, retain) UIScrollView		*settingsView;
@property (nonatomic, retain) UIPageControl		*pageControl;

@property (nonatomic, retain) UIView			*menuView;

@property (nonatomic, retain) UIView			*infoView;
@property (nonatomic, retain) UIScrollView		*infoScrollView;

@property (nonatomic, retain) UIView			*view0;	// color view
@property (nonatomic, retain) UIView			*view1;	// mesh view
@property (nonatomic, retain) UIView			*view2;	// physics view
@property (nonatomic, retain) UIView			*view3;	// spring view

@property (nonatomic, retain) UIButton			*settingsBtn;
@property (nonatomic, retain) UIButton			*randomizeBtn;
@property (nonatomic, retain) UIButton			*playpauseBtn;
@property (nonatomic, retain) UIButton			*saveBtn;
@property (nonatomic, retain) UIButton			*infoBtn;


// Color settings outlets
@property (nonatomic, retain) UISlider			*alphaColorSlider;
@property (nonatomic, retain) UISwitch			*addBlendSwitch;
@property (nonatomic, retain) UISwitch			*screenBlendSwitch;

@property (nonatomic, retain) CRColorPicker		*colorPickerView;

// Mesh settings outlets
@property (nonatomic, retain) UIButton			*loadTextureButton;
@property (nonatomic, retain) UISwitch			*textureSwitch;
@property (nonatomic, retain) UISwitch			*fillsSwitch;
@property (nonatomic, retain) UISwitch			*wiresSwitch;
@property (nonatomic, retain) UISwitch			*pointsSwitch;
@property (nonatomic, retain) UISlider			*resolutionSlider;

@property (nonatomic, retain) UIButton					*textureButton;
@property (nonatomic, retain) UIImagePickerController	*imgPicker;

// Physics settings outlets
@property (nonatomic, retain) UISlider			*simulationSpeedSlider;
@property (nonatomic, retain) UISwitch			*gravitySwitch;
@property (nonatomic, retain) UISlider			*gravityForceSlider;
@property (nonatomic, retain) UISwitch			*attractionForceSwitch;
@property (nonatomic, retain) UISlider			*attractionForceSlider;
@property (nonatomic, retain) UISlider			*touchRadiusSlider;

// Spring settings outlets
@property (nonatomic, retain) UISlider			*dampingSlider;
@property (nonatomic, retain) UISlider			*frequencySlider;
@property (nonatomic, retain) UISlider			*densitySlider;
@property (nonatomic, retain) UISwitch			*horizontalConnSwitch;
@property (nonatomic, retain) UISwitch			*verticalConnSwitch;

// Links buttons
@property (nonatomic, retain) UIButton			*flickrLinkButton;
@property (nonatomic, retain) UIButton			*rsLinkButton;
@property (nonatomic, retain) UIButton			*canLinkButton;
@property (nonatomic, retain) UIButton			*ofLinkButton;



-(IBAction)toggleSettingsView:(id)sender;
-(IBAction)changePage:(id)sender;

-(IBAction)toggleSettingsView:(id)sender;

-(IBAction)toggleInfoView:(id)sender;

-(IBAction)colorSliderHandler:(id)sender;
-(IBAction)colorSwitchHandler:(id)sender;
-(IBAction)meshSwitchHandler:(id)sender;
-(IBAction)meshSliderHandler:(id)sender;
-(IBAction)physicsSliderHandler:(id)sender;
-(IBAction)physicsSwitchHandler:(id)sender;
-(IBAction)springSliderHandler:(id)sender;
-(IBAction)springSwitchHandler:(id)sender;

-(IBAction)grabImage:(id)sender;

-(IBAction)navigateToLink:(id)sender;


-(void)settingsViewDidScroll:(UIScrollView *)sender;

-(void)alignMenuView;
-(void)alignSettingsView;
-(void)showSettingsView;
-(void)hideSettingsView;

-(void)saveSettings;

-(void)showInfoView;
-(void)hideInfoView;


-(void)showMenuView;
-(void)hideMenuView;


@end