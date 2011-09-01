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

@synthesize textureSwitch;
@synthesize fillsSwitch;
@synthesize wiresSwitch;
@synthesize pointsSwitch;

@synthesize blendSwitch;

@synthesize colorRSlider;
@synthesize colorGSlider;
@synthesize colorBSlider;
@synthesize colorASlider;

@synthesize grabImageButton;

@synthesize imgPicker;



-(void)viewDidLoad {
    app = (testApp *)ofGetAppPtr();
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
    
    /* GETTING SIGABRT ERROR not sure why
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]isDirectory:NO]]];
    */
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return false;
    }
    return true;
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

-(IBAction)adjustColorA:(id)sender {
    UISlider *slider    = sender;
    app->colA           = [slider value];
}

// ---- Adjust color END
//------------------------------------------------




//------------------------------------------------
// ---- Switches BEGIN

-(IBAction)renderSwitchHandler:(id)sender {
	UISwitch *whichSwitch = (UISwitch *)sender;
    
	if ( whichSwitch == textureSwitch ) {
		app->isTextureDrawingOn = [whichSwitch isOn];
	}
	else if ( whichSwitch == fillsSwitch ) {
		app->isFillsDrawingOn   = [whichSwitch isOn];
	}
	else if ( whichSwitch == wiresSwitch ) {
		app->isWiresDrawingOn   = [whichSwitch isOn];
	}
	else if ( whichSwitch == pointsSwitch ) {
		app->isPointsDrawingOn  = [whichSwitch isOn];
	}
    else if ( whichSwitch == blendSwitch ) {
		app->isBlendModeOn  = [whichSwitch isOn];
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
    cout << "show" << endl;
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
    cout << "hide" << endl;
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
    
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]isDirectory:NO]]];


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



//------------------------------------------------
// Grab image from photo album BEGIN

-(IBAction)grabImage:(id)sender {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        imgPicker = [[UIImagePickerController alloc] init];
        [imgPicker setDelegate:self];
        
        popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
        [popover setDelegate:self];
        // Using magic CGRectMake,  for some reson self.grabImageButton.frame doesnt work
        [popover presentPopoverFromRect:CGRectMake(150, 2, 40, 40) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [popover setPopoverContentSize:CGSizeMake(320, 480)];
        [imgPicker release];
    }
    else {
        imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.delegate = self;
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:self.imgPicker animated:YES];
        [imgPicker release];
    }
    
    [self hideView:physicsView];
    [self hideView:meshView];
    [self hideView:infoView];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
	CGImageRef imgRef = pickedImage.CGImage;
	
    app->setImage( pickedImage, CGImageGetWidth(imgRef), CGImageGetHeight(imgRef) );
	
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [popover dismissPopoverAnimated:YES];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [popover dismissPopoverAnimated:YES];
    }
}

// Grab image from photo album END
//------------------------------------------------




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