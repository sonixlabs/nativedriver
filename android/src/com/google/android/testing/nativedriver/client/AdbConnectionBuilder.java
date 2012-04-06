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

import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.Joiner;
import com.google.common.base.Preconditions;
import com.google.common.collect.Lists;

import java.io.File;
import java.util.List;

import javax.annotation.Nullable;

/**
 * Configures and creates instances of {@link AdbConnection}.
 *
 * @see AdbConnection#AdbConnection(String, Integer, Integer, Integer)
 * @author Matt DeVore
 */
public class AdbConnectionBuilder {
  @Nullable private String adbPath;
  @Nullable private Integer adbServerPort;
  @Nullable private Integer emulatorConsolePort;
  @Nullable private Integer emulatorAdbPort;

  public AdbConnectionBuilder withAdbPath(String adbPath) {
    this.adbPath = Preconditions.checkNotNull(adbPath);
    return this;
  }

  /**
   * Attempts to find {@code adb} automatically by reading the SDK path from
   * {@code ANDROID_SDK} environment variable and searching certain
   * sub-directories in it. Then it sets the ADB path of this builder to that
   * value.
   *
   * @return this instance
   */
  public AdbConnectionBuilder findAdbFromEnvVariable() {
    String sdkPath = System.getenv("ANDROID_SDK");

    if (sdkPath == null) {
      throw new IllegalStateException("Could not find the adb tool because the "
          + "ANDROID_SDK environment variable has not been set.");
    }

    return findAdbFromAndroidSdk(sdkPath);
  }

  /**
   * Attempts to find {@code adb} automatically given the Android SDK path and
   * then searching certain sub-directories in it. Then it sets the ADB path of
   * this builder to that value.
   *
   * @param androidSdkPath the path to the Android SDK
   * @return this instance
   */
  public AdbConnectionBuilder findAdbFromAndroidSdk(String androidSdkPath) {
    this.adbPath = findAdb(Preconditions.checkNotNull(androidSdkPath));
    return this;
  }

  public AdbConnectionBuilder withAdbServerPort(Integer adbServerPort) {
    this.adbServerPort = adbServerPort;
    return this;
  }

  public AdbConnectionBuilder withEmulatorConsolePort(
      Integer emulatorConsolePort) {
    this.emulatorConsolePort = emulatorConsolePort;
    return this;
  }

  public AdbConnectionBuilder withEmulatorAdbPort(Integer emulatorAdbPort) {
    this.emulatorAdbPort = emulatorAdbPort;
    return this;
  }

  // note: if you want methods to set default ports explicitly - for instance
  // withDefaultAdbServerPort() - feel free to add them.

  public AdbConnection build() {
    return new AdbConnection(Preconditions.checkNotNull(adbPath),
        adbServerPort, emulatorConsolePort, emulatorAdbPort);
  }

  @VisibleForTesting
  protected boolean fileExists(String path) {
    return new File(path).exists();
  }

  private static String joinPath(String root, String[] path) {
    if (root.endsWith(File.separator)) {
      root = root.substring(0, root.length() - 1);
    }

    return Joiner.on(File.separator).join(Lists.asList(root, path));
  }

  private String findAdb(String androidSdkPath) {
    String[] possibleLocations = new String[] {"platform-tools", "tools"};
    List<String> triedLocations = Lists.newArrayList();

    for (String subDirectory : possibleLocations) {
      String fullPath
          = joinPath(androidSdkPath, new String[] {subDirectory, "adb"});

      if (fileExists(fullPath)) {
        return fullPath;
      }

      triedLocations.add(fullPath);
    }

    throw new AdbException(
        "Could not find adb in any of the expected locations: "
        + triedLocations);
  }
}
