package com.makerbar.x2.display.config;

import com.google.common.collect.Lists;
import com.makerbar.x2.display.config.RotationDirection;
import com.makerbar.x2.display.config.SectorRowOrientation;
import java.util.Collections;
import java.util.List;
import org.eclipse.xtend.lib.Data;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.util.ToStringHelper;

@Data
@SuppressWarnings("all")
public class POVConfig {
  public static RotationDirection rotationDirection = RotationDirection.COUNTERCLOCKWISE;
  
  public static int sectorWidth = 56;
  
  public static int numSectorColumns = 4;
  
  public static int sectorHeight = 17;
  
  public static List<SectorRowOrientation> sectorRows = Collections.<SectorRowOrientation>unmodifiableList(Lists.<SectorRowOrientation>newArrayList(SectorRowOrientation.TOP_DOWN, SectorRowOrientation.TOP_DOWN, SectorRowOrientation.TOP_DOWN, SectorRowOrientation.BOTTOM_UP, SectorRowOrientation.BOTTOM_UP, SectorRowOrientation.BOTTOM_UP));
  
  public static int width = new Function0<Integer>() {
    public Integer apply() {
      int _multiply = (POVConfig.numSectorColumns * POVConfig.sectorWidth);
      return _multiply;
    }
  }.apply();
  
  public static int height = new Function0<Integer>() {
    public Integer apply() {
      int _size = POVConfig.sectorRows.size();
      int _multiply = (_size * POVConfig.sectorHeight);
      return _multiply;
    }
  }.apply();
  
  public POVConfig() {
    super();
  }
  
  @Override
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    return result;
  }
  
  @Override
  public boolean equals(final Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    POVConfig other = (POVConfig) obj;
    return true;
  }
  
  @Override
  public String toString() {
    String result = new ToStringHelper().toString(this);
    return result;
  }
}
