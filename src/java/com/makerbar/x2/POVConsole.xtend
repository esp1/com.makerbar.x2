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

class POVConsole extends PApplet {

	static val WIDTH = 4 * 56
	static val HEIGHT = 6 * 17

	def static void main(String[] args) {
		PApplet::main("com.makerbar.x2.POVConsole")
	}
	
	//
	
	PImage image
	Movie movie
	Capture camera
	String selectedCamera
	
	PGraphics pg
	
	int imageWidth
	int imageHeight
	float scaleFactor = 1
	int xOffset
	int yOffset
	
	var boolean dirty
	
	override setup() {
		size(800, 300)
		
		frameRate(30)
		
		pg = createGraphics(WIDTH, HEIGHT)
		
		loadProperties
	}
	
	override draw() {
		// Clear
		background(100)
		
		pushMatrix
		translate(80, 80)
		drawImage
		translate(0, HEIGHT + 50)
		popMatrix
		
		displayText
		
		if (dirty) {
//			val fps = X2Client::sendData(pg)
//			println('''«fps» fps''')
//			dirty = false
		}
	}
	
	def drawImage() {
		pushMatrix
		
		// Draw image on pg
		pg.beginDraw
		pg.background(100)
		
		if (image != null) {
			pg.scale(scaleFactor)
			
			if (camera != null && camera.available) {
				camera.read
				dirty = true
			}
			
			// tile images
			var x = xOffset
			while (x >= -WIDTH / scaleFactor) {
				var y = yOffset
				while (y >= -HEIGHT / scaleFactor) {
					pg.image(image, x, y)
					y = y - imageHeight
				}
				y = yOffset + imageHeight
				while (y < HEIGHT / scaleFactor) {
					pg.image(image, x, y)
					y = y + imageHeight
				}
				
				x = x - imageWidth
			}
			x = xOffset
			while (x < WIDTH / scaleFactor) {
				var y = yOffset
				while (y >= -HEIGHT / scaleFactor) {
					pg.image(image, x, y)
					y = y - imageHeight
				}
				y = yOffset + imageHeight
				while (y < HEIGHT / scaleFactor) {
					pg.image(image, x, y)
					y = y + imageHeight
				}
				
				x = x + imageWidth
			}
		}
		
		pg.endDraw
		
		// Draw pg to screen
		image(pg, 0, 0)
		
		// Draw frame
		stroke(200)
		noFill
		rect(-1, -1, WIDTH + 2, HEIGHT + 2)
		
		popMatrix
	}
	
	def void movieEvent(Movie m) {
		m.read
		dirty = true
	}
	
	def displayText() {
		pushMatrix
		pushStyle
		
		translate(width - 400, 20)
		
		stroke(255)
		text('''
			Display dimensions: «WIDTH» x «HEIGHT»
			
			----
			
			l : re/load properties
			o : open image file
			c : capture video
			
			----
			
			«IF image != null»
				+/- : scale image
				arrow keys : image offset
				(hold shift for fine scale/offset)
			«ENDIF»
			
			«IF scaleFactor != 1»scale factor: «scaleFactor»«ENDIF»
			«IF xOffset != 0»x offset: «xOffset»«ENDIF»
			«IF yOffset != 0»y offset: «yOffset»«ENDIF»
			''', 20, 20)
		
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
				case VK_EQUALS: setScaleFactor(scaleFactor + 0.01f * factor)
				case VK_MINUS: setScaleFactor(scaleFactor - 0.01f * factor)
				case VK_LEFT: setXOffset(xOffset - 1 * factor)
				case VK_RIGHT: setXOffset(xOffset + 1 * factor)
				case VK_UP: setYOffset(yOffset - 1 * factor)
				case VK_DOWN: setYOffset(yOffset + 1 * factor)
			}
		}
	}
	
	def setScaleFactor(float scaleFactor) {
		this.scaleFactor = scaleFactor
		dirty = true
	}
	
	def setXOffset(int xOffset) {
		this.xOffset = xOffset % ((imageWidth / scaleFactor) as int)
		dirty = true
	}
	
	def setYOffset(int yOffset) {
		this.yOffset = yOffset % ((imageHeight / scaleFactor) as int)
		dirty = true
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
			if (scaleFactorProperty != null) setScaleFactor(Float::parseFloat(scaleFactorProperty))
			
			val xOffsetProperty = properties.getProperty("xOffset")
			if (xOffsetProperty != null) setXOffset(Integer::parseInt(xOffsetProperty))
			
			val yOffsetProperty = properties.getProperty("yOffset")
			if (yOffsetProperty != null) setYOffset(Integer::parseInt(yOffsetProperty))
		}
	}
	
	val imageFileFilter = new FileNameExtensionFilter("Image file (*.png, *.jpg, *.bmp)", #{ "png", "jpg", "bmp" })
	val movieFileFilter = new FileNameExtensionFilter("Movie file (*.mov)", #{ "mov" })
	val fileChooser = new JFileChooser(new File(".")) => [
		acceptAllFileFilterUsed = false
		addChoosableFileFilter = imageFileFilter
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
		if (movie != null) {
			movie.stop
			movie = null
		}
		if (camera != null) {
			camera.stop
			camera = null
		}
		image = img
		dirty = true
		
		if (image.width > 0) imageWidth = image.width
		if (image.height > 0) imageHeight = image.height
		
		autoscale
		
		img
	}
	
	def autoscale() {
		if (imageWidth < imageHeight) {
			scaleFactor = (WIDTH as float) / imageWidth
			yOffset = ((HEIGHT - (imageHeight * scaleFactor)) / 2) as int
		} else {
			scaleFactor = (HEIGHT as float) / imageHeight
			xOffset = ((WIDTH - (imageWidth * scaleFactor)) / 2) as int
		}
	}
	
}
