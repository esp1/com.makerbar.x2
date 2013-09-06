package com.makerbar.x2.display;

import processing.serial.Serial;

@SuppressWarnings("all")
public class POVDisplayController {
  private final Serial serial;
  
  private int offsetX;
  
  public POVDisplayController(final Serial povSerial) {
    this.serial = povSerial;
  }
  
  /**
   * clears everything from the globe and resets its position.
   */
  public void resetGlobe() {
    this.sendSerialCommand(0x00);
  }
  
  /**
   * set the globe X columns counterclockwise from the world origin.
   */
  public void setGlobePosition(final int x) {
    this.offsetX = x;
    this.sendSerialCommand(0x01, this.offsetX);
  }
  
  public void incrementGlobePosition(final int deltaX) {
    int _plus = (this.offsetX + deltaX);
    this.setGlobePosition(_plus);
  }
  
  /**
   * removes the reticle.
   */
  public void clearReticle() {
    this.sendSerialCommand(0x10);
  }
  
  /**
   * puts the reticle (crosshairs or indicator dot) on the given coords relative to globe origin.
   */
  public void setReticle(final int x, final int y) {
    this.sendSerialCommand(0x11, x, y);
  }
  
  /**
   * removes the target marker.
   */
  public void clearTarget(final int id) {
    this.sendSerialCommand(0x20, id);
  }
  
  /**
   * add a target marker (animal) to the given coordinates relative to the globe origin.
   */
  public void setTarget(final int id, final int x, final int y) {
    this.sendSerialCommand(0x21, id, x, y);
  }
  
  /**
   * plays the abduction animation (green dot grows to become green circle and fades out). Cancel other animations if you want.
   */
  public void playAbductionAnimation(final int x, final int y) {
    this.sendSerialCommand(0x31, x, y);
  }
  
  /**
   * play the scanner animation (blue circle expands from point, or big blue circle flashes momentarily). Cancel other animations if you want.
   */
  public void playScannerAnimation(final int x, final int y) {
    this.sendSerialCommand(0x32, x, y);
  }
  
  private void sendSerialCommand(final int opCode, final int... params) {
    this.serial.write(0xFF);
    this.serial.write(opCode);
    for (final int param : params) {
      this.serial.write(param);
    }
  }
}
