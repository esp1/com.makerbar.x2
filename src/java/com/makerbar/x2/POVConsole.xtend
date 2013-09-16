package com.makerbar.x2

import java.awt.event.KeyEvent
import java.io.File
import java.io.FileReader
import java.util.HashMap
import java.util.Properties
import javax.swing.JFileChooser
import javax.swing.JOptionPane
import javax.swing.filechooser.FileNameExtensionFilter
import processing.core.PApplet
import processing.core.PGraphics
import processing.core.PImage
import processing.video.Capture
import processing.video.Movie

import static java.awt.event.KeyEvent.*
import static javax.swing.JFileChooser.*
import gifAnimation.Gif

class POVConsole extends PApplet {

	static val WIDTH = 4 * 56
	static val HEIGHT = 6 * 17

	def static void main(String[] args) {
		PApplet::main("com.makerbar.x2.POVConsole")
	}
	
	//
	
	PImage image
	Gif gif
	Movie movie
	Capture camera
	String selectedCamera
	
	PGraphics pg
	
	int imageWidth
	int imageHeight
	float imageScaleFactor = 1
	int imageXOffset
	int imageYOffset
	
	int globeXOffset
	int globeYOffset
	
	long then = System::currentTimeMillis / 33
	int rotationSpeed
	int rotationDirection = 1
	boolean flipImage = false
	
	float brightness = 0
	float contrast = 1
	
	var boolean dirty
	
	double fps
	
	override setup() {
		size(700, 300)
		
		frameRate(30)
		
		pg = createGraphics(WIDTH, HEIGHT)
		
		loadProperties
	}
	
	override draw() {
		val now = System::currentTimeMillis / 33
		if (now > then) {
			setGlobeXOffset(globeXOffset + (rotationSpeed * rotationDirection))
			then = now
		}
		
		// Clear
		background(100)
		
		pushMatrix
		translate(40, 80)
		
		if (flipImage) {
			scale(-1, 1)
			translate(-(WIDTH - 1), 0)
		}
		
		drawImage
		
		// Draw frame
		pushStyle
		stroke(200)
		noFill
		rect(-1, -1, WIDTH + 1, HEIGHT + 1)
		popStyle
		
		popMatrix

		text('''Display dimensions: «WIDTH» x «HEIGHT»''', 40, 80 - 20 - textDescent)
		
		displayText
		
		if (dirty) {
//			fps = X2Client::sendData(pg)
			dirty = false
		}
		
		text(String::format("%1.2f FPS", fps), 40, 80 + HEIGHT + 20 + textAscent)
	}
	
	def drawImage() {
		// Draw image on pg
		pg.beginDraw
		pg.background(100)
		
		// Tile globe image
		if (image != null) {
			// Apply brightness & contrast
			val xImg = new PImage(image.width, image.height)
			image.loadPixels
			for (i : 0 ..< image.width * image.height) {
				val inColor = image.pixels.get(i)
				var r = (inColor >> 16).bitwiseAnd(0xFF)
       			var g = (inColor >> 8).bitwiseAnd(0xFF)
       			var b = inColor.bitwiseAnd(0xFF)

				// apply contrast (multiplication) and brightness (addition)
				r = (r * contrast + brightness) as int
				g = (g * contrast + brightness) as int
				b = (b * contrast + brightness) as int
   
				r = if (r < 0) 0 else if (r > 255) 255 else r
				g = if (g < 0) 0 else if (g > 255) 255 else g
				b = if (b < 0) 0 else if (b > 255) 255 else b
   
				xImg.pixels.set(i, 0xff000000.bitwiseOr(r << 16).bitwiseOr(g << 8).bitwiseOr(b))
			}
			xImg.updatePixels
			
			// Draw globe
			val minX = if (globeXOffset > 0) globeXOffset - WIDTH else globeXOffset
			val minY = if (globeYOffset > 0) globeYOffset - HEIGHT else globeYOffset
			
			var x = minX
			while (x < WIDTH) {
				var y = minY
				while (y < HEIGHT) {
					if (camera != null && camera.available) {
						camera.read
						dirty = true
					}
					
					pg.pushMatrix
					pg.translate(x, y)
					pg.translate(imageXOffset, imageYOffset)
					pg.scale(imageScaleFactor)
					pg.image(xImg, 0, 0)
					pg.popMatrix
					
					y = y + HEIGHT
				}
				
				x = x + WIDTH
			}
		}
		
		pg.endDraw
		
		// Draw pg to screen
		image(pg, 0, 0)
	}
	
	def void movieEvent(Movie m) {
		m.read
		dirty = true
	}
	
	def displayText() {
		pushMatrix
		pushStyle
		
		translate(400, 20)
		
		stroke(255)
		text('''
			l : re/load properties
			o : open image file
			c : capture video
			
			----
			
			«IF image != null»
				+/- : scale image
				arrow keys : image offset
				(hold shift for fine scale/offset)
				0-9 : rotation speed
				R : change rotation direction
				F : flip image
			«ENDIF»
			
			«IF rotationSpeed > 0»rotation speed: «rotationSpeed»«ENDIF»
			«IF flipImage»flipped«ENDIF»
			«IF brightness != 0»brightness: «brightness»«ENDIF»
			«IF contrast != 1»contrast: «contrast»«ENDIF»
			«IF imageScaleFactor != 1»scale factor: «imageScaleFactor»«ENDIF»
			«IF globeXOffset != 0»x offset: «globeXOffset»«ENDIF»
			«IF globeYOffset != 0»y offset: «globeYOffset»«ENDIF»
			''', 0, 0)
		
		popStyle
		popMatrix
	}
	
	override keyPressed(KeyEvent event) {
		if (image == null) {
			switch (event.keyCode) {
				case VK_O: openImageFile
				case VK_C: captureVideo
			}
		} else {
			val factor = if (event.shiftDown) 1 else 10
			switch (event.keyCode) {
				case VK_L: loadProperties
				
				case VK_O: openImageFile
				case VK_C: captureVideo
				
				case VK_EQUALS: setImageScaleFactor(imageScaleFactor + 0.01f * factor)
				case VK_MINUS: setImageScaleFactor(imageScaleFactor - 0.01f * factor)
				
				case VK_LEFT: setGlobeXOffset(globeXOffset - 1 * factor)
				case VK_RIGHT: setGlobeXOffset(globeXOffset + 1 * factor)
				case VK_UP: setGlobeYOffset(globeYOffset - 1 * factor)
				case VK_DOWN: setGlobeYOffset(globeYOffset + 1 * factor)
				
				case VK_0: rotationSpeed = 0
				case VK_1: rotationSpeed = 1
				case VK_2: rotationSpeed = 2
				case VK_3: rotationSpeed = 3
				case VK_4: rotationSpeed = 4
				case VK_5: rotationSpeed = 5
				case VK_6: rotationSpeed = 6
				case VK_7: rotationSpeed = 7
				case VK_8: rotationSpeed = 8
				case VK_9: rotationSpeed = 9
				case VK_R: toggleRotationDirection
				
				case VK_F: toggleFlipImage
				
				case VK_S: setBrightness(brightness - 1 * factor)
				case VK_W: setBrightness(brightness + 1 * factor)
				
				case VK_A: setContrast(contrast - 1 * factor)
				case VK_D: setContrast(contrast + 1 * factor)
				
				case VK_ESCAPE: resetSettings
			}
			
			dirty = true
		}
	}
	
	def setImageScaleFactor(float scaleFactor) {
		this.imageScaleFactor = scaleFactor
	}
	
	def setGlobeXOffset(int xOffset) {
		globeXOffset = xOffset % WIDTH
		if (globeXOffset < 0) globeXOffset = globeXOffset + WIDTH
	}
	
	def setGlobeYOffset(int yOffset) {
		globeYOffset = yOffset % HEIGHT
		if (globeYOffset < 0) globeYOffset = globeYOffset + HEIGHT
	}
	
	def toggleRotationDirection() {
		rotationDirection = if (rotationDirection == 1) -1 else 1
	}
	
	def toggleFlipImage() {
		flipImage = !flipImage
		rotationDirection = if (rotationDirection == 1) -1 else 1
	}
	
	def setBrightness(float brightness) {
		this.brightness = brightness
	}
	
	def setContrast(float contrast) {
		this.contrast = if (contrast <= 0) 1 else contrast
	}
	
	def resetSettings() {
		if (movie != null) {
			movie.stop
			movie = null
		}
		if (camera != null) {
			camera.stop
			camera = null
		}
		
		globeXOffset = 0
		globeYOffset = 0
		
		rotationSpeed = 0
		rotationDirection = 1
		flipImage = false
		
		brightness = 0
		contrast = 1
	}
	
	def loadProperties() {
		val properties = new Properties
		val file = new File("pov-console.properties")
		// Load properties file if it exists
		if (file.exists) {
			val reader = new FileReader(file)
			properties.load(reader)
			reader.close
			
			val imageFileProperty = properties.getProperty("imageFile")
			if (imageFileProperty != null) setImage(loadImage(imageFileProperty))
			
			val movieFileProperty = properties.getProperty("movieFile")
			if (movieFileProperty != null) (movie = setImage(new Movie(this, movieFileProperty))).loop
			
			selectedCamera = properties.getProperty("camera")
			
			val scaleFactorProperty = properties.getProperty("scaleFactor")
			if (scaleFactorProperty != null) setImageScaleFactor(Float::parseFloat(scaleFactorProperty))
			
			val xOffsetProperty = properties.getProperty("xOffset")
			if (xOffsetProperty != null) setGlobeXOffset(Integer::parseInt(xOffsetProperty))
			
			val yOffsetProperty = properties.getProperty("yOffset")
			if (yOffsetProperty != null) setGlobeYOffset(Integer::parseInt(yOffsetProperty))
		}
	}
	
	val imageFileFilter = new FileNameExtensionFilter("Image file (*.png, *.jpg, *.bmp)", #{ "png", "jpg", "bmp" })
	val gifImageFileFilter = new FileNameExtensionFilter("GIF Image file (*.gif)", #{ "gif" })
	val movieFileFilter = new FileNameExtensionFilter("Movie file (*.mov)", #{ "mov" })
	val fileChooser = new JFileChooser(new File(".")) => [
		acceptAllFileFilterUsed = false
		addChoosableFileFilter = imageFileFilter
		addChoosableFileFilter = gifImageFileFilter
		addChoosableFileFilter = movieFileFilter
		fileFilter = imageFileFilter
	]
	
	def void openImageFile() {
		if (fileChooser.showOpenDialog(this) == APPROVE_OPTION) {
			val selectedFile = fileChooser.selectedFile
			switch (fileChooser.fileFilter) {
				case imageFileFilter: {
					println('''Image file: «selectedFile.canonicalPath»''')
					setImage(loadImage(selectedFile.canonicalPath))
				}
				case gifImageFileFilter: {
					println('''GIF Image file: «selectedFile.canonicalPath»''')
					gif = setImage(new Gif(this, selectedFile.canonicalPath))
					gif.loop
				}
				case movieFileFilter: {
					println('''Movie file: «selectedFile.canonicalPath»''')
					movie = setImage(new Movie(this, selectedFile.canonicalPath))
					movie.loop
				}
			}
		}
	}
	
	def void captureVideo() {
		if (selectedCamera == null) {
			cursor(WAIT)
			val cameras = Capture::list
			cursor(ARROW)
			selectedCamera = JOptionPane::showInputDialog(this, "", "Select camera", JOptionPane::PLAIN_MESSAGE, null, cameras, null) as String
		}
		
		if (selectedCamera != null) {
			println('''Opening camera «selectedCamera»''')
			
			val cameraProperties = new HashMap<String, String>
			for (p : selectedCamera.split(",")) {
				val kv = p.split("=")
				cameraProperties.put(kv.get(0), kv.get(1))
			}
			
			val size = cameraProperties.get("size")
			val wh = size.split("x")
			imageWidth = Integer::valueOf(wh.get(0))
			imageHeight = Integer::valueOf(wh.get(1))
			
			camera = setImage(new Capture(this, selectedCamera))
			
			camera.start
		}
	}
	
	def <T extends PImage> setImage(T img) {
		resetSettings
		
		image = img
		dirty = true
		
		if (image.width > 0) imageWidth = image.width
		if (image.height > 0) imageHeight = image.height
		
		autoscale
		
		img
	}
	
	def autoscale() {
		if (imageWidth < imageHeight) {
			imageScaleFactor = (WIDTH as float) / imageWidth
			imageYOffset = ((HEIGHT - (imageHeight * imageScaleFactor)) / 2) as int
		} else {
			imageScaleFactor = (HEIGHT as float) / imageHeight
			imageXOffset = ((WIDTH - (imageWidth * imageScaleFactor)) / 2) as int
		}
	}
	
}
