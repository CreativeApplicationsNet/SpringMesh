#include "testApp.h"
#include "GuiView.h"

GuiView *guiViewController;


//--------------------------------------------------------------
void testApp::setup(){	
	// register touch events
	ofRegisterTouchEvents(this);
	
	// initialize the accelerometer
	ofxAccelerometer.setup();
	
	//iPhoneAlerts will be sent to this.
	ofxiPhoneAlerts.addListener(this);
	
	//If you want a landscape oreintation 
	//iPhoneSetOrientation( OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT );
    
    ofBackground(0, 0, 0); //filip added
	
	ofSetFrameRate( 30 );
    

    
    
    if ( XML.loadFile(ofxiPhoneGetDocumentsDirectory() + "springmesh-settings.xml") ) {
		message = ".xml loaded from documents folder!";
	}
    else if ( XML.loadFile("springmesh-settings.xml") ) {
		message = ".xml loaded from data folder!";
	}
    else {
		message = "unable to load .xml check data/ folder";
	}
	cout << message << endl;
    
    
    drag                = XML.getValue( "PHYSICS:SPRING:DAMPING", 0.4 );
    springStrength      = XML.getValue( "PHYSICS:SPRING:STRENGTH", 2.0 );
    forceRadius         = XML.getValue( "PHYSICS:SPRING:FORCE_RADIUS", 100 );
    isAttractionOn      = XML.getValue( "PHYSICS:SPRING:ATTRACTION", 0 );
    isGravityOn         = XML.getValue( "PHYSICS:SPRING:GRAVITY", 0 );
    
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
		// ipad
		gridSize        = XML.getValue( "PHYSICS:SPRING:GRIDSIZE", 20 );
	}
	else {
		// ipod
		gridSize        = XML.getValue( "PHYSICS:SPRING:GRIDSIZE", 9 );
	}

    isFillsDrawingOn    = XML.getValue( "MESH:VIEW:FILLS", 1 );
    isWiresDrawingOn    = XML.getValue( "MESH:VIEW:WIRES", 0 );
    isPointsDrawingOn   = XML.getValue( "MESH:VIEW:POINTS", 0 );
    colR                = XML.getValue( "MESH:COLOR:RED", 0.2 );
    colG                = XML.getValue( "MESH:COLOR:GREEN", 0.6 );
    colB                = XML.getValue( "MESH:COLOR:BLUE", 1.0 );
    //filip added
    first               = XML.getValue( "MESH:VIEW:FIRST", 1 );
    
    
    gridWidth           = ofGetWidth() - 1;
	gridHeight          = ofGetHeight() - 1;
	
    isSaveImageActive   = false;
    
    
//    // Set gui view  
//    guiViewController = [[GuiView alloc] initWithNibName:@"GuiView" bundle:nil];
//    guiViewController.view.hidden = YES;
//    [ofxiPhoneGetUIWindow() addSubview:guiViewController.view];
    
    if (first == 1){
        // Set gui vie
        guiViewController = [[GuiView alloc] initWithNibName:@"GuiView" bundle:nil];
        guiViewController.view.hidden = NO;
        [ofxiPhoneGetUIWindow() addSubview:guiViewController.view];

    }
    else {
        // Set gui view  
        guiViewController = [[GuiView alloc] initWithNibName:@"GuiView" bundle:nil];
        guiViewController.view.hidden = YES;
        [ofxiPhoneGetUIWindow() addSubview:guiViewController.view];
    }
    
    
    
}


void testApp::init() {
    guiViewController.springDampingSlider.value      = drag;
    guiViewController.springFrequencySlider.value    = springStrength;
    guiViewController.forceRadiusSlider.value        = forceRadius;
    guiViewController.adjustPointsSlider.value        = gridSize;
    [guiViewController.attractionSwitch setOn:isAttractionOn];
    [guiViewController.gravitySwitch setOn:isGravityOn];
    
    [guiViewController.fillsSwitch setOn:isFillsDrawingOn];
    [guiViewController.wiresSwitch setOn:isWiresDrawingOn];
    [guiViewController.pointsSwitch setOn:isPointsDrawingOn];
    guiViewController.colorRSlider.value        = colR;
    guiViewController.colorGSlider.value        = colG;
    guiViewController.colorBSlider.value        = colB;
    
    
    // Init box2d
	box2d.init();
	box2d.setFPS( 30.0f );
	box2d.setIterations( 3, 2 ); // velocity, position
	box2d.setGravity( 0.0f, 0.0f );
    float boundOffset = 4.0f;
    box2d.createBounds( -boundOffset, -boundOffset, ofGetWidth() + boundOffset, ofGetHeight() + boundOffset );
	
    
    buildMesh();
}


void testApp::buildMesh() {
    // Initialize grid
	float gridRatio = gridWidth / gridHeight;
	cols = gridSize;
	rows = (int)( gridSize / gridRatio );
	
    // Add particles to physics world
	float gridColCellDist	= gridWidth / cols;
	float gridRowCellDist	= gridHeight / rows;
	
	int idx = 0;
	for ( int j = 0; j <= rows; j++ ) {
		for ( int i = 0; i <= cols; i++ ) {
			// Calculate grid positions
			float x = gridColCellDist * i;
			float y = gridRowCellDist * j;
			
			// Create particles
			ofxBox2dCircle pA;
            // Make border particles fix to their position
			if ( i == 0 || i == cols || j == 0 || j == rows ) {
				pA.setup( box2d.getWorld(), x, y, 5.0f );
			}
			// Insiders are free
			else {
				pA.setPhysics( 5.0f, 0.1f, 0.1f );
                pA.fixture.filter.groupIndex = -1;
                pA.setup( box2d.getWorld(), x, y, 10.0f );
			}
			particles.push_back( pA );
            
			// Create springs
			ofxBox2dJoint spring;
            if ( i > 0 ) {
				ofxBox2dCircle pB = particles[ idx - 1 ];
				spring.setup( box2d.getWorld(), pA.body, pB.body, springStrength );
                springs.push_back( spring );
			}
			if ( j > 0 ) {
                ofxBox2dCircle pC = particles[ idx - cols - 1 ];
				spring.setup( box2d.getWorld(), pA.body, pC.body, springStrength, drag );
                springs.push_back( spring );
			}
			idx++;
		}
	}
    
    
    // Mesh quad main diagonal
    gridCellDiagonalDist = particles[0].getPosition().distance( particles[2 + cols].getPosition() );
	
    
	// Initialize mesh
    meshFill.reserve( particles.size() * 10 );
	meshFill.setSafeMode( false );
	
}


void testApp::destroyMesh() {
    for ( int s = 0; s < springs.size(); s++ ) {
        springs[s].destroy();
    }
    for ( int p = 0; p < particles.size(); p++ ) {
        particles[p].destroy();
    }
    springs.clear();
    particles.clear();
}



//--------------------------------------------------------------
void testApp::update(){
    
    
    // box2d gravity influence by accelerometer
    if ( isGravityOn ) {
        ofVec2f force;
        force.set( ofxAccelerometer.getForce().x, -ofxAccelerometer.getForce().y );
        force *= 20.0f;
        box2d.setGravity( force.x, force.y );
    }
    else {
        box2d.setGravity( 0, 0 );
    }
    
    box2d.update();
    
    
    // Update particles force
    for ( int i = 0; i < particles.size(); i++ ) {
        for ( int j = 0; j < touchPoints.size(); j++ ) {
            float dis = touchPoints[j].distance( particles[i].getPosition() );
            if ( dis < forceRadius ) {
                ( isAttractionOn ) ? particles[i].addAttractionPoint( touchPoints[j], 9.0f ) : particles[i].addRepulsionForce( touchPoints[j], 40.0f );
            }
            else {
                ( isAttractionOn ) ? particles[i].addAttractionPoint( touchPoints[j], 0.0f ) :
                particles[i].addRepulsionForce( touchPoints[j], 0.0f );
            }
        }
    }
    
    // Update springs
    for ( int i = 0; i < springs.size(); i++ ) {
        springs[i].setDamping( drag );
        springs[i].setFrequency( springStrength );
    }
    
    
    if ( isSaveImageActive ) {
        ofxiPhoneAppDelegate *delegate = ofxiPhoneGetAppDelegate();
        ofxiPhoneScreenGrab( delegate );
    }
    isSaveImageActive = false;
}

//--------------------------------------------------------------
void testApp::draw(){
	ofBackground( 0, 0, 0 );
	
    if ( isFillsDrawingOn ) {
		renderFill();
	}
	if ( isWiresDrawingOn ) {
		ofPushMatrix();
        ofTranslate( 1, 1 );
            renderLines();
        ofPopMatrix();
	}
	if ( isPointsDrawingOn ) {
		renderPoints();
	}
}

//--------------------------------------------------------------
void testApp::exit(){

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
    touchPoints[touch.id] = ofVec2f( touch.x, touch.y );
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){
	touchPoints[touch.id] = ofVec2f( touch.x, touch.y );
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
    if ( touch.numTouches == 0 ) {
        touchPoints.clear();
    }
    else {
        touchPoints.erase( touch.id );
    }
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){
	if ( guiViewController.view.hidden ) {
		guiViewController.view.hidden = NO;
	}
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs& args){
	
}

//--------------------------------------------------------------
void testApp::lostFocus(){

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation) {
    //iPhoneSetOrientation( (ofOrientation)newOrientation );
}



//--------------------------------------------------------------
// ---- Render methods BEGIN

void testApp::renderFill() {
	meshFill.enableNormal( false );
	meshFill.enableColor( true );
	meshFill.enableTexCoord( false );
	meshFill.setClientStates();
	meshFill.begin( GL_TRIANGLES );
	int idx = 0;
	for ( int y = 0; y < rows; y++ ) {
		for ( int x = 0; x < cols; x++ ) {
			int i = x + cols * y;
			i += idx;
			
			int A, B, C, D;
			A = i;
			B = i + 1;
			C = i + 1 + cols;
			D = i + 2 + cols;
			
			ofxBox2dCircle a = particles[A];
            ofxBox2dCircle b = particles[B];
            ofxBox2dCircle c = particles[C];
            ofxBox2dCircle d = particles[D];
            
			float dist	= a.getPosition().distance( d.getPosition() );
			float k		= 1.0f - ( dist / gridCellDiagonalDist );
			k *= 0.25f;
            
            float colorA[3] = { colR - k, colG - k, colB - k };
            float colorB[3] = { colR - k, colG - k, colB - k };
            float colorC[3] = { colR * 0.9f - k, colG * 0.9f - k, colB * 0.9f - k };
            float colorD[3] = { colR * 0.8f - k, colG * 0.8f - k, colB * 0.8f - k };
            /*
             float colorA[3] = { k - colR, k - colG, k - colB };
             float colorB[3] = { k - colR, k - colG, k - colB };
             float colorC[3] = { k - colR * 0.9f, k - colG * 0.9f, k - colB * 0.9f };
             float colorD[3] = { k - colR * 0.8f, k - colG * 0.8f, k - colB * 0.8f };
             */
			meshFill.setColor3v( colorA );
			meshFill.addVertex( a.getPosition().x, a.getPosition().y );
			meshFill.setColor3v( colorB );
			meshFill.addVertex( b.getPosition().x, b.getPosition().y );
			meshFill.setColor3v( colorD );
			meshFill.addVertex( d.getPosition().x, d.getPosition().y );
			
			meshFill.setColor3v( colorA );
			meshFill.addVertex( a.getPosition().x, a.getPosition().y );
			meshFill.setColor3v( colorD );
			meshFill.addVertex( d.getPosition().x, d.getPosition().y );
			meshFill.setColor3v( colorC );
			meshFill.addVertex( c.getPosition().x, c.getPosition().y );
		}
		idx++;
	}
	meshFill.end();
	meshFill.restoreClientStates();
}


void testApp::renderLines() {
    for ( int i = 0; i < springs.size(); i++ ) {
        ofVec2f bodyA( springs[i].joint->GetAnchorA().x, springs[i].joint->GetAnchorA().y );
        ofVec2f bodyB( springs[i].joint->GetAnchorB().x, springs[i].joint->GetAnchorB().y );
        
        float dist  = bodyA.distance( bodyB );
        float k     = (dist / springs[i].getLength());
        //cout << "K: " << k << endl;
        
        ofSetColor( 255 * (colR * k), 255 * (colG * k), 255 * (colB * k) );
        springs[i].draw();
    }
}


void testApp::renderPoints() {
	//glLineWidth( 1.5f );
	float size = 3.0f;
    for ( int i = 0; i < particles.size(); i++ ) {
		ofxBox2dCircle p = particles[i];
		ofSetHexColor( 0xffffff );
        ofLine( p.getPosition().x - size, p.getPosition().y + size, p.getPosition().x + size, p.getPosition().y - size );
		ofLine( p.getPosition().x + size, p.getPosition().y + size, p.getPosition().x - size, p.getPosition().y - size );
	}
}

// ---- Render methods END
//--------------------------------------------------------------




void testApp::saveSettings() {
	XML.setValue( "PHYSICS:SPRING:DAMPING", drag );
    XML.setValue( "PHYSICS:SPRING:STRENGTH", springStrength );
    XML.setValue( "PHYSICS:SPRING:FORCE_RADIUS", forceRadius );
    XML.setValue( "PHYSICS:SPRING:ATTRACTION", isAttractionOn );
    XML.setValue( "PHYSICS:SPRING:GRAVITY", isGravityOn );
    XML.setValue( "PHYSICS:SPRING:GRIDSIZE", gridSize );
    
    XML.setValue( "MESH:VIEW:FILLS", isFillsDrawingOn );
    XML.setValue( "MESH:VIEW:WIRES", isWiresDrawingOn );
    XML.setValue( "MESH:VIEW:POINTS", isPointsDrawingOn );
    XML.setValue( "MESH:COLOR:RED", colR );
    XML.setValue( "MESH:COLOR:GREEN", colG );
    XML.setValue( "MESH:COLOR:BLUE", colB );
    
    //filip added
    XML.setValue( "MESH:VIEW:FIRST", 0 );
    
	XML.saveFile( ofxiPhoneGetDocumentsDirectory() + "springmesh-settings.xml" );
	cout << ".xml saved to app documents folder" << endl;
}
