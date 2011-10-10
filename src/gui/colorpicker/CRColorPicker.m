//
//  CRColorPicker.m
//  SimpleColorPicker
//
//  Created by ICRG LABS on 16/01/11.
//

#import "CRColorPicker.h"


@implementation CRColorPicker
@synthesize sourceColorImageView;
@synthesize delegate,currentColor;
@synthesize knobView;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	self.sourceColorImageView = nil;
	self.delegate = nil;
	self.currentColor = nil;
	
	self.knobView = nil;
	
    [super dealloc];
}

#pragma mark -
//- (void)layoutSubviews{
- (void)arrange {
	if(nil == self.sourceColorImageView.superview){
		UIImage *srcColorImage = [UIImage imageNamed:@"colorcource_big.png"];
		CGSize size = srcColorImage.size;
		UIImageView *bg = [[UIImageView alloc] initWithImage:srcColorImage];
		self.sourceColorImageView = bg;
		[self addSubview:bg];
		[bg release];
		
		//reset the new frame 
		CGRect rect = CGRectMake(5, 0, size.width, size.height);
		self.sourceColorImageView.frame = rect;
		
		CGRect viewFrame = self.frame;
		self.backgroundColor = [UIColor clearColor];  
		UIImage *_srcColorImage = [UIImage imageNamed:@"knob_big.png"];
		UIImageView *_bg = [[UIImageView alloc] initWithImage:_srcColorImage];
		self.knobView = _bg;
		[self addSubview:_bg];
		viewFrame = self.knobView.frame;
		viewFrame.origin.x = CGRectGetMidX(self.bounds)-7;
		viewFrame.origin.y += 5;
		self.knobView.frame = viewFrame;
		[_bg release];
		//[self changeColor];
	}
	//NSLog( @"now" );
}	

#pragma mark -
-(void)changeColor
{
	//Get the mid point of the Knob frame and consider this as a reference point and map it with the colorcource.png image. Important here is, u make sure always the knobview superview frame size is equal to the colorcource.png image.
	
	double sliderValueX = self.knobView.frame.origin.x;
	double sliderValueY = self.knobView.frame.origin.y;
	CGPoint point = CGPointMake(sliderValueX, sliderValueY);
	UIColor *colorSelected = [self pixelColorAt:point colorSource:[UIImage imageNamed:@"colorcource_big.png"]]; 
	
	mColorPoint = point;
	
	if([self.delegate respondsToSelector:@selector(selectedColor:fromColorPicker:)]){
		[self.delegate selectedColor:colorSelected fromColorPicker:self];
	}
	self.currentColor = colorSelected;
}


#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
	mTouchStartPoint = [[touches anyObject] locationInView:self];
	
	CGRect newFrame = self.knobView.frame;
	newFrame.origin.x = mTouchStartPoint.x - 9;
	newFrame.origin.y = mTouchStartPoint.y - 9;
	
	float offset = 3.0f;
	
	if(newFrame.origin.x < offset){
		newFrame.origin.x = offset;
	}
	else if(CGRectGetMaxX(newFrame) > CGRectGetWidth(self.bounds)){
		newFrame.origin.x = CGRectGetWidth(self.bounds)-CGRectGetWidth(newFrame);
	}
	
	if(newFrame.origin.y < offset){
		newFrame.origin.y = offset;
	}
	else if(CGRectGetMaxY(newFrame) > CGRectGetHeight(self.bounds)){
		newFrame.origin.y = CGRectGetHeight(self.bounds)-CGRectGetHeight(newFrame);
	}
	
	self.knobView.frame = newFrame;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	CGPoint newPoint = [[touches anyObject] locationInView:self];
	CGRect newFrame = self.knobView.frame;
	newFrame.origin.x += (newPoint.x-mTouchStartPoint.x);
	newFrame.origin.y += (newPoint.y-mTouchStartPoint.y);
	//calculate the new frame...simple login...find the difference between latest two drag points and update the frame. Note that we are chaning only the origin x value of the knob.
	
	float offset = 3.0f;
	
	if(newFrame.origin.x < offset){
		newFrame.origin.x = offset;
	}
	else if(CGRectGetMaxX(newFrame) > CGRectGetWidth(self.bounds)+offset){
		newFrame.origin.x = (CGRectGetWidth(self.bounds)-CGRectGetWidth(newFrame)+offset);
	}
	
	if(newFrame.origin.y < offset){
		newFrame.origin.y = offset;
	}
	else if(CGRectGetMaxY(newFrame) > CGRectGetHeight(self.bounds)+offset){
		newFrame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(newFrame)+offset);
	}
	
	self.knobView.frame = newFrame;
	
	CGRect _frame = self.superview.frame;
	_frame.origin.x += (newPoint.x-mTouchStartPoint.x);
	_frame.origin.y += (newPoint.y-mTouchStartPoint.y);
	//self.superview.frame = newFrame;
	
	mTouchStartPoint = newPoint;
	[self changeColor];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint newPoint = [[touches anyObject] locationInView:self];
	CGRect newFrame = self.knobView.frame;
	newFrame.origin.x = newPoint.x - 9;
	newFrame.origin.y = newPoint.y - 9;
	
	float offset = 3.0f;
	
	if(newFrame.origin.x < offset){
		newFrame.origin.x = offset;
	}
	else if(CGRectGetMaxX(newFrame) > CGRectGetWidth(self.bounds)+offset){
		newFrame.origin.x = CGRectGetWidth(self.bounds)-CGRectGetWidth(newFrame)+offset;
	}
	
	if(newFrame.origin.y < offset){
		newFrame.origin.y = offset;
	}
	else if(CGRectGetMaxY(newFrame) > CGRectGetHeight(self.bounds)+offset){
		newFrame.origin.y = CGRectGetHeight(self.bounds)-CGRectGetHeight(newFrame)+offset;
	}
	self.knobView.frame = newFrame;
	[self changeColor];
}


#pragma mark - 
-(UIColor*)pixelColorAt:(CGPoint)point colorSource:(UIImage*)inImage;{
	UIColor* color = nil;
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
	CGImageRef srcImage = inImage.CGImage;
	CGContextRef cgctx = [self createARGBBitmapContextFromImage:srcImage];
	if (cgctx == NULL) { return nil; /* error */ }
	
	size_t w = CGImageGetWidth(srcImage);
	size_t h = CGImageGetHeight(srcImage);
	CGRect rect = {{0,0},{w,h}}; 
	
	// Draw the image to the bitmap context. Once we draw, the memory 
	// allocated for the context for rendering will then contain the 
	// raw image data in the specified color space.
	CGContextDrawImage(cgctx, rect, srcImage); 
	
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	unsigned char* data = CGBitmapContextGetData (cgctx);
	if (data != NULL) {
		//offset locates the pixel in the data from x,y. 
		//4 for 4 bytes of data per pixel, w is width of one row of data.
		int offset = 4*((w*round(point.y))+round(point.x));
		int alpha =  data[offset]; 
		int red = data[offset+1]; 
		int green = data[offset+2]; 
		int blue = data[offset+3]; 
		//		NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
		color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
	}
	
	// When finished, release the context
	CGContextRelease(cgctx); 
	// Free image data memory for the context
	if (data) { free(data); }
	
	return color;
}

-(CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage;{
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	if (colorSpace == NULL)
		{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
		}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL) 
		{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
		}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
	// per component. Regardless of what the source image format is 
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
	if (context == NULL)
		{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
		}
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
	
	return context;
}

@end
