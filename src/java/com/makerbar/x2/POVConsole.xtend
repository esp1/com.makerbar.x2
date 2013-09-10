package com.makerbar.x2

import com.makerbar.x2.display.config.POVConfig
import com.makerbar.x2.display.config.SectorRowOrientation
import java.awt.event.KeyEvent
import java.io.File
import java.io.FileReader
import java.util.Properties
import javax.swing.JFileChooser
import javax.swing.JOptionPane
import javax.swing.filechooser.FileNameExtensionFilter
import processing.core.PApplet
import processing.core.PGraphics
import processing.core.PImage
import processing.video.Capture
import processing.video.Movie

import static com.makerbar.x2.display.config.SectorRowOrientation.*
import static java.awt.event.KeyEvent.*
import static javax.swing.JFileChooser.*

class POVConsole extends PApplet {

	def static void main(String[] args) {
		PApplet::main("com.makerbar.x2.POVConsole")
	}
	
	//
	
	PImage image
	Movie movie
	Capture camera
	
	PGraphics pg
	PImage ximg
	
	float scaleFactor = 1
	int xOffset
	int yOffset
	
	var boolean dirty
	
	override setup() {
		size(800, 600)
		
		pg = createGraphics(POVConfig::width, POVConfig::height)
		ximg = createImage(POVConfig::width, POVConfig::height, ARGB)
		
		loadProperties
	}
	
	override draw() {
		// Clear
		background(100)
		
		pushMatrix
		translate(40, 40)
		drawImage
		translate(0, POVConfig::height + 50)
		drawTransformedImage
		popMatrix
		
		displayText
	}
	
	def drawImage() {
		pushMatrix
		
		// Draw image on pg
		pg.beginDraw
		pg.background(100)
		pg.translate(xOffset, yOffset)
		pg.scale(scaleFactor)
		
		if (image != null) {
			if (camera != null && camera.available) {
				camera.read
				dirty = true
			}
			pg.image(image, 0, 0)
		}
		
		pg.endDraw
		
		// Draw pg to screen
		image(pg, 0, 0)
		
		// Draw frame
		stroke(200)
		noFill
		rect(-1, -1, POVConfig::width + 2, POVConfig::height + 2)
		
		popMatrix
	}
	
	def void movieEvent(Movie m) {
		m.read
		dirty = true
	}
	
	def drawTransformedImage() {
		pushMatrix
		pushStyle
		
		ximg.loadPixels
		for (sectorRowIndex : 0 ..< POVConfig::sectorRows.size) {
			val sectorRow = POVConfig::sectorRows.get(sectorRowIndex)
			for (y : 0 ..< POVConfig::sectorHeight) {
				for (x : 0 ..< POVConfig::width) {
					val originalY = (sectorRowIndex * POVConfig::sectorHeight) + y
					val transformedY = switch (sectorRow) {
						case TOP_DOWN: originalY
						case BOTTOM_UP: ((sectorRowIndex + 1) * POVConfig::sectorHeight) - 1 - y
					}
					ximg.set(x, originalY, pg.get(x, transformedY))
				}
			}
		}
		ximg.updatePixels
		
		image(ximg, 0, 0)
		
		popStyle
		popMatrix
		
		drawPOVConfig
		
		if (dirty) {
			println('''«X2Client::sendData(ximg)» fps''')
			dirty = false
		}
	}
	
	def drawPOVConfig() {
		pushMatrix
		pushStyle
		noFill

		for (sectorRow : POVConfig::sectorRows) {
			// Sectors
			pushMatrix
			pushStyle
			stroke(0, 50)  // Black
			for (i : 0 ..< POVConfig::numSectorColumns) {
				// Draw sector
				rect(0, 0, POVConfig::sectorWidth, POVConfig::sectorHeight)
				translate(POVConfig::sectorWidth, 0)
			}
			popStyle
			popMatrix
			
			// Draw sector row
			stroke(0, 0, 200, 50)  // Blue
			rect(1, 1, POVConfig::width - 2, POVConfig::sectorHeight - 2)
			
			sectorRow.drawOrientationIndicator
			
			translate(0, POVConfig::sectorHeight)
		}
		
		popStyle
		popMatrix
	}
	
	def drawOrientationIndicator(SectorRowOrientation sectorRow) {
		pushMatrix
		pushStyle
		
		translate(-10, POVConfig::sectorHeight / 2f)
		
		stroke(0)
		fill(0)
		line(0, -POVConfig::sectorHeight / 4f, 0, POVConfig::sectorHeight / 4f)
		
		if (sectorRow == BOTTOM_UP)
			rotate(PI)
		
		triangle(-2, 0, 2, 0, 0, 4)
		
		popStyle
		popMatrix
	}
	
	def displayText() {
		pushMatrix
		pushStyle
		
		translate(width - 400, 20)
		
		stroke(255)
		text('''
			Display dimensions: «POVConfig::width» x «POVConfig::height»
			
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
		this.xOffset = xOffset
		dirty = true
	}
	
	def setYOffset(int yOffset) {
		this.yOffset = yOffset
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
	val fileChooser = new JFileChooser => [
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
		cursor(WAIT)
		val cameras = Capture::list
		cursor(ARROW)
		val selectedCamera = JOptionPane::showInputDialog(this, "", "Select camera", JOptionPane::PLAIN_MESSAGE, null, cameras, null) as String
		if (selectedCamera != null) {
			println('''Opening camera «selectedCamera»''')
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
		img
	}
	
}
