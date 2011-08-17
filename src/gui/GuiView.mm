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


@synthesize springDampingSlider;
@synthesize springFrequencySlider;
@synthesize forceRadiusSlider;
@synthesize adjustPointsSlider;

@synthesize attractionSwitch;
@synthesize gravitySwitch;


@synthesize fillsSwitch;
@synthesize wiresSwitch;
@synthesize pointsSwitch;
@synthesize colorRSlider;
@synthesize colorGSlider;
@synthesize colorBSlider;

@synthesize imgPicker;



-(void)viewDidLoad {
    app = (testApp *)ofGetAppPtr();
//	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
//		// ipad
//		app->gridSize = 20;
//	}
//	else {
//		// ipod
//		app->gridSize = 9;
//	}
    app->init();
    
    
    // Resize toolbar width
	CGRect frame = [[UIScreen mainScreen] applicationFrame];
	toolBar.frame = CGRectMake(0, 0, frame.size.width, toolBar.frame.size.height);
	

    
    if (app->first == 1){
        physicsView.hidden  = YES;
        meshView.hidden     = YES;
        infoView.hidden     = NO;

    }
    else {
        physicsView.hidden  = YES;
        meshView.hidden     = YES;
        infoView.hidden     = YES; 

    }
}



-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        return YES;
    }
    return NO;
}
  

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation duration:(NSTimeInterval)duration {
    if ( self.view.hidden == YES ) {
        [UIView setAnimationsEnabled:NO];
    }
    else {
        [UIView setAnimationsEnabled:YES];
    }
}




//------------------------------------------------
// ---- Adjust physics BEGIN

-(IBAction)adjustSpringDamping:(id)sender {
	UISlider *slider    = sender;
	app->drag           = [slider value];
}


-(IBAction)adjustSpringFrequency:(id)sender {
	UISlider *slider    = sender;
	app->springStrength = [slider value];
}


-(IBAction)adjustForceRadius:(id)sender {
    UISlider *slider    = sender;
    app->forceRadius    = [slider value];
}

-(IBAction)adjustPoints:(id)sender {
    UISlider *slider    = sender;
    app->gridSize       = [slider value];
    app->destroyMesh();
    app->buildMesh();
}

// ---- Adjust physics END
//------------------------------------------------




//------------------------------------------------
// ---- Adjust color BEGIN

-(IBAction)adjustColorR:(id)sender {
    UISlider *slider    = sender;
    app->colR           = [slider value];
}

-(IBAction)adjustColorG:(id)sender {
    UISlider *slider    = sender;
    app->colG           = [slider value];
}

-(IBAction)adjustColorB:(id)sender {
    UISlider *slider    = sender;
    app->colB           = [slider value];
}

// ---- Adjust color END
//------------------------------------------------




//------------------------------------------------
// ---- Switches BEGIN

-(IBAction)renderSwitchHandler:(id)sender {
	UISwitch *whichSwitch = (UISwitch *)sender;
    
	if ( whichSwitch == fillsSwitch ) {
		app->isFillsDrawingOn   = [whichSwitch isOn];
	}
	else if ( whichSwitch == wiresSwitch ) {
		app->isWiresDrawingOn   = [whichSwitch isOn];
	}
	else if ( whichSwitch == pointsSwitch ) {
		app->isPointsDrawingOn  = [whichSwitch isOn];
	}
}


-(IBAction)attractionSwitchHandler:(id)sender {
    app->isAttractionOn = !app->isAttractionOn;
}

-(IBAction)gravitySwitchHandler:(id)sender {
    app->isGravityOn = !app->isGravityOn;
}

// ---- Switches END
//------------------------------------------------




//------------------------------------------------
// ---- Show / hide views BEGIN

-(void)showView:(UIView *)v {
	CGRect frame		= v.frame;
	frame.origin.y		= 80.0;
	v.frame				= frame;
	frame.origin.y		= 44.0;
	
	v.alpha		= 0.0;
	v.hidden	= NO;
	[UIView animateWithDuration: 0.3
						  delay: 0.0
						options: UIViewAnimationOptionCurveEaseOut
					 animations: ^{
						 v.alpha = 1.0;
						 v.frame = frame;
					 }
					 completion: ^(BOOL finished) {
						 v.hidden = NO;
					 }];
}


-(void)hideView:(UIView *)v {
	CGRect frame		= v.frame;
	frame.origin.y		= 80.0;
	
	[UIView animateWithDuration: 0.15
						  delay: 0.0
						options: UIViewAnimationOptionCurveEaseIn
					 animations: ^{
						 v.alpha = 0.0;
						 v.frame = frame;
					 }
					 completion: ^(BOOL finished) {
						 v.hidden = YES;
					 }];
}


-(IBAction)showHidePhysicsView:(id)sender {
    if ( physicsView.hidden == YES ) {
		[self showView:physicsView];
	}
	else {
		[self hideView:physicsView];
	}
	meshView.hidden = YES;
	infoView.hidden = YES;
}


-(IBAction)showHideMeshView:(id)sender {
    if ( meshView.hidden == YES ) {
		[self showView:meshView];
	}
	else {
		[self hideView:meshView];
	}
	physicsView.hidden  = YES;
	infoView.hidden     = YES;
}


-(IBAction)showHideInfoView:(id)sender {
    if ( infoView.hidden == YES ) {
		[self showView:infoView];
	}
	else {
		[self hideView:infoView];
	}
	physicsView.hidden  = YES;
    meshView.hidden     = YES;
}


-(IBAction)hideGUIView:(id)sender {
	self.view.hidden = YES;
}

-(IBAction)runRandom:(id)sender {
    app->runRandom();
}

// ---- Shows / hide view END
//------------------------------------------------




-(IBAction)save:(id)sender {
    app->isSaveImageActive = true;
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Screenshot Saved"
                          message:@"See your Photo Gallery"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil];
	[alert show];	
	[alert release];
}


-(IBAction)saveSettings:(id)sender {
    app->saveSettings();
}

//----------------------------------------------------------------
-(IBAction)linkCAN:(id)sender{
	
	if (infoView.hidden == NO) {
        string sktchlink="http://apps.creativeapplications.net";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [[[[NSString alloc] initWithCString: sktchlink.c_str()]stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding] autorelease]   ]];
	}	
	
}

//----------------------------------------------------------------
-(IBAction)linkRicardo:(id)sender{
	
	if (infoView.hidden == NO) {
        string sktchlink="http://nardove.com";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [[[[NSString alloc] initWithCString: sktchlink.c_str()]stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding] autorelease]   ]];
	}	
	
}


@end