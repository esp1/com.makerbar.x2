package com.makerbar.x2.display;

/**
 * Various bit manipulation functions. Coded in Java because Xtend is not so good for this.
 */
public class BitFiddler {

	// Color stuff
	
	public int getAlpha(int pixel) { return (pixel >> 24) & 0xff; }
	public int getRed(int pixel) { return (pixel >> 16) & 0xff; }
	public int getGreen(int pixel) { return (pixel >> 8) & 0xff; }
	public int getBlue(int pixel) { return pixel & 0xff; }

	/**
	 * Translate a 24 bit RGB color value to BRG order.
	 */
	public static int toBRG(int rgb) {
		return ((rgb & 0xFF0000) >> 8) | ((rgb & 0xFF00) >> 8) | ((rgb & 0xFF) << 16);
	}

	/**
	 * Translate a 24 bit RGB color value to GBR order.
	 */
	public static int toGBR(int rgb) {
		return ((rgb & 0xFF0000) >> 16) | ((rgb & 0xFF00) << 8) | ((rgb & 0xFF) << 8);
	}

	/**
	 * Translate a 24 bit RGB color value to GRB order.
	 */
	public static int toGRB(int rgb) {
		return ((rgb & 0xFF0000) >> 8) | ((rgb & 0xFF00) << 8) | (rgb & 0xFF);
	}

	/**
	 * Translate a 24 bit RGB color value to RBG order.
	 */
	public static int toRBG(int rgb) {
		return (rgb & 0xFF0000) | ((rgb & 0xFF00) >> 8) | ((rgb & 0xFF) << 8);
	}
	
	// bytes to ints
	
	public static int bytesToInt(byte[] bytes, int offset) {
		return ((bytes[offset] << 24) & 0xFF000000) | ((bytes[offset + 1] << 16) & 0xFF0000) | ((bytes[offset + 2] << 8) & 0xFF00) | ((bytes[offset + 3]) & 0xFF);
	}
	
	/**
	 * Pack bytes into int array
	 */
	public static int[] toIntArray(byte[] bytes) {
		int[] ints = new int[bytes.length / 4];  // 4 bytes in an int
		
		for (int i = 0; i < ints.length; i++) {
			ints[i] = bytesToInt(bytes, i * 4);
		}
		
		return ints;
	}
	
	// OctoWS2811
	
	/**
	 * Convert to OctoWS2811 bytes. Each bit of the 24 bit color is mapped to one of 24 consecutive bytes.
	 */
	public static void setOctoWS2811Bytes(byte[] octoBytes, int pixelIndex, int[] stripColors) {
		// For each of the strip colors
		for (int strip = 0; strip < 8; strip++) {
			int color = stripColors[strip];
			int bit = 0xFF & (1 << strip);
			
			// Step through each bit of the 24-bit color
			for (int bitIndex = 0; bitIndex < 24; bitIndex++) {
				int mask = 1 << (23 - bitIndex);
				int byteIndex = (pixelIndex * 24) + bitIndex;
				
				if ((color & mask) != 0) {
					octoBytes[byteIndex] |= (byte) (0xFF & bit);  // bitwise OR here because we will be revisiting the same byte for different strips
				} else {
					octoBytes[byteIndex] &= (byte) (0xFF & ~bit);
				}
			}
		}
	}
	
	/**
	 * Generates bitmasks for a given number of X sectors.
	 * @param numSignificantBits
	 * @return An array of ordered bitmasks where the order corresponds to the x sector offset. 
	 */
	public static byte[] generateBitmasks(int numSignificantBits) {
		byte[] bitmasks = new byte[numSignificantBits];
		
		int numInsignificantBits = 8 - numSignificantBits;
		int significantBitsMask = 0xFF >> numInsignificantBits;
		
		for (int i = 0; i < numSignificantBits; i++) {
			bitmasks[i] = (byte) ((0xFF00 >> (numInsignificantBits + i)) & significantBitsMask);
		}
		
		return bitmasks;
	}
	
	/**
	 * Gets the complement of the specified bitmask.
	 * @param bitmask
	 * @param numSignificantBits
	 * @return
	 */
	public static byte getComplementaryBitmask(byte bitmask, int numSignificantBits) {
		int numComplementaryBits = 8 - numSignificantBits;
		return (byte) (~bitmask & (0xFF >> numComplementaryBits));
	}
	
	public static byte[][] new3DByteArrayOfSize(int a, int b) {
		return new byte[a][b];
	}
	
	public static void set(byte[][] bytes, int a, int b, byte value) {
		bytes[a][b] = value;
	}

}
