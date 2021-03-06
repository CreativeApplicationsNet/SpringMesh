#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "MSAShape3D.h"
#include "ofxBox2d.h"

#include "ofxXmlSettings.h"

#define MAX_TOUCH_POINTS 3


class testApp : public ofxiPhoneApp
{
	
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
    
    void runRandom();
	
    void buildMesh();
    void destroyMesh();
    
    
    void renderFill();
    void renderLines();
	void renderPoints();
	void renderTexturedMesh();
    
    void setImage( UIImage *inImage, int w, int h );
    
	void loadSettings();
    void saveSettings();
    
    void updateColorPicker();
	
    
	int cols, rows;
	int gridSize;
	
	float appWidth;
    float appHeight;
    float gridCellDiagonalDist;
	
	float drag;
    float springStrength;
    float forceRadius;
    float particleDensity;
	float gravityForce;
	float physicsSpeed;
	float attractionForce;
	float colR, colG, colB, colA;
    
    float firstTimeLaunch;
	
	float timeStep;
	
	float knobPositionX, knobPositionY;
	
    bool isFillsDrawingOn;
    bool isWiresDrawingOn;
    bool isPointsDrawingOn;
    bool isAttractionOn, isGravityOn;
    bool isSaveImageActive;
    bool isTextureDrawingOn;
    bool isImageSet;
    bool isAddBlendModeOn;
    bool isScreenBlendModeOn;
    bool isHorizontalSpringsOn;
    bool isVerticalSpringsOn;
    
	bool isBox2dPaused;
	
    ofxBox2d                box2d;
    
    vector<ofxBox2dCircle>  particles;
    vector<ofxBox2dJoint>   springs;
    
    vector<ofIndexType>     indices;
	vector<ofVec3f>         vertices;
	vector<ofFloatColor>    colors;
    vector<ofVec2f>         textCoords;
	
    
    map<int, ofVec2f>       touchPoints;
    
	MSA::Shape3D            meshFill;
	
    ofxXmlSettings          XML;
    string                  xmlStructure;
    string                  message;
    
    
    ofImage                 skinImage;
	ofTexture               skinTexture;
	
    ofMesh                  mesh;
	ofVbo                   vbo;
};


