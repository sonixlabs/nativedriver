# NativeDriver by Sonix

## Function

* AndroidNativeDriver#setText(text)
* AndroidNativeDriver#flick(x1, y1, x2, y2)
* etc.

## Bug Fix

* Fix AndroidNativeDriver#quit() to wait until finish all activities.
* etc.

## Sample Test Code

    import junit.framework.TestCase;
    import org.openqa.selenium.By;
    import org.openqa.selenium.WebElement;
    import com.google.android.testing.nativedriver.client.AdbConnection;
    import com.google.android.testing.nativedriver.client.AdbConnectionBuilder;
    import com.google.android.testing.nativedriver.client.AndroidNativeDriver;
    import com.google.android.testing.nativedriver.client.AndroidNativeDriverBuilder;
    import com.google.android.testing.nativedriver.client.AndroidNativeElement;
    import com.google.android.testing.nativedriver.common.AndroidKeys;
    import com.google.android.testing.nativedriver.common.AndroidNativeBy;

    public class PaintTest extends TestCase {
      private AndroidNativeDriver driver;

      @Override
      protected void setUp() {
        driver = new AndroidNativeDriverBuilder().withDefaultServer().build();
      }

      @Override
      protected void tearDown() {
        driver.quit();
      }

      public void testPaint() throws InterruptedException {
        // start activity
        driver.startActivity("com.sciroccocloud.demo.MainActivity");
        Thread.sleep(1000);

        // click button
        driver.findElement(AndroidNativeBy.text("Paint")).click();
        Thread.sleep(1000);

        // send key
        driver.getKeyboard().sendKeys(AndroidKeys.MENU);
        Thread.sleep(1000);

        // flick
        driver.flick(310, 100, 390, 100);
      }
    }



--------------
Ref: [GettingStartedAndroid](https://code.google.com/p/nativedriver/wiki/GettingStartedAndroid)

## Requirements

* Android SDK 2.2 or later - download
* Eclipse version 3.5 or later (Eclipse IDE for Java Developers recommended) - download
* Android Development Toolkit (ADT) plug-in - Installing ADT
* Ant - download
* JDK 1.6 or later - download

After installing the Android SDK, you may want to put the platform-tools directory in your PATH environment variable, so you can run adb easily.

##Build the NativeDriver libraries

Clone the repository

    $ git clone https://github.com/sonixlabs/nativedriver.git

The repository that will be downloaded is organized in this manner:

    nativedriver
      |
      |__android
      |     |__src
      |     |__sample-aut (sample app under test)
      |     |__test (sample test cases that test the sample app under test)
      |
      |__third_party (all the dependencies we need)
      
Next use ant to build the NativeDriver libraries:

    $ cd nativedriver/android
    $ ant
    
The libraries are built and stored in the nativedriver/android/build directory:

* **server-standalone.jar** - this should be linked to your Android application, and runs on the Android device (or emulator). This is the NativeDriver server, and listens for requests to automate the application, such as “start an activity” or “click a UI element”
* **client-standalone.jar** - this should be linked to the test, which is the NativeDriver client. It implements a WebDriver API which communicates with the server.

These two jar packages are represented by the yellow and green components below - yellow is code that is reused from Selenium WebDriver. Green is original code from NativeDriver.



## Import the NativeDriver Sample Projects Into Eclipse

1. Start Eclipse
2. Click the File -> Import... menu item.
3. Select Existing Projects into Workspace in the General category and click Next
4. Click Select root directory and then click Browse...
5. Open the nativedriver/android/sample-aut/simplelayouts directory in the repository you downloaded
6. Confirm your screen looks like the below image and click Finish. Repeat the import process for the nativedriver/android/test directory. 

The android-test project you imported contains sample tests written with Android NativeDriver that also serve to test Android NativeDriver itself. The simplelayouts project is an Android app that the sample tests run against.

## Install the simplelayouts app to your device (or emulator)

One easy way to do this is to run the app from Eclipse by right-clicking on the simplelayouts project, then selecting Run As->Android Application.

You can also run this command:

    adb install nativedriver/android/sample-aut/simplelayouts/bin/simplelayouts.apk

## Prepare the Android device to receive NativeDriver requests
In the future these steps should be done through code, maybe using an extended AdbConnection class. For now, this part must be done manually:

(1) At a command-prompt, run this command:

    adb shell am instrument com.google.android.testing.nativedriver.simplelayouts/com.google.android.testing.nativedriver.server.ServerInstrumentation

This restarts the app with instrumentation enabled. The NativeDriver ServerInstrumentation class listens for requests to drive the app on a device port in a JSON Wire Protocol, which is almost identical to that protocol used by Selenium WebDriver

(2) Enable port forwarding to bind the device port to a port on your PC. This allows the NativeDriver client to communicate with the device through a normal TCP connection.

    adb forward tcp:54129 tcp:54129
    
You can confirm that the instrumentation is started by running adb logcat and looking for a line like this:

    I/com.google.android.testing.nativedriver.server.ServerInstrumentation(  273): Jetty started on port 54129

## Run the tests

1. Right-click one of the three test classes in the android-test project
2. Select Run As->JUnit Test.
3. Specify the Eclipse JUnit Launcher as the Preferred Launcher.
4. Watch the device screen to see the magic!
