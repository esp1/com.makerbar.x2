package com.makerbar.x2.display

import processing.serial.Serial

class POVDisplayController {
	
	val Serial serial
	
	int offsetX
	
	new(Serial povSerial) {
		this.serial = povSerial
	}
	
	// Globe
	
	/**
	 * clears everything from the globe and resets its position.
	 */
	def resetGlobe() {
		sendSerialCommand(0x00)
	}
	
	/**
	 * set the globe X columns counterclockwise from the world origin.
	 */
	def setGlobePosition(int x) {
		offsetX = x
		sendSerialCommand(0x01, offsetX)
	}
	
	def incrementGlobePosition(int deltaX) {
		globePosition = offsetX + deltaX
	}
	
	// Reticle
	
	/**
	 * removes the reticle.
	 */
	def clearReticle() {
		sendSerialCommand(0x10)
	}
	
	/**
	 * puts the reticle (crosshairs or indicator dot) on the given coords relative to globe origin.
	 */
	def setReticle(int x, int y) {
		sendSerialCommand(0x11, x, y)
	}
	
	// Targets
	// There can be a maximum of 20 targets. Target IDs are integers between 0 and 19.
	
	/**
	 * removes the target marker.
	 */
	def clearTarget(int id) {
		sendSerialCommand(0x20, id)
	}
	
	/**
	 * add a target marker (animal) to the given coordinates relative to the globe origin.
	 */
	def setTarget(int id, int x, int y) {
		sendSerialCommand(0x21, id, x, y)
	}
	
	// Animations
	
	/**
	 * plays the abduction animation (green dot grows to become green circle and fades out). Cancel other animations if you want.
	 */
	def playAbductionAnimation(int x, int y) {
		sendSerialCommand(0x31, x, y)
	}
	
	/**
	 * play the scanner animation (blue circle expands from point, or big blue circle flashes momentarily). Cancel other animations if you want.
	 */
	def playScannerAnimation(int x, int y) {
		sendSerialCommand(0x32, x, y)
	}
	
	private def sendSerialCommand(int opCode, int...params) {
		serial.write(0xFF)
		serial.write(opCode)
		for (param : params)
			serial.write(param)
	}
	
}
