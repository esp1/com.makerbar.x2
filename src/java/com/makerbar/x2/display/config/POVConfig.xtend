package com.makerbar.x2.display.config

import static com.makerbar.x2.display.config.RotationDirection.*
import static com.makerbar.x2.display.config.SectorRowOrientation.*

@Data
class POVConfig {
	
	public static val rotationDirection = COUNTERCLOCKWISE
	public static val sectorWidth = 56
	public static val numSectorColumns = 4
	public static val sectorHeight = 17
	public static val sectorRows = #[
		TOP_DOWN,
		TOP_DOWN,
		TOP_DOWN,
		BOTTOM_UP,
		BOTTOM_UP,
		BOTTOM_UP
	]
	
	public static val width = numSectorColumns * sectorWidth
	public static val height = sectorRows.size * sectorHeight
	
}