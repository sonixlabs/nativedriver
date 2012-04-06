/*
Copyright 2010 NativeDriver committers
Copyright 2010 Google Inc.

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

package com.google.android.testing.nativedriver.server;

import android.app.Activity;
import android.app.Instrumentation;
import android.app.KeyguardManager;
import android.content.Context;
import android.os.Bundle;
import android.os.PowerManager;
import android.util.Log;

import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Handler;
import org.mortbay.jetty.HttpGenerator;
import org.mortbay.jetty.Server;
import org.mortbay.jetty.bio.SocketConnector;
import org.mortbay.jetty.handler.DefaultHandler;
import org.mortbay.jetty.handler.HandlerList;
import org.mortbay.jetty.servlet.ServletHolder;

import javax.annotation.Nullable;

// TODO(matvore): add a link to getting started documentation at the end of the
// first paragraph below. Like this:
// For instructions on how to make your Android application testable using this
// instrumentation, see the
// <a href="???">Getting Started page</a>.

/**
 * The Android Instrumentation which executes the Android NativeDriver
 * server. This class should be linked into the test application,
 * specified with the {@code instrumentation} tag in
 * {@code AndroidManifest.xml}, and once the package is installed on the device,
 * the {@code Instrumentation} should be started with {@code adb} command.
 *
 * <p>The code that handles Jetty in this class is based on
 * {@link org.openqa.selenium.android.server.JettyService} from the
 * normal Android WebDriver.
 *
 * @author Matt DeVore
 * @author Tomohiro Kaizu
 */
public class ServerInstrumentation extends Instrumentation {
  private static final String LOG_TAG = ServerInstrumentation.class.getName();
  private static final int PORT = 54129;

  @Nullable private static ServerInstrumentation instance;

  @Nullable private Server server;
  @Nullable private PowerManager.WakeLock wakeLock;
  @Nullable private KeyguardManager.KeyguardLock keyguardLock;
  private final ActivitiesReporter activitiesReporter;

  public ServerInstrumentation() {
    activitiesReporter = new ActivitiesReporter();
  }

  @Override
  public void onCreate(Bundle arguments) {
    start();
  }

  /**
   * Attempts to acquire the wake lock.
   *
   * @return a reference to the wake lock, or {@code null} if the wake lock
   *         could not be obtained
   * @see #onStart
   */
  @Nullable
  protected PowerManager.WakeLock tryToAcquireWakeLock() {
    PowerManager powerManager
        = (PowerManager) getContext().getSystemService(Context.POWER_SERVICE);
    PowerManager.WakeLock acquiredLock
        = powerManager.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK, LOG_TAG);

    try {
      acquiredLock.acquire();
    } catch (SecurityException exception) {
      Log.w(LOG_TAG, "Could not acquire a wake lock for preventing the "
          + "device from sleeping during testing.", exception);
      acquiredLock = null;
    }

    return acquiredLock;
  }

  /**
   * Attempts to acquire the keyguard lock.
   *
   * @return a reference to the keyguard lock, or {@code null} if the keyguard
   *         lock could not be obtained
   * @see #onStart
   */
  @Nullable
  protected KeyguardManager.KeyguardLock tryToAcquireKeyguardLock() {
    KeyguardManager keyguardManager = (KeyguardManager) getContext()
        .getSystemService(Context.KEYGUARD_SERVICE);
    KeyguardManager.KeyguardLock acquiredLock
        = keyguardManager.newKeyguardLock(LOG_TAG);

    try {
      acquiredLock.disableKeyguard();
    } catch (SecurityException exception) {
      Log.w(LOG_TAG, "Could not disable the keyguard for testing; it must be "
          + "disabled manually.", exception);
      acquiredLock = null;
    }

    return acquiredLock;
  }

  /**
   * Obtains locks to eliminate manual interaction during automation and starts
   * the Jetty server to listen for WebDriver requests.
   *
   * <p>This method attempts to disable the following features of the
   * Android device which would otherwise get in the way of automation testing:
   * <ul>
   *   <li>Obtain a wake lock of type
   *   {@link android.os.PowerManager#SCREEN_DIM_WAKE_LOCK}, to
   *   prevent the CPU from going to sleep.
   *   <li>Disable the keyguard, so that the screen will be unlocked
   *   (if necessary) and stay unlocked until the {@code Instrumentation}
   *   ends.
   * </ul>
   * If any of these operations fails, a warning message is printed to
   * {@code logcat}. This will happen when you are missing the
   * necessary {@code <uses-permissions>} tags in the
   * {@code AndroidManifest.xml} file.
   */
  @Override
  public void onStart() {
    wakeLock = tryToAcquireWakeLock();
    keyguardLock = tryToAcquireKeyguardLock();

    synchronized (ServerInstrumentation.class) {
      startJetty();

      if (server == null) {
        finish(1, null);
        return;
      }

      instance = this;
    }
  }

  @Override
  public void callActivityOnResume(Activity activity) {
    super.callActivityOnResume(activity);

    activitiesReporter.wasResumed(activity);
  }

  @Override
  public void callActivityOnCreate(Activity activity, Bundle icicle) {
    super.callActivityOnCreate(activity, icicle);

    activitiesReporter.wasCreated(activity);
  }

  @Override
  public void callActivityOnDestroy(Activity activity) {
    activitiesReporter.wasDestroyed(activity);

    super.callActivityOnDestroy(activity);
  }

  public Activities getActivities() {
    return activitiesReporter.getActivities();
  }

  /**
   * Called by the Android runtime to clean up the {@code Instrumentation}.
   * This implementation releases the locks obtained in {@code onStart} and
   * stops the Jetty server.
   */
  @Override
  public void onDestroy() {
    if (wakeLock != null) {
      wakeLock.release();
      wakeLock = null;
    }

    if (keyguardLock != null) {
      keyguardLock.reenableKeyguard();
      keyguardLock = null;
    }

    if (server != null) {
      try {
        callServerStop();
      } catch (Exception exception) {
        Log.e(LOG_TAG, "Exception when stopping Jetty.", exception);
      }

      Log.i(LOG_TAG, "Jetty stopped");

      server = null;
    } else {
      Log.i(LOG_TAG, "In onDestroy(), but Jetty is not running");
    }

    instance = null;
  }

  /**
   * Returns the last instance of {@code ServerInstrumentation} that was
   * started.
   *
   * <p>In general, there will never be more than one instance
   * alive at a time, since only one instance of some instrumentation
   * can be running for any application. If the instrumentation is associated
   * with more than one target package in the {@code AndroidManifest.xml} file,
   * this may not be true. The current version does not support more than one
   * running instance of {@code ServerInstrumentation} for the same application.
   */
  @Nullable
  public static synchronized ServerInstrumentation getInstance() {
    return instance;
  }

  public Server getServer() {
    return server;
  }

  /**
   * Returns the port on which the Jetty server listens. This is not currently
   * overrideable, and is set to 54129.
   *
   * @return 54129
   */
  public int getPort() {
    return PORT;
  }

  protected Server createServer() {
    return new Server();
  }

  protected Connector createConnector() {
    SocketConnector socketConnector = new SocketConnector();
    socketConnector.setPort(PORT);
    socketConnector.setAcceptors(1);
    return socketConnector;
  }

  protected Handler createHandler() {
    org.mortbay.jetty.servlet.Context root
        = new org.mortbay.jetty.servlet.Context(server, "/hub",
            org.mortbay.jetty.servlet.Context.SESSIONS);
    root.addServlet(new ServletHolder(new AndroidNativeDriverServlet()), "/*");

    HandlerList handlers = new HandlerList();
    handlers.setHandlers(
        new org.mortbay.jetty.Handler[] {root, new DefaultHandler()});
    return handlers;
  }

  protected void callServerStart() throws Exception {
    server.start();
  }

  protected void callServerStop() throws Exception {
    server.stop();
  }

  protected void startJetty() {
    System.setProperty("org.mortbay.log.class", "org.mortbay.log.AndroidLog");
    server = createServer();

    server.addConnector(createConnector());
    server.setHandler(createHandler());

    try {
      callServerStart();
    } catch (Exception exception) {
      Log.e(LOG_TAG, "Exception when starting Jetty.", exception);
      server = null;
      return;
    }

    HttpGenerator.setServerVersion("Android NativeDriver jetty");

    Log.i(LOG_TAG, "Jetty started on port " + getPort());
  }
}
