/*
 *  GuiView.mm
 *  SpringMesh
 *
 *  Created by Ricardo Sanchez on 14/07/2011.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "GuiView.h"

#include "ofxiPhoneExtras.h"


@implementation GuiView


// View outlets
@synthesize introView;
@synthesize introImageView;
@synthesize introViewButton;

@synthesize settingsView;
@synthesize pageControl;

@synthesize menuView;

@synthesize infoView;
@synthesize infoScrollView;

@synthesize view0;
@synthesize view1;
@synthesize view2;
@synthesize view3;

@synthesize settingsBtn;
@synthesize randomizeBtn;
@synthesize playpauseBtn;
@synthesize saveBtn;
@synthesize infoBtn;


// Color settings outlets
@synthesize alphaColorSlider;
@synthesize addBlendSwitch;
@synthesize screenBlendSwitch;

@synthesize colorPickerView;

// Mesh settings outlets
@synthesize loadTextureButton;
@synthesize textureSwitch;
@synthesize fillsSwitch;
@synthesize wiresSwitch;
@synthesize pointsSwitch;
@synthesize resolutionSlider;
@synthesize textureButton;
@synthesize imgPicker;

// Physics settings outlets
@synthesize simulationSpeedSlider;
@synthesize gravitySwitch;
@synthesize gravityForceSlider;
@synthesize attractionForceSwitch;
@synthesize attractionForceSlider;
@synthesize touchRadiusSlider;

// Spring settings outlets
@synthesize dampingSlider;
@synthesize frequencySlider;
@synthesize densitySlider;
@synthesize horizontalConnSwitch;
@synthesize verticalConnSwitch;

// Link buttons
@synthesize flickrLinkButton;
@synthesize rsLinkButton;
@synthesize canLinkButton;
@synthesize ofLinkButton;



-(void)viewDidLoad
{
    //[super viewDidLoad];
    
	// Set testApp
	app = (testApp *)ofGetAppPtr();
    //app->init();
	
	// Check which device
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		isPad	= YES;
	}
	else
	{
		isPad	= NO;
	}
    
	self.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	
	viewFrame	= [[UIScreen mainScreen] applicationFrame];
	
	// Set intro objects frame
	self.introView.frame		= viewFrame;
	self.introViewButton.frame	= viewFrame;
	
	menuViewHeight	= 45.0;
	
	self.colorPickerView.delegate = self;
	[self.colorPickerView arrange];
	
	[self alignSettingsView];
	[self alignMenuView];
	
	app->init();
}


-(void)viewWillAppear:(BOOL)animated
{
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	if ( ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) || ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) )
	{
		NSLog(@"Using landscape image");
		[[self introImageView] setImage:[UIImage imageNamed:@"intro-Landscape.png"]];
	}
	else
	{
		NSLog(@"Using portrait image");
		if ( isPad == YES )
		{
			[[self introImageView] setImage:[UIImage imageNamed:@"intro-Portrait.png"]];
		}
		else
		{
			[[self introImageView] setImage:[UIImage imageNamed:@"intro.png"]];
		}
	}
	
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	// Hide intro view after 4 seconds
	[UIView animateWithDuration: 1.0
						  delay: 4.0
						options: UIViewAnimationOptionCurveLinear
					 animations: ^{
						 introView.alpha = 0;
					 }
					 completion: ^(BOOL finished) {
						 [introView removeFromSuperview];
						 [introViewButton removeFromSuperview];
					 }];
}



-(void)viewDidUnload
{
    //[super viewDidUnload];
    
    settingsView	= nil;
    pageControl		= nil;
	menuView		= nil;
}



-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
	NSLog( @"Oops memory warning?! better check it out" );
}



-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
        return YES;
    }
	return NO;
}
  


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation duration:(NSTimeInterval)duration
{
    
	viewFrame	= self.view.bounds;
	
	[self alignSettingsView];
	[self alignMenuView];
}



-(IBAction)hideIntroView:(id)sender
{
	NSLog(@"animation should cancel");
	
	//[introView stopAnimating];
	//[introView.layer removeAllAnimations];
	[UIView animateWithDuration: 1.0
						  delay: 0.5
						options: UIViewAnimationOptionCurveLinear
					 animations: ^{
						 introView.alpha = 0;
					 }
					 completion: ^(BOOL finished) {
						 [introView removeFromSuperview];
						 [introViewButton removeFromSuperview];
					 }];
	
}



-(void)selectedColor:(UIColor*)inColor fromColorPicker:(CRColorPicker *)inColorPicker;
{
	if ( inColor )
	{
		const float* colors = CGColorGetComponents( inColor.CGColor );
		
		app->colR			= colors[0];
		app->colG			= colors[1];
		app->colB			= colors[2];
		
		app->knobPositionX	= colorPickerView.knobView.frame.origin.x;
		app->knobPositionY	= colorPickerView.knobView.frame.origin.y;
		
		[self saveSettings];
	}
}



-(IBAction)colorSliderHandler:(id)sender
{
	UISlider *colorSlider = sender;
	if ( colorSlider == alphaColorSlider )
	{
		app->colA = [colorSlider value];
	}
	
	[self saveSettings];
}



-(IBAction)colorSwitchHandler:(id)sender
{
	UISwitch *colorSwitch = (UISwitch *)sender;
	
	if ( colorSwitch == addBlendSwitch )
	{
		app->isAddBlendModeOn		= [colorSwitch isOn];
	}
	else if ( colorSwitch == screenBlendSwitch )
	{
		app->isScreenBlendModeOn	= [colorSwitch isOn];
	}
	
	[self saveSettings];
}



-(IBAction)meshSwitchHandler:(id)sender
{
	UISwitch *meshSwitch = (UISwitch *)sender;
    
	if ( meshSwitch == textureSwitch )
	{
		app->isTextureDrawingOn	= [meshSwitch isOn];
	}
	else if ( meshSwitch == fillsSwitch )
	{
		app->isFillsDrawingOn   = [meshSwitch isOn];
	}
	else if ( meshSwitch == wiresSwitch )
	{
		app->isWiresDrawingOn   = [meshSwitch isOn];
	}
	else if ( meshSwitch == pointsSwitch )
	{
		app->isPointsDrawingOn  = [meshSwitch isOn];
	}
	
	[self saveSettings];
}


-(IBAction)meshSliderHandler:(id)sender
{
    UISlider *meshSlider		= sender;
    app->gridSize				= [meshSlider value];
    app->destroyMesh();
    app->buildMesh();
	
	[self saveSettings];
}



-(IBAction)physicsSliderHandler:(id)sender
{
	UISlider *physicsSlider		= sender;
	
	if ( physicsSlider == simulationSpeedSlider )
	{
		app->physicsSpeed		= [physicsSlider value];
	}
	else if ( physicsSlider == gravityForceSlider )
	{
		app->gravityForce		= [physicsSlider value];
	}
	else if ( physicsSlider == attractionForceSlider )
	{
		app->attractionForce	= [physicsSlider value];
	}
	else if ( physicsSlider == touchRadiusSlider )
	{
		app->forceRadius		= [physicsSlider value];
	}
	
	[self saveSettings];
}



-(IBAction)physicsSwitchHandler:(id)sender
{
	UISwitch *physicsSwitch		= (UISwitch *)sender;
    
	if ( physicsSwitch == gravitySwitch )
	{
		app->isGravityOn		= [physicsSwitch isOn];
	}
	else if ( physicsSwitch == attractionForceSwitch )
	{
		app->isAttractionOn		= [physicsSwitch isOn];
	}
	
	[self saveSettings];
}



-(IBAction)springSliderHandler:(id)sender
{
	UISlider *springSlider		= sender;
	
	if ( springSlider == dampingSlider )
	{
		app->drag				= [springSlider value];
	}
	else if ( springSlider == frequencySlider )
	{
		app->springStrength		= [springSlider value];
	}
	else if ( springSlider == densitySlider )
	{
		app->particleDensity	= [springSlider value];
	}
	
	[self saveSettings];
}



-(IBAction)springSwitchHandler:(id)sender
{
	UISwitch *springSwitch		= (UISwitch *)sender;
	
	// Check if both are off, is so switch back on the other
	if ( [horizontalConnSwitch isOn] == NO && [verticalConnSwitch isOn] == NO )
	{
		if ( springSwitch != horizontalConnSwitch )
		{
			[horizontalConnSwitch setOn:YES];
			app->isHorizontalSpringsOn	= YES;
		}
		else
		{
			[verticalConnSwitch setOn:YES];
			app->isVerticalSpringsOn	= YES;
		}
	}
	
	if ( springSwitch == horizontalConnSwitch )
	{
		app->isHorizontalSpringsOn	= [springSwitch isOn];
	}
	else if ( springSwitch == verticalConnSwitch )
	{
		app->isVerticalSpringsOn	= [springSwitch isOn];
	}
	
	app->destroyMesh();
	app->buildMesh();
	
	[self saveSettings];
}



-(IBAction)grabImage:(id)sender
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		imgPicker = [[UIImagePickerController alloc] init];
		[imgPicker setDelegate:self];
        
		popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
		[popover setDelegate:self];
		
		CGPoint position	= [view1.superview convertPoint:view1.frame.origin toView:nil];
		CGRect popOverFrame	= CGRectMake( position.x, position.y, self.view.frame.size.width, self.view.frame.size.height );
		
		[popover presentPopoverFromRect:popOverFrame inView:self.view permittedArrowDirections:nil animated:NO];
		[popover setPopoverContentSize:CGSizeMake( 320, 480 )];
	}
	else
	{
		imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.delegate = self;
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:self.imgPicker animated:YES];
	}
	[imgPicker release];
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
	CGImageRef imgRef = pickedImage.CGImage;
	
    app->setImage( pickedImage, CGImageGetWidth(imgRef), CGImageGetHeight(imgRef) );
	
//	Enable texture siwth after an image has been loaded
	[textureSwitch setEnabled:YES];
	[textureSwitch setOn:YES];
	app->isTextureDrawingOn		= [textureSwitch isOn];
	
	[fillsSwitch setOn:NO];
	app->isFillsDrawingOn		= [fillsSwitch isOn];
	
	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		[[picker parentViewController] dismissModalViewControllerAnimated:YES];
		[popover dismissPopoverAnimated:YES];
	}
	else
	{
		[picker dismissModalViewControllerAnimated:YES];
	}
	
	[self alignMenuView];
	[self alignSettingsView];
}



-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		[[picker parentViewController] dismissModalViewControllerAnimated:YES];
		[popover dismissPopoverAnimated:YES];
	}
	else
	{
		[picker dismissModalViewControllerAnimated:YES];
	}
	
	[self alignMenuView];
	[self alignSettingsView];
}



-(IBAction)saveSettings
{
    app->saveSettings();
}



-(IBAction)runRandom:(id)sender
{
    app->runRandom();
}



-(IBAction)saveImage:(id)sender
{
    app->isSaveImageActive = true;
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Screenshot Saved"
                          message:@"Check it out in your Photo Album"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil];
	[alert show];	
	[alert release];
}



-(IBAction)playpauseSimulation:(id)sender
{
	app->isBox2dPaused = !app->isBox2dPaused;
	
	if ([sender isSelected])
	{
		[sender setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
		[sender setSelected:NO];
	}
	else
	{
		[sender setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateSelected];
		[sender setSelected:YES];
	}
}



-(void)alignMenuView
{
	menuFrame.origin.x			= 0;
	menuFrame.origin.y			= viewFrame.size.height - menuViewHeight;
	menuFrame.size.width		= viewFrame.size.width;
	menuFrame.size.height		= menuViewHeight;
	
	menuView.frame				= menuFrame;
	
	isMenuViewOpen				= NO;
	
	float spaceX				= 10.0;
	float width					= 0.0;
	
	for ( UIView *btn in [menuView subviews] )
	{
		width += btn.frame.size.width;
	}
	
	CGRect settingsBtnFrame		= settingsBtn.frame;
	settingsBtnFrame.origin.x	= (viewFrame.size.width - width - settingsBtn.frame.size.width) / 2;
	settingsBtn.frame			= settingsBtnFrame;
	
	CGRect randomizeBtnFrame	= randomizeBtn.frame;
	randomizeBtnFrame.origin.x	= settingsBtnFrame.origin.x + settingsBtnFrame.size.width + spaceX;
	randomizeBtn.frame			= randomizeBtnFrame;
	
	CGRect playpauseBtnFrame	= playpauseBtn.frame;
	playpauseBtnFrame.origin.x	= randomizeBtnFrame.origin.x + randomizeBtnFrame.size.width + spaceX;
	playpauseBtn.frame			= playpauseBtnFrame;
	
	CGRect saveBtnFrame			= saveBtn.frame;
	saveBtnFrame.origin.x		= playpauseBtnFrame.origin.x + playpauseBtnFrame.size.width + spaceX;
	saveBtn.frame				= saveBtnFrame;
	
	CGRect infoBtnFrame			= infoBtn.frame;
	infoBtnFrame.origin.x		= saveBtnFrame.origin.x + saveBtnFrame.size.width + spaceX;
	infoBtn.frame				= infoBtnFrame;
}



-(void)showMenuView
{
	if ( menuView.hidden == YES || isMenuViewOpen == NO )
	{
		CGRect openFrame			= viewFrame;
		CGRect openMenuFrame		= openFrame;
		openMenuFrame.origin.y		= openPosY - menuViewHeight;
		openMenuFrame.size.height	= menuViewHeight;
		
		settingsView.hidden			= NO;
		
		[UIView animateWithDuration: 0.2
							  delay: 0.0
							options: UIViewAnimationOptionCurveEaseIn
						 animations: ^{
							 menuView.frame	= openMenuFrame;
						 }
						 completion: ^(BOOL finished) {
							 isMenuViewOpen = YES;
						 }];
		
		[settingsBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
	}
}



-(void)hideMenuView
{
	if ( menuView.hidden == NO || isMenuViewOpen == YES )
	{
		CGRect closeFrame			= viewFrame;
		closeFrame.origin.y			= closePosY;
		
		CGRect closeMenuFrame		= closeFrame;
		closeMenuFrame.origin.y		= closePosY - menuViewHeight;
		closeMenuFrame.size.height	= menuViewHeight;
		
		[UIView animateWithDuration: 0.15
							  delay: 0.0
							options: UIViewAnimationOptionCurveEaseOut
						 animations: ^{
							 menuView.frame	= closeMenuFrame;
						 }
						 completion: ^(BOOL finished) {
							 isMenuViewOpen = NO;
						 }];
		
		[settingsBtn setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
	}
}



-(void)showInfoView
{
	if ( infoView.hidden == YES )
	{
		CGRect openFrame			= infoViewFrame;
		openFrame.origin.y			= openPosY;
		
		CGRect openMenuFrame		= openFrame;
		openMenuFrame.origin.y		= openPosY - menuViewHeight;
		openMenuFrame.size.height	= menuViewHeight;
		
		infoView.hidden				= NO;
		
		[UIView animateWithDuration: 0.2
							  delay: 0.0
							options: UIViewAnimationOptionCurveEaseIn
						 animations: ^{
							 infoView.frame		= openFrame;
						 }
						 completion: ^(BOOL finished) {
							 infoView.hidden	= NO;
						 }];
		
		[infoBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
	}
}



-(void)hideInfoView
{
	if ( infoView.hidden == NO )
	{
		CGRect closeFrame			= infoViewFrame;
		closeFrame.origin.y			= closePosY;
		
		CGRect closeMenuFrame		= closeFrame;
		closeMenuFrame.origin.y		= closePosY - menuViewHeight;
		closeMenuFrame.size.height	= menuViewHeight;
		
		[UIView animateWithDuration: 0.15
							  delay: 0.0
							options: UIViewAnimationOptionCurveEaseOut
						 animations: ^{
							 infoView.frame		= closeFrame;
						 }
						 completion: ^(BOOL finished) {
							 infoView.hidden	= YES;
						 }];
		
		[infoBtn setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
	}
}



-(IBAction)toggleInfoView:(id)sender
{
	if ( infoView.hidden == YES )
	{
		[self showInfoView];
		[self showMenuView];
	}
	else
	{
		[self hideInfoView];
		[self hideMenuView];
	}
		
	// Check if settingsView is open, if os close it
	if ( settingsView.hidden == NO )
	{
		[self hideSettingsView];
	}
}



-(void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth		= settingsView.frame.size.width;
    
	int page				= floor( (settingsView.contentOffset.x - pageWidth / 2 ) / pageWidth ) + 1;
    
	pageControl.currentPage = page;
}



-(IBAction)changePage:(id)sender
{
    CGRect frame;
    frame.origin.x		= settingsView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y		= 0;
    frame.size			= settingsView.frame.size;
    
	[settingsView scrollRectToVisible:frame animated:YES];
}



-(void)alignSettingsView
{
	NSUInteger scaleFactor			= (isPad) ? 2 : 1;
	
	CGFloat offsetY					= (viewFrame.size.height > viewFrame.size.width) ? 0.65 : 0.6;
	CGFloat offsetH					= (viewFrame.size.height > viewFrame.size.width) ?  0.35 : 0.4;
	
	
	settingsViewFrame.origin.x		= 0;
    settingsViewFrame.origin.y		= viewFrame.size.height * ((isPad) ? offsetY : offsetH);
    settingsViewFrame.size.width	= viewFrame.size.width;
    settingsViewFrame.size.height	= viewFrame.size.height * ((isPad) ? offsetH : offsetY);
    
	openPosY						= settingsViewFrame.origin.y;
	closePosY						= settingsViewFrame.origin.y + settingsViewFrame.size.height;
	
	settingsViewFrame.origin.y		= closePosY;
	
	settingsView.frame				= settingsViewFrame;
    settingsView.contentSize			= CGSizeMake( settingsViewFrame.size.width * (settingsView.subviews.count / scaleFactor), settingsViewFrame.size.height );
	
	// This is a hack to initialize hte scroll view settings after orientation changed
	settingsView.hidden				= YES;
	[settingsBtn setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
	
	
	// ---- Info view
	infoViewFrame					= settingsViewFrame;
	infoView.frame					= infoViewFrame;
	//infoScrollView.frame			= infoViewFrame;
	infoScrollView.contentSize		= CGSizeMake( 320, 631 );
	infoView.hidden					= YES;
	[infoBtn setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
	
	
	NSUInteger index;
	for ( UIView *sView in [settingsView subviews] )
	{
		index						= [[settingsView subviews] indexOfObject:sView];
		
		CGRect frame;
        frame.origin.x				= (settingsViewFrame.size.width / scaleFactor) * index;
        frame.origin.y				= 0;
        frame.size.width			= settingsViewFrame.size.width / scaleFactor;
		frame.size.height			= settingsViewFrame.size.height;
		
		[sView setFrame:frame];
	}
	
	// pageControl
    pageControl.numberOfPages		= settingsView.subviews.count / scaleFactor;
	
    pageControlFrame.origin.x		= (settingsViewFrame.size.width - pageControl.frame.size.width) / 2;
    pageControlFrame.origin.y		= openPosY + settingsViewFrame.size.height - menuViewHeight * 0.75;
    pageControlFrame.size			= pageControl.bounds.size;
    
	pageControl.frame				= pageControlFrame;
    pageControl.hidden				= YES;
}



-(void)showSettingsView
{
	if ( settingsView.hidden == YES )
	{
		CGRect openFrame			= settingsViewFrame;
		openFrame.origin.y			= openPosY;
		
		CGRect openMenuFrame		= openFrame;
		openMenuFrame.origin.y		= openPosY - menuViewHeight;
		openMenuFrame.size.height	= menuViewHeight;
		
		settingsView.hidden			= NO;
		
		[UIView animateWithDuration: 0.2
							  delay: 0.0
							options: UIViewAnimationOptionCurveEaseIn
						 animations: ^{
							 settingsView.frame		= openFrame;
							 //menuView.frame			= openMenuFrame;
						 }
						 completion: ^(BOOL finished) {
							 settingsView.hidden	= NO;
							 pageControl.hidden		= NO;
						 }];
		
		[settingsBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
	}
}



-(void)hideSettingsView
{
	if ( settingsView.hidden == NO )
	{
		CGRect closeFrame			= settingsViewFrame;
		closeFrame.origin.y			= closePosY;
		
		CGRect closeMenuFrame		= closeFrame;
		closeMenuFrame.origin.y		= closePosY - menuViewHeight;
		closeMenuFrame.size.height	= menuViewHeight;
		
		[UIView animateWithDuration: 0.15
							  delay: 0.0
							options: UIViewAnimationOptionCurveEaseOut
						 animations: ^{
							 settingsView.frame		= closeFrame;
							 //menuView.frame			= closeMenuFrame;
						 }
						 completion: ^(BOOL finished) {
							 settingsView.hidden	= YES;
							 pageControl.hidden		= YES;
						 }];
		
		[settingsBtn setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
	}
}



-(IBAction)toggleSettingsView:(id)sender
{
	if ( settingsView.hidden == YES )
	{
		[self showSettingsView];
		[self showMenuView];
	}
	else
	{
		[self hideSettingsView];
		[self hideMenuView];
	}
	
	// Check if infoView is open, if os close it
	if ( infoView.hidden == NO )
	{
		[self hideInfoView];
	}
}



-(IBAction)navigateToLink:(id)sender
{
	UIButton *button	= sender;
	
	string linkString;
	
	if ( button == flickrLinkButton )
	{
		linkString = "http://www.flickr.com/groups/springmesh/";
	}
	else if ( button == rsLinkButton )
	{
		linkString = "http://www.nardove.com";
	}
	else if ( button == canLinkButton )
	{
		linkString = "http://itunes.com/apps/creativeapplicationsnet/";
	}
	else if ( button == ofLinkButton )
	{
		linkString = "http://www.openframeworks.cc";
	}
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: [[[[NSString alloc] initWithCString: linkString.c_str()]stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding] autorelease]]];
}


@end