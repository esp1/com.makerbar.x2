package com.makerbar.x2.display;

import com.makerbar.x2.display.config.POVConfig;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import processing.core.PImage;

/**
 * Process images for use with PJRC's OctoWS2811 library: http://www.pjrc.com/teensy/td_libs_OctoWS2811.html
 */
@SuppressWarnings("all")
public class POVImageEncoder {
  /**
   * Takes in a bitmap image and transforms it into a set of int arrays encoded for the OctoWS2811 library.
   * The output is a multidimensional int array where the outer array corresponds to the set of Teensys, and
   * the inner 2-d int arrays correspond to the OctoWS2811-encoded image data for each Teensy.
   */
  public byte[][] processImage(final PImage bitmap) {
    throw new Error("Unresolved compilation problems:"
      + "\nThe method or field povDisplay is undefined for the type POVImageEncoder"
      + "\nThe method or field povDisplay is undefined for the type POVImageEncoder"
      + "\nThe method or field povDisplay is undefined for the type POVImageEncoder"
      + "\nteensys cannot be resolved"
      + "\nsize cannot be resolved"
      + "\nteensys cannot be resolved"
      + "\nsize cannot be resolved"
      + "\nteensys cannot be resolved"
      + "\nget cannot be resolved"
      + "\nsectorRows cannot be resolved"
      + "\nsize cannot be resolved"
      + "\nsectorRows cannot be resolved"
      + "\nsize cannot be resolved");
  }
  
  public CharSequence toBitmapH(final byte[][] bytes) {
    StringConcatenation _builder = new StringConcatenation();
    {
      int _length = bytes.length;
      ExclusiveRange _doubleDotLessThan = new ExclusiveRange(0, _length, true);
      boolean _hasElements = false;
      for(final Integer teensyId : _doubleDotLessThan) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate("\n\n\n\n\n", "");
        }
        final byte[] imageData = bytes[(teensyId).intValue()];
        _builder.newLineIfNotEmpty();
        _builder.append("#ifndef Bitmap_h_");
        _builder.newLine();
        _builder.append("#define Bitmap_h_");
        _builder.newLine();
        _builder.newLine();
        _builder.append("// Teensy ID. Master has ID 0, other IDs are slaves.");
        _builder.newLine();
        _builder.append("#define TEENSY_ID ");
        _builder.append(teensyId, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("// Bitmap");
        _builder.newLine();
        _builder.newLine();
        _builder.append("PROGMEM const unsigned int BITMAP[");
        _builder.append(POVConfig.sectorWidth, "");
        _builder.append("][");
        int _multiply = (POVConfig.sectorHeight * 6);
        _builder.append(_multiply, "");
        _builder.append("] = {");
        _builder.newLineIfNotEmpty();
        {
          ExclusiveRange _doubleDotLessThan_1 = new ExclusiveRange(0, POVConfig.sectorWidth, true);
          boolean _hasElements_1 = false;
          for(final Integer bitmapSliceIndex : _doubleDotLessThan_1) {
            if (!_hasElements_1) {
              _hasElements_1 = true;
            } else {
              _builder.appendImmediate(",", "	");
            }
            _builder.append("\t");
            _builder.append("/* Bitmap slice ");
            String _format = String.format("%2d", bitmapSliceIndex);
            _builder.append(_format, "	");
            _builder.append(" */ { ");
            {
              int _multiply_1 = (POVConfig.sectorHeight * 6);
              ExclusiveRange _doubleDotLessThan_2 = new ExclusiveRange(0, _multiply_1, true);
              boolean _hasElements_2 = false;
              for(final Integer i : _doubleDotLessThan_2) {
                if (!_hasElements_2) {
                  _hasElements_2 = true;
                } else {
                  _builder.appendImmediate(", ", "	");
                }
                _builder.append("/* ");
                _builder.append(i, "	");
                _builder.append(" */ 0x");
                {
                  ExclusiveRange _doubleDotLessThan_3 = new ExclusiveRange(0, 4, true);
                  for(final Integer b : _doubleDotLessThan_3) {
                    int _multiply_2 = ((bitmapSliceIndex).intValue() * POVConfig.sectorWidth);
                    int _multiply_3 = ((i).intValue() * 4);
                    int _plus = (_multiply_2 + _multiply_3);
                    int _plus_1 = (_plus + (b).intValue());
                    byte _get = imageData[_plus_1];
                    String _format_1 = String.format("%02x", Byte.valueOf(_get));
                    _builder.append(_format_1, "	");
                  }
                }
              }
            }
            _builder.append(" }");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("};");
        _builder.newLine();
        _builder.newLine();
        _builder.append("#endif");
        _builder.newLine();
      }
    }
    return _builder;
  }
}
