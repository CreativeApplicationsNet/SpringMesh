#include "testApp.h"
#include "GuiView.h"

GuiView *guiViewController;



void testApp::setup()
{	
	ofRegisterTouchEvents(this);
	
	ofxAccelerometer.setup();
	
	ofxiPhoneAlerts.addListener(this);
	
	//iPhoneSetOrientation( OFXIPHONE_ORIENTATION_PORTRAIT );
    
    ofBackground( 0, 0, 0 );
    
	ofSetFrameRate( 30 );
    
    ofDisableArbTex();
    ofEnableNormalizedTexCoords();
    
    
    // Load xml settings file
    if ( XML.loadFile(ofxiPhoneGetDocumentsDirectory() + "springmesh-settings.xml") )
	{
		message = ".xml loaded from documents folder!";
	}
    else if ( XML.loadFile("springmesh-settings.xml") )
	{
		message = ".xml loaded from data folder!";
	}
    else
	{
		message = "unable to load .xml check data/ folder";
	}
	
    drag                    = XML.getValue( "PHYSICS:SPRING:DAMPING", 0.4f );
    springStrength          = XML.getValue( "PHYSICS:SPRING:STRENGTH", 2.0f );
    forceRadius             = XML.getValue( "PHYSICS:SPRING:FORCE_RADIUS", 100 );
    
	isGravityOn             = XML.getValue( "PHYSICS:SPRING:GRAVITY", 0 );
    gravityForce			= XML.getValue( "PHYSICS:SPRING:GRAVITY_FORCE", 20.0f );
	
	particleDensity			= XML.getValue( "PHYSICS:SPRING:DENSITY", 10.0f );
	physicsSpeed			= XML.getValue( "PHYSICS:SPRING:SPEED", 60.0f );
	
	isAttractionOn          = XML.getValue( "PHYSICS:SPRING:ATTRACTION", 0 );
    attractionForce			= XML.getValue( "PHYSICS:SPRING:ATTRACTION_FORCE", 30.0f );
	
	isHorizontalSpringsOn   = XML.getValue( "PHYSICS:SPRING:HORIZONTAL", 1 );
    isVerticalSpringsOn     = XML.getValue( "PHYSICS:SPRING:VERTICAL", 1 );
    
	gridSize				= XML.getValue( "PHYSICS:SPRING:GRID_SIZE", 14 );
	
    isFillsDrawingOn        = XML.getValue( "MESH:VIEW:FILLS", 1 );
    isWiresDrawingOn        = XML.getValue( "MESH:VIEW:WIRES", 0 );
    isPointsDrawingOn       = XML.getValue( "MESH:VIEW:POINTS", 0 );
    
    isAddBlendModeOn        = XML.getValue( "MESH:VIEW:ADD", 1 );
    isScreenBlendModeOn     = XML.getValue( "MESH:VIEW:SCREEN", 0 );
    
    firstTimeLaunch         = XML.getValue( "MESH:VIEW:FIRST", 1 );
    
	knobPositionX			= XML.getValue( "MESH:COLOR:KNOB_X", 9.0f );
    knobPositionY			= XML.getValue( "MESH:COLOR:KNOB_Y", 9.0f );
	colA                    = XML.getValue( "MESH:COLOR:ALPHA", 1.0f );
    
    isImageSet              = false;
    isTextureDrawingOn      = false;
    isBox2dPaused			= false;
	isSaveImageActive		= false;
    
    appWidth				= ofGetWidth();
	appHeight				= ofGetHeight();
	
	
    // Set gui view
	guiViewController = [[GuiView alloc] initWithNibName:@"GuiView" bundle:nil];
	[ofxiPhoneGetGLView() addSubview:guiViewController.view];
	//[ofxiPhoneGetUIWindow() addSubview:guiViewController.view];
}


/*
 *	First load settings from xml file,
 *	then initialize box2d physics
 *	first time buldMesh() is called
 */
void testApp::init()
{
	// Load xml settings and update guiview
	loadSettings();
	
    // Init box2d
	float boundOffset	= 4.0f;
	timeStep			= 1.0f / physicsSpeed;
	
    box2d.init();
    box2d.setFPS( physicsSpeed );
	box2d.setIterations( 2, 2 ); // velocity, position
	box2d.setGravity( 0, 0 );
    box2d.createBounds( -boundOffset, -boundOffset, ofGetWidth() + boundOffset, ofGetHeight() + boundOffset );
	
    buildMesh();
}


/*
 *	Randomize a set of variables and attributes
 */
void testApp::runRandom()
{
    destroyMesh();
    
    drag                = ofRandom( 0.0f, 0.5f );
    springStrength      = ofRandom( 0.5f, 4.0f );
    forceRadius         = (int)ofRandom( 80, 100 );
    gridSize            = (int)ofRandom( 9, 20 );
	
	knobPositionX		= ofRandom( 9.0f, 245.0f );
	knobPositionY		= ofRandom( 9.0f, 111.0f );
	
    colA				= ofRandomuf();
    
	// Update gui controls
	updateColorPicker();
	[guiViewController.alphaColorSlider setValue:colA];
	[guiViewController.dampingSlider setValue:drag];
	[guiViewController.frequencySlider setValue:springStrength];
	[guiViewController.touchRadiusSlider setValue:forceRadius];
	[guiViewController.resolutionSlider setValue:gridSize];
	
	[guiViewController.simulationSpeedSlider setValue:ofRandom( 30.0f, 230.0f )];
	[guiViewController.gravityForceSlider setValue:ofRandom( -20.0f, 20.0f )];
	[guiViewController.densitySlider setValue:ofRandom( 5.0f, 30.0f )];
	
    buildMesh();
}



/*
 *	Creates a mesh using vbo,
 *	its dimensions are realtive to device screen
 *	and resolution slider
 */
void testApp::buildMesh()
{
    // Initialize grid
	float gridRatio     = appWidth / appHeight;
	cols                = gridSize;
	rows                = (int)( gridSize / gridRatio );
	
    float spaceX        = appWidth / (cols-1);
	float spaceY        = appHeight / (rows-1);
	
    int colSteps        = cols - 1;
	int rowSteps        = rows - 1;
    
    // Indices
	for ( int r = 0; r < rowSteps; r++ )
	{
		for ( int c = 0; c < colSteps; c++ )
		{
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
    
	for ( int y = 0; y < rows; y++ )
	{
		for ( int x = 0; x < cols; x++ )
		{
			ofVec2f point( x * spaceX, y * spaceY );
            vertices.push_back( point );
            
            // Create particles
            ofxBox2dCircle pA;
            // Make border particles fix to their position
			if ( x == 0 || x == cols-1 || y == 0 || y == rows-1 )
			{
				pA.setup( box2d.getWorld(), point.x, point.y, 1.0f );
			}
			// Insiders are free
			else
			{
				pA.setPhysics( particleDensity, 0.1f, 0.5f );
                pA.fixture.filter.groupIndex = -1;
                pA.setup( box2d.getWorld(), point.x, point.y, 5.0f );
			}
			particles.push_back( pA );
            
            // Create springs
            ofxBox2dJoint spring;
            if ( x > 0 && isHorizontalSpringsOn )
			{
				ofxBox2dCircle pB = particles[idx - 1];
				spring.setup( box2d.getWorld(), pA.body, pB.body, springStrength, drag, false );
                springs.push_back( spring );
			}
			if ( y > 0 && isVerticalSpringsOn )
			{
                ofxBox2dCircle pC = particles[idx - cols];
				spring.setup( box2d.getWorld(), pA.body, pC.body, springStrength, drag, false );
                springs.push_back( spring );
			}
            idx++;
            
            // Add colors
            colors.push_back( ofFloatColor( 1, 1, 1 ) );
            
            // Textture coordinates
            ofVec2f textCoordPoint;
			if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
			{
				textCoordPoint = ofVec2f( (y * spaceY) / appHeight, (x * spaceX) / appWidth );
			}
			else
			{
				textCoordPoint = ofVec2f( (x * spaceX) / appWidth, (y * spaceY) / appHeight );
			}
			textCoords.push_back( textCoordPoint );
		}
	}
    
	mesh.setMode( OF_PRIMITIVE_TRIANGLES );
	mesh.addIndices( indices );
    mesh.addColors( colors );
	mesh.addVertices( vertices );
    mesh.addTexCoords( textCoords );
	
	vbo.setMesh( mesh, GL_DYNAMIC_DRAW );
    
    // Mesh quad main diagonal
    gridCellDiagonalDist = particles[0].getPosition().distance( particles[2 + cols].getPosition() );
    
	// Initialize mesh
    meshFill.reserve( particles.size() * 10 );
	meshFill.setSafeMode( false );
}


/*
 *	Destroys current vbo mesh, physics and
 *	clears all containers
 */
void testApp::destroyMesh()
{
    for ( int s = 0; s < springs.size(); s++ )
	{
        springs[s].destroy();
    }
    
	for ( int p = 0; p < particles.size(); p++ )
	{
        particles[p].destroy();
    }
    
	springs.clear();
    particles.clear();
    
    textCoords.clear();
    colors.clear();
    vertices.clear();
    indices.clear();
    
    mesh.clearTexCoords();
    mesh.clearVertices();
    mesh.clearIndices();
    mesh.clear();
    
	vbo.clear();
}


//--------------------------------------------------------------
void testApp::update()
{
    // box2d gravity influence by accelerometer
    if ( isGravityOn )
	{
        ofVec2f force;
        force.set( ofxAccelerometer.getForce().x, -ofxAccelerometer.getForce().y );
        force *= gravityForce;
        box2d.setGravity( force.x, force.y );
    }
    else
	{
        box2d.setGravity( 0, 0 );
    }
    
    box2d.setFPS( physicsSpeed );
	//box2d.update();
	
	// Controls physics world time
	if ( isBox2dPaused )
	{
		timeStep = 0;
	}
	else
	{
		timeStep = 1.0f / physicsSpeed;
	}
	box2d.world->Step( timeStep, 2, 2 );
	
    
    // Update particles force
    for ( int i = 0; i < particles.size(); i++ )
	{
        particles[i].setDensity( particleDensity );
		
		for ( int j = 0; j < touchPoints.size(); j++ )
		{
            float dis = touchPoints[j].distance( particles[i].getPosition() );
            
			if ( dis < forceRadius )
			{
                if ( isAttractionOn )
				{
					particles[i].addAttractionPoint( touchPoints[j], attractionForce );
				}
				else
				{
					particles[i].addRepulsionForce( touchPoints[j], attractionForce );
				}
            }
            else
			{
                if ( isAttractionOn )
				{
					particles[i].addAttractionPoint( touchPoints[j], 0 );
				}
				else 
				{
					particles[i].addRepulsionForce( touchPoints[j], 0 );
				}
                
            }
        }
    }
    
    // Update springs
    for ( int i = 0; i < springs.size(); i++ )
	{
        springs[i].setDamping( drag );
        springs[i].setFrequency( springStrength );
    }
    
    
	// Screen grab
    if ( isSaveImageActive )
	{
		// This methods has been updated with the follwing code
		// by jasonwalters http://forum.openframeworks.cc/index.php/topic,6092.15.html
		ofxiPhoneScreenGrab( NULL );
    }
    
	isSaveImageActive = false;
	
}


//--------------------------------------------------------------
void testApp::draw()
{
	ofBackground( 0, 0, 0 );
	
    ofEnableAlphaBlending();
    
    if ( isAddBlendModeOn )
	{
        ofEnableBlendMode( OF_BLENDMODE_ADD );
    }
    
    if ( isScreenBlendModeOn )
	{
        ofEnableBlendMode( OF_BLENDMODE_SCREEN );
    }
    
    if ( isTextureDrawingOn )
	{
        renderTexturedMesh();   
    }
    
    if ( isFillsDrawingOn )
	{
		renderFill();
	}
	
    if ( isWiresDrawingOn )
	{
        renderLines();
    }
	
    if ( isPointsDrawingOn )
	{
		renderPoints();
	}
    
    ofDisableBlendMode();
    ofDisableAlphaBlending();
}


//--------------------------------------------------------------
void testApp::exit()
{

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch)
{
	touchPoints[touch.id] = ofVec2f( touch.x, touch.y );
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch)
{
	touchPoints[touch.id] = ofVec2f( touch.x, touch.y );
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch)
{
    if ( touch.numTouches == 0 )
	{
        touchPoints.clear();
    }
    else
	{
        touchPoints.erase( touch.id );
    }
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch)
{
	// Hides and show gui
	guiViewController.view.hidden = !guiViewController.view.hidden;
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs& args)
{
	
}

//--------------------------------------------------------------
void testApp::lostFocus()
{

}

//--------------------------------------------------------------
void testApp::gotFocus()
{

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning()
{

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation)
{
    //iPhoneSetOrientation( (ofOrientation)newOrientation );
	//cout << "new orientation: " << newOrientation << endl;
}




void testApp::renderFill()
{
	meshFill.enableNormal( false );
	meshFill.enableColor( true );
	meshFill.enableTexCoord( false );
	meshFill.setClientStates();
	meshFill.begin( GL_TRIANGLES );
	
    for ( int i = 0; i < indices.size(); i += 6 )
	{
        ofIndexType A		= indices[i];
        ofIndexType B		= indices[i + 1];
        ofIndexType C		= indices[i + 2];
        ofIndexType D		= indices[i + 3];
        ofIndexType E		= indices[i + 4];
        ofIndexType F		= indices[i + 5];
        
        ofxBox2dCircle a	= particles[A];
        ofxBox2dCircle b	= particles[B];
        ofxBox2dCircle c	= particles[C];
        ofxBox2dCircle d	= particles[D];
        ofxBox2dCircle e	= particles[E];
        ofxBox2dCircle f	= particles[F];
        
        float dist1			= a.getPosition().distance( c.getPosition() );
        float dist2			= d.getPosition().distance( f.getPosition() );
        
		float colFactor0	= 0.8f;
		float colFactor1	= 0.9f;
		
        float k				= 0.65f - (((dist1 + dist2) / 2.0f) / gridCellDiagonalDist);
        float colorA[4]		= { colR - k, colG - k, colB - k, colA };
        float colorB[4]		= { colR - k, colG - k, colB - k, colA };
        float colorC[4]		= { colR * colFactor0 - k, colG * colFactor0 - k, colB * colFactor0 - k, colA };
        float colorD[4]		= { colR * colFactor1 - k, colG * colFactor1 - k, colB * colFactor1 - k, colA };
        
        
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


void testApp::renderLines()
{
	ofSetLineWidth( 1.5f );
    
	int numSprings = springs.size();
    
	for ( int i = 0; i < numSprings; i++ )
	{
        ofVec2f bodyAPos( springs[i].joint->GetAnchorA().x, springs[i].joint->GetAnchorA().y );
        ofVec2f bodyBPos( springs[i].joint->GetAnchorB().x, springs[i].joint->GetAnchorB().y );
        
        float dist  = bodyAPos.distance( bodyBPos );
        float k     = (dist / springs[i].getLength());
        
        if ( springs[i].joint->GetBodyA()->GetMass() != 0 || springs[i].joint->GetBodyB()->GetMass() != 0 )
		{
            ofSetColor( 255 * (colR * k), 255 * (colG * k), 255 * (colB * k), 255 * colA );
            springs[i].draw();
        }
    }
}


void testApp::renderPoints()
{
	//glLineWidth( 1.5f );
	int numParticles = particles.size();
    
	float size = 4.0f;
    
	for ( int i = 0; i < numParticles; i++ )
	{
		ofxBox2dCircle p = particles[i];
		//ofLine( p.getPosition().x - size, p.getPosition().y + size, p.getPosition().x + size, p.getPosition().y - size );
		//ofLine( p.getPosition().x + size, p.getPosition().y + size, p.getPosition().x - size, p.getPosition().y - size );
		ofSetColor( 255, 255, 255 );
		ofRect( p.getPosition().x - (size * 0.5f), p.getPosition().y - (size * 0.5f), size, size );
	}
}


void testApp::renderTexturedMesh()
{
    int numParticles = particles.size();
    
	vector<ofVec3f>positions(numParticles);
    
	for ( int i = 0; i < numParticles; i++ )
	{
        positions[i] = particles[i].getPosition();
    }
    
    if ( isImageSet )
	{
		skinTexture.bind();
	}
    
	ofSetHexColor( 0xffffff );
	vbo.updateVertexData( &positions[0], numParticles );
    vbo.drawElements( GL_TRIANGLES, mesh.getNumIndices() );
    
	if ( isImageSet )
	{
		skinTexture.unbind();
	}
}



void testApp::setImage( UIImage *inImage, int w, int h )
{
	iPhoneUIImageToOFImage( inImage, skinImage );
	skinTexture.allocate( w, h, GL_RGBA );
	skinTexture.loadData( skinImage.getPixels(), w, h, GL_RGBA );
    
	isImageSet          = true;
    isTextureDrawingOn  = true;
}



void testApp::loadSettings()
{
	// Color settings
	updateColorPicker();
	
    guiViewController.alphaColorSlider.value		= colA;
    [guiViewController.addBlendSwitch setOn:isAddBlendModeOn];
    [guiViewController.screenBlendSwitch setOn:isScreenBlendModeOn];
	
	// Mesh settigns
    [guiViewController.textureSwitch setOn:isTextureDrawingOn];
    [guiViewController.fillsSwitch setOn:isFillsDrawingOn];
    [guiViewController.wiresSwitch setOn:isWiresDrawingOn];
    [guiViewController.pointsSwitch setOn:isPointsDrawingOn];
	guiViewController.resolutionSlider.value		= gridSize;
	
	// Physics settings
	guiViewController.simulationSpeedSlider.value	= physicsSpeed;
	guiViewController.touchRadiusSlider.value		= forceRadius;
    guiViewController.gravityForceSlider.value		= gravityForce;
	[guiViewController.attractionForceSwitch setOn:isAttractionOn];
    [guiViewController.gravitySwitch setOn:isGravityOn];
    
	// Spring settings
	guiViewController.dampingSlider.value			= drag;
    guiViewController.frequencySlider.value			= springStrength;
    guiViewController.densitySlider.value			= particleDensity;
	[guiViewController.horizontalConnSwitch setOn:isHorizontalSpringsOn];
	[guiViewController.verticalConnSwitch setOn:isVerticalSpringsOn];
	
}



void testApp::saveSettings()
{
	XML.setValue( "PHYSICS:SPRING:DAMPING", drag );
	XML.setValue( "PHYSICS:SPRING:STRENGTH", springStrength );
	XML.setValue( "PHYSICS:SPRING:FORCE_RADIUS", forceRadius );
	XML.setValue( "PHYSICS:SPRING:ATTRACTION", isAttractionOn );
	XML.setValue( "PHYSICS:SPRING:GRAVITY", isGravityOn );
	XML.setValue( "PHYSICS:SPRING:GRID_SIZE", gridSize );
    
	XML.setValue( "PHYSICS:SPRING:HORIZONTAL", isHorizontalSpringsOn );
	XML.setValue( "PHYSICS:SPRING:VERTICAL", isVerticalSpringsOn );
    
	XML.setValue( "PHYSICS:SPRING:GRAVITY_FORCE", gravityForce );
	XML.setValue( "PHYSICS:SPRING:ATRACTION_FORCE", attractionForce );
	XML.setValue( "PHYSICS:SPRING:SPEED", physicsSpeed );
	XML.setValue( "PHYSICS:SPRING:DENSITY", particleDensity );
	
    
	XML.setValue( "MESH:VIEW:FILLS", isFillsDrawingOn );
	XML.setValue( "MESH:VIEW:WIRES", isWiresDrawingOn );
	XML.setValue( "MESH:VIEW:POINTS", isPointsDrawingOn );
    
	XML.setValue( "MESH:VIEW:ADD", isAddBlendModeOn );
	XML.setValue( "MESH:VIEW:SCREEN", isScreenBlendModeOn );
    	
	XML.setValue( "MESH:VIEW:FIRST", 0 );
	
	XML.setValue( "MESH:COLOR:KNOB_X", knobPositionX );
	XML.setValue( "MESH:COLOR:KNOB_Y", knobPositionY );
	XML.setValue( "MESH:COLOR:ALPHA", colA );
    
	XML.saveFile( ofxiPhoneGetDocumentsDirectory() + "springmesh-settings.xml" );
	cout << ".xml saved to app documents folder" << endl;
}



void testApp::updateColorPicker()
{
	CGRect colorPickerFrame		= guiViewController.colorPickerView.knobView.frame;
	colorPickerFrame.origin.x	= knobPositionX;
	colorPickerFrame.origin.y	= knobPositionY;
	
	guiViewController.colorPickerView.knobView.frame = colorPickerFrame;
	[guiViewController.colorPickerView changeColor];
}
