package com.makerbar.x2;

import com.google.common.base.Objects;
import com.google.common.collect.Sets;
import com.makerbar.x2.display.POVImageEncoder;
import com.makerbar.x2.display.config.POVConfig;
import com.makerbar.x2.display.config.SectorRowOrientation;
import java.awt.event.KeyEvent;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Properties;
import java.util.Set;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import javax.swing.filechooser.FileFilter;
import javax.swing.filechooser.FileNameExtensionFilter;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PGraphics;
import processing.core.PImage;
import processing.serial.Serial;
import processing.video.Capture;
import processing.video.Movie;

@SuppressWarnings("all")
public class POVConsole extends PApplet {
  public static void main(final String[] args) {
    PApplet.main("com.makerbar.x2.POVConsole");
  }
  
  private PImage image;
  
  private Movie movie;
  
  private Capture camera;
  
  private PGraphics pg;
  
  private PImage ximg;
  
  private final HashMap<Integer,Serial> teensyIdToSerialMap = new Function0<HashMap<Integer,Serial>>() {
    public HashMap<Integer,Serial> apply() {
      HashMap<Integer,Serial> _hashMap = new HashMap<Integer, Serial>();
      return _hashMap;
    }
  }.apply();
  
  private POVImageEncoder imageEncoder;
  
  private float scaleFactor = 1;
  
  private int xOffset;
  
  private int yOffset;
  
  private boolean dirty;
  
  public void setup() {
    this.size(800, 600);
    PGraphics _createGraphics = this.createGraphics(POVConfig.width, POVConfig.height);
    this.pg = _createGraphics;
    PImage _createImage = this.createImage(POVConfig.width, POVConfig.height, PConstants.ARGB);
    this.ximg = _createImage;
    this.loadProperties();
  }
  
  public void draw() {
    this.background(100);
    this.pushMatrix();
    this.translate(40, 40);
    this.drawImage();
    int _plus = (POVConfig.height + 50);
    this.translate(0, _plus);
    this.drawTransformedImage();
    this.popMatrix();
    this.displayText();
  }
  
  public void drawImage() {
    this.pushMatrix();
    this.pg.beginDraw();
    this.pg.background(100);
    this.pg.translate(this.xOffset, this.yOffset);
    this.pg.scale(this.scaleFactor);
    boolean _notEquals = (!Objects.equal(this.image, null));
    if (_notEquals) {
      boolean _and = false;
      boolean _notEquals_1 = (!Objects.equal(this.camera, null));
      if (!_notEquals_1) {
        _and = false;
      } else {
        boolean _available = this.camera.available();
        _and = (_notEquals_1 && _available);
      }
      if (_and) {
        this.camera.read();
        this.dirty = true;
      }
      this.pg.image(this.image, 0, 0);
    }
    this.pg.endDraw();
    this.image(this.pg, 0, 0);
    this.stroke(200);
    this.noFill();
    int _minus = (-1);
    int _minus_1 = (-1);
    int _plus = (POVConfig.width + 2);
    int _plus_1 = (POVConfig.height + 2);
    this.rect(_minus, _minus_1, _plus, _plus_1);
    this.popMatrix();
  }
  
  public void movieEvent(final Movie m) {
    m.read();
    this.dirty = true;
  }
  
  public Boolean drawTransformedImage() {
    Boolean _xblockexpression = null;
    {
      this.pushMatrix();
      this.pushStyle();
      this.ximg.loadPixels();
      int _size = POVConfig.sectorRows.size();
      ExclusiveRange _doubleDotLessThan = new ExclusiveRange(0, _size, true);
      for (final Integer sectorRowIndex : _doubleDotLessThan) {
        {
          final SectorRowOrientation sectorRow = POVConfig.sectorRows.get((sectorRowIndex).intValue());
          ExclusiveRange _doubleDotLessThan_1 = new ExclusiveRange(0, POVConfig.sectorHeight, true);
          for (final Integer y : _doubleDotLessThan_1) {
            ExclusiveRange _doubleDotLessThan_2 = new ExclusiveRange(0, POVConfig.width, true);
            for (final Integer x : _doubleDotLessThan_2) {
              {
                int _multiply = ((sectorRowIndex).intValue() * POVConfig.sectorHeight);
                final int originalY = (_multiply + (y).intValue());
                Integer _switchResult = null;
                boolean _matched = false;
                if (!_matched) {
                  if (Objects.equal(sectorRow,SectorRowOrientation.TOP_DOWN)) {
                    _matched=true;
                    _switchResult = Integer.valueOf(originalY);
                  }
                }
                if (!_matched) {
                  if (Objects.equal(sectorRow,SectorRowOrientation.BOTTOM_UP)) {
                    _matched=true;
                    int _plus = ((sectorRowIndex).intValue() + 1);
                    int _multiply_1 = (_plus * POVConfig.sectorHeight);
                    int _minus = (_multiply_1 - 1);
                    int _minus_1 = (_minus - (y).intValue());
                    _switchResult = Integer.valueOf(_minus_1);
                  }
                }
                final Integer transformedY = _switchResult;
                int _get = this.pg.get((x).intValue(), (transformedY).intValue());
                this.ximg.set((x).intValue(), originalY, _get);
              }
            }
          }
        }
      }
      this.ximg.updatePixels();
      this.image(this.ximg, 0, 0);
      this.popStyle();
      this.popMatrix();
      this.drawPOVConfig();
      Boolean _xifexpression = null;
      if (this.dirty) {
        boolean _xblockexpression_1 = false;
        {
          Set<Integer> _keySet = this.teensyIdToSerialMap.keySet();
          for (final Integer teensyId : _keySet) {
            {
              final byte[][] bytes = this.imageEncoder.processImage(this.ximg);
              final Serial serial = this.teensyIdToSerialMap.get(teensyId);
              boolean _notEquals = (!Objects.equal(serial, null));
              if (_notEquals) {
                final byte[] imageData = bytes[(teensyId).intValue()];
                StringConcatenation _builder = new StringConcatenation();
                _builder.append("Sending ��imageData.length�� bytes to teensy ��teensyId��");
                PApplet.println(_builder);
                serial.write(imageData);
              }
            }
          }
          boolean _dirty = this.dirty = false;
          _xblockexpression_1 = (_dirty);
        }
        _xifexpression = Boolean.valueOf(_xblockexpression_1);
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  public void drawPOVConfig() {
    this.pushMatrix();
    this.pushStyle();
    this.noFill();
    for (final SectorRowOrientation sectorRow : POVConfig.sectorRows) {
      {
        this.pushMatrix();
        this.pushStyle();
        this.stroke(0, 50);
        ExclusiveRange _doubleDotLessThan = new ExclusiveRange(0, POVConfig.numSectorColumns, true);
        for (final Integer i : _doubleDotLessThan) {
          {
            this.rect(0, 0, POVConfig.sectorWidth, POVConfig.sectorHeight);
            this.translate(POVConfig.sectorWidth, 0);
          }
        }
        this.popStyle();
        this.popMatrix();
        this.stroke(0, 0, 200, 50);
        int _minus = (POVConfig.width - 2);
        int _minus_1 = (POVConfig.sectorHeight - 2);
        this.rect(1, 1, _minus, _minus_1);
        this.drawOrientationIndicator(sectorRow);
        this.translate(0, POVConfig.sectorHeight);
      }
    }
    this.popStyle();
    this.popMatrix();
  }
  
  public void drawOrientationIndicator(final SectorRowOrientation sectorRow) {
    this.pushMatrix();
    this.pushStyle();
    int _minus = (-10);
    float _divide = (POVConfig.sectorHeight / 2f);
    this.translate(_minus, _divide);
    this.stroke(0);
    this.fill(0);
    int _minus_1 = (-POVConfig.sectorHeight);
    float _divide_1 = (_minus_1 / 4f);
    float _divide_2 = (POVConfig.sectorHeight / 4f);
    this.line(0, _divide_1, 0, _divide_2);
    boolean _equals = Objects.equal(sectorRow, SectorRowOrientation.BOTTOM_UP);
    if (_equals) {
      this.rotate(PConstants.PI);
    }
    int _minus_2 = (-2);
    this.triangle(_minus_2, 0, 2, 0, 0, 4);
    this.popStyle();
    this.popMatrix();
  }
  
  public void displayText() {
    this.pushMatrix();
    this.pushStyle();
    int _minus = (this.width - 400);
    this.translate(_minus, 20);
    this.stroke(255);
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Display dimensions: ��POVConfig::width�� x ��POVConfig::height��");
    _builder.newLine();
    _builder.newLine();
    _builder.append("----");
    _builder.newLine();
    _builder.newLine();
    _builder.append("l : re/load properties");
    _builder.newLine();
    _builder.append("o : open image file");
    _builder.newLine();
    _builder.append("c : capture video");
    _builder.newLine();
    _builder.newLine();
    _builder.append("----");
    _builder.newLine();
    _builder.newLine();
    _builder.append("��IF image != null��");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("+/- : scale image");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("arrow keys : image offset");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("(hold shift for fine scale/offset)");
    _builder.newLine();
    _builder.append("��ENDIF��");
    _builder.newLine();
    _builder.newLine();
    _builder.append("��IF scaleFactor != 1��scale factor: ��scaleFactor����ENDIF��");
    _builder.newLine();
    _builder.append("��IF xOffset != 0��x offset: ��xOffset����ENDIF��");
    _builder.newLine();
    _builder.append("��IF yOffset != 0��y offset: ��yOffset����ENDIF��");
    _builder.newLine();
    this.text(_builder.toString(), 20, 20);
    this.popStyle();
    this.popMatrix();
  }
  
  public void keyPressed(final KeyEvent event) {
    boolean _equals = Objects.equal(this.image, null);
    if (_equals) {
      int _keyCode = event.getKeyCode();
      final int _switchValue = _keyCode;
      boolean _matched = false;
      if (!_matched) {
        if (Objects.equal(_switchValue,KeyEvent.VK_O)) {
          _matched=true;
          this.openImageFile();
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,KeyEvent.VK_C)) {
          _matched=true;
          this.captureVideo();
        }
      }
    } else {
      int _xifexpression = (int) 0;
      boolean _isShiftDown = event.isShiftDown();
      if (_isShiftDown) {
        _xifexpression = 1;
      } else {
        _xifexpression = 10;
      }
      final int factor = _xifexpression;
      int _keyCode_1 = event.getKeyCode();
      final int _switchValue_1 = _keyCode_1;
      boolean _matched_1 = false;
      if (!_matched_1) {
        if (Objects.equal(_switchValue_1,KeyEvent.VK_L)) {
          _matched_1=true;
          this.loadProperties();
        }
      }
      if (!_matched_1) {
        if (Objects.equal(_switchValue_1,KeyEvent.VK_O)) {
          _matched_1=true;
          this.openImageFile();
        }
      }
      if (!_matched_1) {
        if (Objects.equal(_switchValue_1,KeyEvent.VK_C)) {
          _matched_1=true;
          this.captureVideo();
        }
      }
      if (!_matched_1) {
        if (Objects.equal(_switchValue_1,KeyEvent.VK_EQUALS)) {
          _matched_1=true;
          float _multiply = (0.01f * factor);
          float _plus = (this.scaleFactor + _multiply);
          this.setScaleFactor(_plus);
        }
      }
      if (!_matched_1) {
        if (Objects.equal(_switchValue_1,KeyEvent.VK_MINUS)) {
          _matched_1=true;
          float _multiply_1 = (0.01f * factor);
          float _minus = (this.scaleFactor - _multiply_1);
          this.setScaleFactor(_minus);
        }
      }
      if (!_matched_1) {
        if (Objects.equal(_switchValue_1,KeyEvent.VK_LEFT)) {
          _matched_1=true;
          int _multiply_2 = (1 * factor);
          int _minus_1 = (this.xOffset - _multiply_2);
          this.setXOffset(_minus_1);
        }
      }
      if (!_matched_1) {
        if (Objects.equal(_switchValue_1,KeyEvent.VK_RIGHT)) {
          _matched_1=true;
          int _multiply_3 = (1 * factor);
          int _plus_1 = (this.xOffset + _multiply_3);
          this.setXOffset(_plus_1);
        }
      }
      if (!_matched_1) {
        if (Objects.equal(_switchValue_1,KeyEvent.VK_UP)) {
          _matched_1=true;
          int _multiply_4 = (1 * factor);
          int _minus_2 = (this.yOffset - _multiply_4);
          this.setYOffset(_minus_2);
        }
      }
      if (!_matched_1) {
        if (Objects.equal(_switchValue_1,KeyEvent.VK_DOWN)) {
          _matched_1=true;
          int _multiply_5 = (1 * factor);
          int _plus_2 = (this.yOffset + _multiply_5);
          this.setYOffset(_plus_2);
        }
      }
      if (!_matched_1) {
        if (Objects.equal(_switchValue_1,KeyEvent.VK_E)) {
          _matched_1=true;
          final byte[][] ints = this.imageEncoder.processImage(this.ximg);
          CharSequence _bitmapH = this.imageEncoder.toBitmapH(ints);
          PApplet.println(_bitmapH);
        }
      }
    }
  }
  
  public boolean setScaleFactor(final float scaleFactor) {
    boolean _xblockexpression = false;
    {
      this.scaleFactor = scaleFactor;
      boolean _dirty = this.dirty = true;
      _xblockexpression = (_dirty);
    }
    return _xblockexpression;
  }
  
  public boolean setXOffset(final int xOffset) {
    boolean _xblockexpression = false;
    {
      this.xOffset = xOffset;
      boolean _dirty = this.dirty = true;
      _xblockexpression = (_dirty);
    }
    return _xblockexpression;
  }
  
  public boolean setYOffset(final int yOffset) {
    boolean _xblockexpression = false;
    {
      this.yOffset = yOffset;
      boolean _dirty = this.dirty = true;
      _xblockexpression = (_dirty);
    }
    return _xblockexpression;
  }
  
  public Boolean loadProperties() {
    try {
      Boolean _xblockexpression = null;
      {
        Properties _properties = new Properties();
        final Properties properties = _properties;
        File _file = new File("pov-console.properties");
        final File file = _file;
        Boolean _xifexpression = null;
        boolean _exists = file.exists();
        if (_exists) {
          Boolean _xblockexpression_1 = null;
          {
            FileReader _fileReader = new FileReader(file);
            final FileReader reader = _fileReader;
            properties.load(reader);
            reader.close();
            final String imageFileProperty = properties.getProperty("imageFile");
            boolean _notEquals = (!Objects.equal(imageFileProperty, null));
            if (_notEquals) {
              PImage _loadImage = this.loadImage(imageFileProperty);
              this.<PImage>setImage(_loadImage);
            }
            final String movieFileProperty = properties.getProperty("movieFile");
            boolean _notEquals_1 = (!Objects.equal(movieFileProperty, null));
            if (_notEquals_1) {
              Movie _movie = new Movie(this, movieFileProperty);
              Movie _setImage = this.<Movie>setImage(_movie);
              Movie _movie_1 = this.movie = _setImage;
              _movie_1.loop();
            }
            final String scaleFactorProperty = properties.getProperty("scaleFactor");
            boolean _notEquals_2 = (!Objects.equal(scaleFactorProperty, null));
            if (_notEquals_2) {
              float _parseFloat = Float.parseFloat(scaleFactorProperty);
              this.setScaleFactor(_parseFloat);
            }
            final String xOffsetProperty = properties.getProperty("xOffset");
            boolean _notEquals_3 = (!Objects.equal(xOffsetProperty, null));
            if (_notEquals_3) {
              int _parseInt = Integer.parseInt(xOffsetProperty);
              this.setXOffset(_parseInt);
            }
            final String yOffsetProperty = properties.getProperty("yOffset");
            Boolean _xifexpression_1 = null;
            boolean _notEquals_4 = (!Objects.equal(yOffsetProperty, null));
            if (_notEquals_4) {
              int _parseInt_1 = Integer.parseInt(yOffsetProperty);
              boolean _setYOffset = this.setYOffset(_parseInt_1);
              _xifexpression_1 = Boolean.valueOf(_setYOffset);
            }
            _xblockexpression_1 = (_xifexpression_1);
          }
          _xifexpression = _xblockexpression_1;
        }
        _xblockexpression = (_xifexpression);
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  private final FileNameExtensionFilter imageFileFilter = new Function0<FileNameExtensionFilter>() {
    public FileNameExtensionFilter apply() {
      FileNameExtensionFilter _fileNameExtensionFilter = new FileNameExtensionFilter("Image file (*.png, *.jpg, *.bmp)", ((String[])Conversions.unwrapArray(Collections.<String>unmodifiableSet(Sets.<String>newHashSet("png", "jpg", "bmp")), String.class)));
      return _fileNameExtensionFilter;
    }
  }.apply();
  
  private final FileNameExtensionFilter movieFileFilter = new Function0<FileNameExtensionFilter>() {
    public FileNameExtensionFilter apply() {
      FileNameExtensionFilter _fileNameExtensionFilter = new FileNameExtensionFilter("Movie file (*.mov)", ((String[])Conversions.unwrapArray(Collections.<String>unmodifiableSet(Sets.<String>newHashSet("mov")), String.class)));
      return _fileNameExtensionFilter;
    }
  }.apply();
  
  private final JFileChooser fileChooser = new Function0<JFileChooser>() {
    public JFileChooser apply() {
      JFileChooser _jFileChooser = new JFileChooser();
      final Procedure1<JFileChooser> _function = new Procedure1<JFileChooser>() {
        public void apply(final JFileChooser it) {
          it.setAcceptAllFileFilterUsed(false);
          it.addChoosableFileFilter(POVConsole.this.imageFileFilter);
          it.addChoosableFileFilter(POVConsole.this.movieFileFilter);
          it.setFileFilter(POVConsole.this.imageFileFilter);
        }
      };
      JFileChooser _doubleArrow = ObjectExtensions.<JFileChooser>operator_doubleArrow(_jFileChooser, _function);
      return _doubleArrow;
    }
  }.apply();
  
  public void openImageFile() {
    try {
      int _showOpenDialog = this.fileChooser.showOpenDialog(this);
      boolean _equals = (_showOpenDialog == JFileChooser.APPROVE_OPTION);
      if (_equals) {
        final File selectedFile = this.fileChooser.getSelectedFile();
        FileFilter _fileFilter = this.fileChooser.getFileFilter();
        final FileFilter _switchValue = _fileFilter;
        boolean _matched = false;
        if (!_matched) {
          if (Objects.equal(_switchValue,this.imageFileFilter)) {
            _matched=true;
            StringConcatenation _builder = new StringConcatenation();
            _builder.append("Image file: ��selectedFile.canonicalPath��");
            PApplet.println(_builder);
            String _canonicalPath = selectedFile.getCanonicalPath();
            PImage _loadImage = this.loadImage(_canonicalPath);
            this.<PImage>setImage(_loadImage);
          }
        }
        if (!_matched) {
          if (Objects.equal(_switchValue,this.movieFileFilter)) {
            _matched=true;
            StringConcatenation _builder_1 = new StringConcatenation();
            _builder_1.append("Movie file: ��selectedFile.canonicalPath��");
            PApplet.println(_builder_1);
            String _canonicalPath_1 = selectedFile.getCanonicalPath();
            Movie _movie = new Movie(this, _canonicalPath_1);
            Movie _setImage = this.<Movie>setImage(_movie);
            this.movie = _setImage;
            this.movie.loop();
          }
        }
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public void captureVideo() {
    this.cursor(PConstants.WAIT);
    final String[] cameras = Capture.list();
    this.cursor(PConstants.ARROW);
    Object _showInputDialog = JOptionPane.showInputDialog(this, "", "Select camera", JOptionPane.PLAIN_MESSAGE, null, cameras, null);
    final String selectedCamera = ((String) _showInputDialog);
    boolean _notEquals = (!Objects.equal(selectedCamera, null));
    if (_notEquals) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("Opening camera ��selectedCamera��");
      PApplet.println(_builder);
      Capture _capture = new Capture(this, selectedCamera);
      Capture _setImage = this.<Capture>setImage(_capture);
      this.camera = _setImage;
      this.camera.start();
    }
  }
  
  public <T extends PImage> T setImage(final T img) {
    T _xblockexpression = null;
    {
      boolean _notEquals = (!Objects.equal(this.movie, null));
      if (_notEquals) {
        this.movie.stop();
        this.movie = null;
      }
      boolean _notEquals_1 = (!Objects.equal(this.camera, null));
      if (_notEquals_1) {
        this.camera.stop();
        this.camera = null;
      }
      this.image = img;
      this.dirty = true;
      _xblockexpression = (img);
    }
    return _xblockexpression;
  }
  
  public void configureTeensySerialPorts() {
    try {
      this.cursor(PConstants.WAIT);
      PApplet.println("Discovering Teensy serial ports");
      String[] _list = Serial.list();
      ArrayList<String> _newArrayList = CollectionLiterals.<String>newArrayList(_list);
      final Function1<String,Boolean> _function = new Function1<String,Boolean>() {
        public Boolean apply(final String p) {
          boolean _startsWith = p.startsWith("/dev/tty.usbmodem");
          return Boolean.valueOf(_startsWith);
        }
      };
      final Iterable<String> ports = IterableExtensions.<String>filter(_newArrayList, _function);
      for (final String port : ports) {
        {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("Checking port ��port��...");
          PApplet.print(_builder);
          Serial _serial = new Serial(this, port);
          final Serial serial = _serial;
          char command = '?';
          serial.write(command);
          boolean responseReceived = false;
          int i = 0;
          boolean _and = false;
          boolean _not = (!responseReceived);
          if (!_not) {
            _and = false;
          } else {
            boolean _lessThan = (i < 20);
            _and = (_not && _lessThan);
          }
          boolean _while = _and;
          while (_while) {
            {
              PApplet.print(".");
              Thread.sleep(500);
              int _available = serial.available();
              boolean _greaterThan = (_available > 0);
              boolean _while_1 = _greaterThan;
              while (_while_1) {
                {
                  byte[] _readBytes = serial.readBytes();
                  byte _get = _readBytes[0];
                  final Integer teensyId = Integer.valueOf(_get);
                  StringConcatenation _builder_1 = new StringConcatenation();
                  _builder_1.append("Found Teensy ��teensyId�� on port ��port��");
                  PApplet.println(_builder_1);
                  responseReceived = true;
                  boolean _containsKey = this.teensyIdToSerialMap.containsKey(teensyId);
                  if (_containsKey) {
                    StringConcatenation _builder_2 = new StringConcatenation();
                    _builder_2.append("Warning! Duplicate Teensy ID: ��teensyId��");
                    PApplet.println(_builder_2);
                  } else {
                    this.teensyIdToSerialMap.put(teensyId, serial);
                  }
                }
                int _available_1 = serial.available();
                boolean _greaterThan_1 = (_available_1 > 0);
                _while_1 = _greaterThan_1;
              }
              int _plus = (i + 1);
              i = _plus;
            }
            boolean _and_1 = false;
            boolean _not_1 = (!responseReceived);
            if (!_not_1) {
              _and_1 = false;
            } else {
              boolean _lessThan_1 = (i < 20);
              _and_1 = (_not_1 && _lessThan_1);
            }
            _while = _and_1;
          }
        }
      }
      PApplet.println("Finished scanning ports");
      this.cursor(PConstants.ARROW);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public void stop() {
    Collection<Serial> _values = this.teensyIdToSerialMap.values();
    for (final Serial serial : _values) {
      serial.stop();
    }
  }
}
