#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "MSAShape3D.h"
#include "ofxBox2d.h"

#include "ofxXmlSettings.h"

#define MAX_TOUCH_POINTS 3


class testApp : public ofxiPhoneApp {
	
public:
	void setup();
	void update();
	void draw();
	void exit();
	
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
	void touchCancelled(ofTouchEventArgs &touch);

	void lostFocus();
	void gotFocus();
	void gotMemoryWarning();
	void deviceOrientationChanged(int newOrientation);
	
	void init();
	
    void renderFill();
    void renderLines();
	void renderPoints();
	
    void saveSettings();
    
	int cols, rows;
	int gridSize;
	
	float gridWidth;
    float gridHeight;
    float gridCellDiagonalDist;
	
	float drag;
    float springStrength;
    float forceRadius;
    float colR, colG, colB;
    
    bool isFillsDrawingOn;
    bool isWiresDrawingOn;
    bool isPointsDrawingOn;
    bool isAttractionOn, isGravityOn;
    bool isSaveImageActive;
    
    ofxBox2d box2d;
    
    vector<ofxBox2dCircle> particles;
    vector<ofxBox2dJoint> springs;
    
    map<int, ofVec2f>touchPoints;
    
	MSA::Shape3D meshFill;
	
    ofxXmlSettings XML;
    string xmlStructure;
    string message;

};


