package com.makerbar.x2.display

import processing.core.PImage

import static extension com.makerbar.x2.display.BitFiddler.*
import com.makerbar.x2.display.config.POVConfig

/**
 * Process images for use with PJRC's OctoWS2811 library: http://www.pjrc.com/teensy/td_libs_OctoWS2811.html
 */
class POVImageEncoder {

	/**
	 * Takes in a bitmap image and transforms it into a set of int arrays encoded for the OctoWS2811 library.
	 * The output is a multidimensional int array where the outer array corresponds to the set of Teensys, and
	 * the inner 2-d int arrays correspond to the OctoWS2811-encoded image data for each Teensy.
	 */
	def byte[][] processImage(PImage bitmap) {
		val bytes = new3DByteArrayOfSize(povDisplay.teensys.size, POVConfig::sectorWidth * POVConfig::sectorHeight * 24)
		
		// Bitmap slice
		var sectorRowOffset = 0
		for (teensyId : 0 ..< povDisplay.teensys.size) {
			val teensy = povDisplay.teensys.get(teensyId)
			
			// Frame slice pixel data for all sector columns is interleaved together in OctoWS2811's data format
			for (bitmapSliceIndex : 0 ..< POVConfig::sectorWidth) {
				val octoBytes = newByteArrayOfSize(POVConfig::sectorHeight * 24)  // 24 bytes per pixel - 24 bit color value is spread across 24 bytes
				
				for (sectorPixelIndex : 0 ..< POVConfig::sectorHeight) {
					val stripColors = newIntArrayOfSize(8)
					
					// Sector rows
					for (sectorRowIndex : 0 ..< teensy.sectorRows.size) {
						val bitmapY = ((sectorRowOffset + sectorRowIndex) * POVConfig::sectorHeight) + sectorPixelIndex
						
						// Sector columns
						for (sectorColumnIndex : 0 ..< POVConfig::numSectorColumns) {  // The display should not have more than 8 sector columns!
							val bitmapX = sectorColumnIndex * POVConfig::sectorWidth + bitmapSliceIndex
							
							// Pixel
							val bitmapRGB = bitmap.get(bitmapX, bitmapY).toGRB
							stripColors.set(sectorRowIndex * POVConfig::numSectorColumns + sectorColumnIndex, bitmapRGB)
						}
					}
					
					octoBytes.setOctoWS2811Bytes(sectorPixelIndex, stripColors)
				}
				
				// Write OctoWS2811 pixel data for slice
				for (i : 0 ..< octoBytes.size)
					bytes.set(teensyId, (bitmapSliceIndex * POVConfig::sectorWidth) + i, octoBytes.get(i))
			}
			
			sectorRowOffset = sectorRowOffset + teensy.sectorRows.size
		}
		
		bytes
	}
	
	def toBitmapH(byte[][] bytes) {
		'''
		«FOR teensyId : 0 ..< bytes.length SEPARATOR "\n\n\n\n\n"»
			«val imageData = bytes.get(teensyId)»
			#ifndef Bitmap_h_
			#define Bitmap_h_
			
			// Teensy ID. Master has ID 0, other IDs are slaves.
			#define TEENSY_ID «teensyId»
			
			// Bitmap
			
			PROGMEM const unsigned int BITMAP[«POVConfig::sectorWidth»][«POVConfig::sectorHeight * 6»] = {
				«FOR bitmapSliceIndex : 0 ..< POVConfig::sectorWidth SEPARATOR ","»
					/* Bitmap slice «String::format("%2d", bitmapSliceIndex)» */ { «
					FOR i : 0 ..< (POVConfig::sectorHeight * 6) SEPARATOR ", "
						»/* «i» */ 0x«
						FOR b : 0 ..< 4
							»«String::format("%02x", imageData.get((bitmapSliceIndex * POVConfig::sectorWidth) + (i * 4) + b))
						»«ENDFOR
					»«ENDFOR» }
				«ENDFOR»
			};
			
			#endif
		«ENDFOR»
		'''
	}
	
}
