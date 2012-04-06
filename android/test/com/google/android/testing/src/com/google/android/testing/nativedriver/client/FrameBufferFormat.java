/*
Copyright 2011 NativeDriver committers
Copyright 2011 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package com.google.android.testing.nativedriver.client;

import com.google.common.base.Preconditions;
import com.google.common.io.LittleEndianDataInputStream;
import com.google.common.primitives.Ints;

import java.awt.image.BufferedImage;
import java.io.DataInput;
import java.io.IOException;
import java.io.InputStream;

/**
 * Contains information describing the format of an Android device's frame
 * buffer. This includes the x and y resolution, and the number of bits per
 * pixel. This class also has helper methods for retrieving and converting frame
 * buffer data from a device.
 *
 * <p>Palletized and grayscale color modes are not currently supported.
 * Supported {@code bitsPerPixel} values are 15, 16, and 32.
 *
 * <p>This class is largely based on C code from the open source Android
 * Screenshot Library, in particular the
 * {@link <a href="http://code.google.com/p/android-screenshot-library/source/browse/native/fbshot.c">fbshot.c file</a>}.
 *
 * @author Matt DeVore
 */
public class FrameBufferFormat {
  /**
   * The request code invoked on the frame buffer device. This request code can
   * be passed to {@link AdbConnection#doIoctlForReading(String, int, int)}, and
   * is used to get the frame buffer format information.
   *
   * <p>Value: {@code 0x4600}
   *
   * @see {@code linux/fb.h}
   */
  protected static final int FBIOGET_FSCREENINFO = 0x4600;

  /**
   * The device file which represents the frame buffer, supplied as a constant
   * for convenience.
   *
   * <p>Value: {@code /dev/graphics/fb0}
   */
  public static final String FB_DEVICEFILE = "/dev/graphics/fb0";

  // The number of bytes we need to read from the fb_var_screeninfo structure
  // (defined in linux/fb.h), and the byte offsets of the important values.
  // This structure is read from the output of the ioctl command, executed with
  // AdbConnection#doIoctlForReading.
  private static final int FB_VAR_SCREENINFO_XRESOLUTION_OFFSET = 0;
  private static final int FB_VAR_SCREENINFO_YRESOLUTION_OFFSET = 4;
  private static final int FB_VAR_SCREENINFO_BITSPERPIXEL_OFFSET = 24;
  private static final int FB_VAR_SCREENINFO_STRUCTSIZE = 28;

  private final int xResolution, yResolution, bitsPerPixel;

  public FrameBufferFormat(int xResolution, int yResolution, int bitsPerPixel) {
    Preconditions.checkArgument(isSupportedBitsPerPixel(bitsPerPixel));
    this.xResolution = xResolution;
    this.yResolution = yResolution;
    this.bitsPerPixel = bitsPerPixel;
  }

  private static boolean isSupportedBitsPerPixel(int bitsPerPixel) {
    return bitsPerPixel == 15 || bitsPerPixel == 16 || bitsPerPixel == 32;
  }

  /**
   * Determines the format of the frame buffer of the device corresponding to
   * the given {@code AdbConnection}. This is accomplished by issuing an
   * {@code ioctl} request through {@code adb}.
   */
  public static FrameBufferFormat ofDevice(AdbConnection adb) {
    byte[] varScreenInfo = adb.doIoctlForReading(
        FB_DEVICEFILE, FBIOGET_FSCREENINFO, FB_VAR_SCREENINFO_STRUCTSIZE);

    int xResolution = readLittleEndianInteger32(
        varScreenInfo, FB_VAR_SCREENINFO_XRESOLUTION_OFFSET);
    int yResolution = readLittleEndianInteger32(
        varScreenInfo, FB_VAR_SCREENINFO_YRESOLUTION_OFFSET);
    int bitsPerPixel = readLittleEndianInteger32(
        varScreenInfo, FB_VAR_SCREENINFO_BITSPERPIXEL_OFFSET);

    return new FrameBufferFormat(xResolution, yResolution, bitsPerPixel);
  }

  public int getXResolution() {
    return xResolution;
  }

  public int getYResolution() {
    return yResolution;
  }

  public int getBitsPerPixel() {
    return bitsPerPixel;
  }

  private static int readLittleEndianInteger32(byte[] source, int byteIndex) {
    byte byte4 = source[byteIndex++];
    byte byte3 = source[byteIndex++];
    byte byte2 = source[byteIndex++];
    byte byte1 = source[byteIndex];
    return Ints.fromBytes(byte1, byte2, byte3, byte4);
  }

  /**
   * Converts raw frame buffer data to 32-bit ARGB pixels. The number of pixels
   * converted is equal to the length of the {@code into} array. For non-32-bit
   * frame buffer color depths, this algorithm duplicates the highest bits of
   * each color field into the lower bits of the 32-bit translated color. For
   * instance, if the 16-bit color is (in binary) {@code abcde fghijk lmnop},
   * the 32-bit translated color is {@code 11111111 abcdeabc fghijkfg lmnoplmn}.
   *
   * @param frameBuffer stream from which to read the frame buffer data. The
   *        format of the data should match with the format specified by this
   *        {@code FrameBufferFormat} instance.
   * @param into where to write the converted pixel data
   */
  protected void convertToRgba32(DataInput frameBuffer, int[] into) {
    try {
      switch (bitsPerPixel) {
        case 15:
          for (int x = 0; x < into.length; x++) {
            int rgb = frameBuffer.readShort() & 0x7fff;
            int red = rgb >> 10;
            red = (red << 3) | (red >> 2);
            int green = (rgb >> 5) & 31;
            green = (green << 3) | (green >> 2);
            int blue = rgb & 31;
            blue = (blue << 3) | (blue >> 2);
            into[x] = 0xff000000 | (red << 16) | (green << 8) | blue;
          }
          break;
        case 16:
          for (int x = 0; x < into.length; x++) {
            int rgb = frameBuffer.readShort() & 0xffff;
            int red = rgb >> 11;
            red = (red << 3) | (red >> 2);
            int green = (rgb >> 5) & 63;
            green = (green << 2) | (green >> 4);
            int blue = rgb & 31;
            blue = (blue << 3) | (blue >> 2);
            into[x] = 0xff000000 | (red << 16) | (green << 8) | blue;
          }
          break;
        case 32:
          for (int x = 0; x < into.length; x++) {
            into[x] = frameBuffer.readInt();
          }
      }
    } catch (IOException exception) {
      throw new AdbException(
          "IOException when reading screenshot data over adb.", exception);
    }
  }

  /**
   * Copies the frame buffer data from an {@code InputStream] to a given
   * location in a {@code BufferedImage}.
   *
   * @param source the source to read the raw frame buffer data from. The format
   *        of the data should correspond to the format represented by this
   *        instance
   * @param destination the image to which to write the converted image data
   */
  public void copyFrameBufferToImage(
      InputStream source, BufferedImage destination) {
    DataInput sourceDataStream
        = new LittleEndianDataInputStream(source);
    int[] oneLine = new int[getXResolution()];

    for (int y = 0; y < yResolution; y++) {
      convertToRgba32(sourceDataStream, oneLine);
      destination.setRGB(0, y, xResolution, 1, oneLine, 0, xResolution);
    }
  }

  @Override
  public String toString() {
    return String.format("{FrameBufferFormat xres: %d, yres: %d, bpp: %d}",
        xResolution, yResolution, bitsPerPixel);
  }
}
