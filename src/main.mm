#include "ofMain.h"
#include "testApp.h"

int main(){
	
	ofAppiPhoneWindow *iOSWindow = new ofAppiPhoneWindow();
	iOSWindow->enableRetinaSupport();
	//iOSWindow->enableAntiAliasing( 4 );	// this breaks ofxiPhoneScreenGrab()
	
	ofSetupOpenGL( iOSWindow, 480, 320, OF_FULLSCREEN );			// <-------- setup the GL context
	
	ofRunApp( new testApp );
}
