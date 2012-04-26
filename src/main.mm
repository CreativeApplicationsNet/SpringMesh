#include "ofMain.h"
#include "testApp.h"

int main(){
	
	ofAppiPhoneWindow *iOSWindow = new ofAppiPhoneWindow();
	iOSWindow->enableRetinaSupport();
	//iOSWindow->enableAntiAliasing( 4 );	// this breaks ofxiPhoneScreenGrab()
	
	ofSetupOpenGL( iOSWindow, 1024, 768, OF_FULLSCREEN );			// <-------- setup the GL context
	
	ofRunApp( new testApp );
}
