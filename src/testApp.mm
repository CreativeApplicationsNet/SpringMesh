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
    
    ofDisableArbTex();
    ofEnableNormalizedTexCoords();
    
    
    
    if ( XML.loadFile(ofxiPhoneGetDocumentsDirectory() + "springmesh-settings.xml") ) {
		message = ".xml loaded from documents folder!";
	}
    else if ( XML.loadFile("springmesh-settings.xml") ) {
		message = ".xml loaded from data folder!";
	}
    else {
		message = "unable to load .xml check data/ folder";
	}
	//cout << message << endl;
    
    
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
    
    
    isFillsDrawingOn        = XML.getValue( "MESH:VIEW:FILLS", 1 );
    isWiresDrawingOn        = XML.getValue( "MESH:VIEW:WIRES", 0 );
    isPointsDrawingOn       = XML.getValue( "MESH:VIEW:POINTS", 0 );
    
    isAddBlendModeOn        = XML.getValue( "MESH:VIEW:ADD", 0 );
    isScreenBlendModeOn     = XML.getValue( "MESH:VIEW:SCREEN", 0 );
    
    colR                    = XML.getValue( "MESH:COLOR:RED", 0.2 );
    colG                    = XML.getValue( "MESH:COLOR:GREEN", 0.6 );
    colB                    = XML.getValue( "MESH:COLOR:BLUE", 1.0 );
    colA                    = XML.getValue( "MESH:COLOR:ALPHA", 1.0 );
    first                   = XML.getValue( "MESH:VIEW:FIRST", 1 );
    
    isImageSet              = false;
    isTextureDrawingOn      = false;
    
    isAddBlendModeOn        = false;
    isScreenBlendModeOn     = false;
    
    
    gridWidth               = ofGetWidth();
	gridHeight              = ofGetHeight();
	
    isSaveImageActive       = false;
    
    
//    // Set gui view  
//    guiViewController = [[GuiView alloc] initWithNibName:@"GuiView" bundle:nil];
//    guiViewController.view.hidden = YES;
//    [ofxiPhoneGetUIWindow() addSubview:guiViewController.view];
    
    if ( first == 1 ) {
        // Set gui view
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
    guiViewController.adjustPointsSlider.value       = gridSize;
    [guiViewController.attractionSwitch setOn:isAttractionOn];
    [guiViewController.gravitySwitch setOn:isGravityOn];
    
    [guiViewController.textureSwitch setOn:isTextureDrawingOn];
    [guiViewController.fillsSwitch setOn:isFillsDrawingOn];
    [guiViewController.wiresSwitch setOn:isWiresDrawingOn];
    [guiViewController.pointsSwitch setOn:isPointsDrawingOn];
    guiViewController.colorRSlider.value            = colR;
    guiViewController.colorGSlider.value            = colG;
    guiViewController.colorBSlider.value            = colB;
    guiViewController.colorASlider.value            = colA;
    
    [guiViewController.addBlendSwitch setOn:isAddBlendModeOn];
    [guiViewController.screenBlendSwitch setOn:isScreenBlendModeOn];
    
    
    // Init box2d
	box2d.init();
	box2d.setFPS( 30.0f );
	box2d.setIterations( 3, 2 ); // velocity, position
	box2d.setGravity( 0.0f, 0.0f );
    float boundOffset = 4.0f;
    box2d.createBounds( -boundOffset, -boundOffset, ofGetWidth() + boundOffset, ofGetHeight() + boundOffset );
	
    buildMesh();
}


//--------------------------------------------------------------
void testApp::runRandom(){
    
    destroyMesh();
    
    drag                = ofRandom( 0.0f, 0.5f );
    springStrength      = ofRandom( 0.5f, 4.0f );
    forceRadius         = (int)ofRandom( 80, 100 );
    gridSize            = (int)ofRandom( 9, 20 );

    colR                = ofRandomuf();
    colG                = ofRandomuf();
    colB                = ofRandomuf();
    colA                = ofRandomuf();
    
    guiViewController.springDampingSlider.value     = drag;
    guiViewController.springFrequencySlider.value   = springStrength;
    guiViewController.forceRadiusSlider.value       = forceRadius;
    guiViewController.adjustPointsSlider.value      = gridSize;
    
    guiViewController.colorRSlider.value            = colR;
    guiViewController.colorGSlider.value            = colG;
    guiViewController.colorBSlider.value            = colB;
    guiViewController.colorASlider.value            = colA;
    
    buildMesh();
}



//--------------------------------------------------------------
void testApp::buildMesh() {
    // Initialize grid
	float gridRatio     = gridWidth / gridHeight;
	cols                = gridSize;
	rows                = (int)( gridSize / gridRatio );
	
    
    float spaceX        = gridWidth / (cols-1);
	float spaceY        = gridHeight / (rows-1);
	
    int colSteps        = cols - 1;
	int rowSteps        = rows - 1;
	
    
    int totalQuads		= (cols-1) * (rows-1);
	int totalTriangles	= totalQuads * 2;
	int totalVertices	= cols * rows;
	int totalIndices	= totalTriangles * 3; //(cols*2) * (rows-1);
	
    cout << "total quads: " << totalQuads << endl;
	cout << "total triangles: " << totalTriangles << endl;
	cout << "total vertices: " << totalVertices << endl;
	cout << "total indices: " << totalIndices << endl;
	
    
    // Indices
	for ( int r = 0; r < rowSteps; r++ ) {
		for ( int c = 0; c < colSteps; c++ ) {
			int t = c + r * cols;
			
			int A, B, C, D;
			A = t;
			B = t + 1;
			C = t + cols;
			D = t + cols + 1;
			
			indices.push_back( A );
			indices.push_back( B );
			indices.push_back( D );
			indices.push_back( A );
			indices.push_back( D );
			indices.push_back( C );
		}
	}
    
    
	// Vertex positions
	int idx = 0;
    for ( int y = 0; y < rows; y++ ) {
		for ( int x = 0; x < cols; x++ ) {
			ofVec2f point( x * spaceX, y * spaceY );
            vertices.push_back( point );
            
            // Create particles
            ofxBox2dCircle pA;
            // Make border particles fix to their position
			if ( x == 0 || x == cols-1 || y == 0 || y == rows-1 ) {
				pA.setup( box2d.getWorld(), point.x, point.y, 1.0f );
			}
			// Insiders are free
			else {
				pA.setPhysics( 5.0f, 0.1f, 0.1f );
                pA.fixture.filter.groupIndex = -1;
                pA.setup( box2d.getWorld(), point.x, point.y, 10.0f );
			}
			particles.push_back( pA );
            
            // Create springs
            ofxBox2dJoint spring;
            if ( x > 0 ) {
				ofxBox2dCircle pB = particles[idx - 1];
				spring.setup( box2d.getWorld(), pA.body, pB.body, springStrength, drag );
                springs.push_back( spring );
			}
			if ( y > 0 ) {
                ofxBox2dCircle pC = particles[idx - cols];
				spring.setup( box2d.getWorld(), pA.body, pC.body, springStrength, drag );
                springs.push_back( spring );
			}
            idx++;
            
            
            // Textture coordinates
            ofVec2f textCoordPoint( (x * spaceX) / gridWidth, (y * spaceY) / gridHeight );
			textCoords.push_back( textCoordPoint );
		}
	}
    
    
	mesh.setMode( OF_PRIMITIVE_TRIANGLES );
	mesh.addVertices( vertices );
	mesh.addIndices( indices );
	mesh.addTexCoords( textCoords );
	
	vboMesh.setMesh( mesh, GL_DYNAMIC_DRAW );
    
    
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
    
    textCoords.clear();
    vertices.clear();
    indices.clear();
    
    mesh.clearTexCoords();
    mesh.clearVertices();
    mesh.clearIndices();
    mesh.clear();
    vboMesh.clear();
    
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
	
    ofEnableAlphaBlending();
    
    if ( isAddBlendModeOn ) {
        ofEnableBlendMode( OF_BLENDMODE_ADD );
    }
    
    if ( isScreenBlendModeOn ) {
        ofEnableBlendMode( OF_BLENDMODE_SCREEN );
    }
    
    if ( isTextureDrawingOn ) {
        renderTexturedMesh();   
    }
    
    if ( isFillsDrawingOn ) {
		renderFill();
	}
	
    if ( isWiresDrawingOn ) {
        renderLines();
    }
	
    if ( isPointsDrawingOn ) {
		renderPoints();
	}
    
    ofDisableBlendMode();
    ofDisableAlphaBlending();
    
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
	
    for ( int i = 0; i < indices.size(); i += 6 ) {
        ofIndexType A = indices[i];
        ofIndexType B = indices[i + 1];
        ofIndexType C = indices[i + 2];
        ofIndexType D = indices[i + 3];
        ofIndexType E = indices[i + 4];
        ofIndexType F = indices[i + 5];
        
        ofxBox2dCircle a = particles[A];
        ofxBox2dCircle b = particles[B];
        ofxBox2dCircle c = particles[C];
        ofxBox2dCircle d = particles[D];
        ofxBox2dCircle e = particles[E];
        ofxBox2dCircle f = particles[F];
        
        float dist	= a.getPosition().distance( c.getPosition() );
        float k		= (1.0f - ( dist / gridCellDiagonalDist )) * 0.25f;
        
        float colorA[4] = { colR - k, colG - k, colB - k, colA };
        float colorB[4] = { colR - k, colG - k, colB - k, colA };
        float colorC[4] = { colR * 0.9f - k, colG * 0.9f - k, colB * 0.9f - k, colA };
        float colorD[4] = { colR * 0.8f - k, colG * 0.8f - k, colB * 0.8f - k, colA };
        
        
        meshFill.setColor4v( colorA );
        meshFill.addVertex( a.getPosition().x, a.getPosition().y );
        meshFill.setColor4v( colorB );
        meshFill.addVertex( b.getPosition().x, b.getPosition().y );
        meshFill.setColor4v( colorD );
        meshFill.addVertex( c.getPosition().x, c.getPosition().y );
        
        meshFill.setColor4v( colorA );
        meshFill.addVertex( d.getPosition().x, d.getPosition().y );
        meshFill.setColor4v( colorD );
        meshFill.addVertex( e.getPosition().x, e.getPosition().y );
        meshFill.setColor4v( colorC );
        meshFill.addVertex( f.getPosition().x, f.getPosition().y );
    }
    
	meshFill.end();
	meshFill.restoreClientStates();
}


void testApp::renderLines() {
    int numSprings = springs.size();
    for ( int i = 0; i < numSprings; i++ ) {
        ofVec2f bodyAPos( springs[i].joint->GetAnchorA().x, springs[i].joint->GetAnchorA().y );
        ofVec2f bodyBPos( springs[i].joint->GetAnchorB().x, springs[i].joint->GetAnchorB().y );
        
        float dist  = bodyAPos.distance( bodyBPos );
        float k     = (dist / springs[i].getLength());
        //cout << "K: " << k << endl;
        
        if ( springs[i].joint->GetBodyA()->GetMass() != 0 || springs[i].joint->GetBodyB()->GetMass() != 0 ) {
            ofSetColor( 255 * (colR * k), 255 * (colG * k), 255 * (colB * k), 255 * colA );
            springs[i].draw();
        }
    }
}


void testApp::renderPoints() {
	//glLineWidth( 1.5f );
	int numParticles = particles.size();
    float size = 3.0f;
    for ( int i = 0; i < numParticles; i++ ) {
		ofxBox2dCircle p = particles[i];
		ofSetHexColor( 0xffffff );
        ofLine( p.getPosition().x - size, p.getPosition().y + size, p.getPosition().x + size, p.getPosition().y - size );
		ofLine( p.getPosition().x + size, p.getPosition().y + size, p.getPosition().x - size, p.getPosition().y - size );
	}
}


void testApp::renderTexturedMesh() {
    int numParticles = particles.size();
    ofVec3f positions[numParticles];
    for ( int i = 0; i < particles.size(); i++ ) {
        positions[i] = particles[i].getPosition();
    }
    
    ofSetHexColor( 0xffffff );
	if ( isImageSet ) skinTexture.bind();
    vboMesh.updateVertexData( positions, numParticles );
    vboMesh.drawElements( GL_TRIANGLES, mesh.getNumIndices() );
    if ( isImageSet ) skinTexture.unbind();
    
    //ofSetHexColor( 0xff0000 );
    //mesh.drawWireframe();
}

// ---- Render methods END
//--------------------------------------------------------------



void testApp::setImage( UIImage *inImage, int w, int h ) {
	iPhoneUIImageToOFImage( inImage, skinImage );
	skinTexture.allocate( w, h, GL_RGBA );
	skinTexture.loadData( skinImage.getPixels(), w, h, GL_RGBA );
    
	isImageSet          = true;
    isTextureDrawingOn  = true;
    [guiViewController.textureSwitch setOn:isTextureDrawingOn];
}



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
    
    XML.setValue( "MESH:VIEW:ADD", isAddBlendModeOn );
    XML.setValue( "MESH:VIEW:SCREEN", isScreenBlendModeOn );
    
    XML.setValue( "MESH:COLOR:RED", colR );
    XML.setValue( "MESH:COLOR:GREEN", colG );
    XML.setValue( "MESH:COLOR:BLUE", colB );
    XML.setValue( "MESH:COLOR:ALPHA", colA );
    
    //filip added
    XML.setValue( "MESH:VIEW:FIRST", 0 );
    
	XML.saveFile( ofxiPhoneGetDocumentsDirectory() + "springmesh-settings.xml" );
	cout << ".xml saved to app documents folder" << endl;
}
