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

import com.google.common.collect.Lists;

import android.view.View;

import org.openqa.selenium.WebDriverException;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.util.List;

import javax.annotation.Nullable;

/**
 * The root element of Android NativeDriver. This element is the parent of all
 * top level nodes. The children includes pop-up windows, dialogs, menus,
 * toasts.
 *
 * <p>Since we use reflection to get top level nodes, this implementation might
 * not work in future version of Android SDK.
 *
 * @author Tomohiro Kaizu
 */
public class RootSearchScope implements ElementSearchScope {
  private static final String REFLECTION_ERROR_MESSAGE
      = "Android NativeDriver only supports Android 2.2 (Froyo)."
          + " Check your environment.";

  private final ElementContext context;

  public RootSearchScope(ElementContext context) {
    this.context = context;
  }

  protected Class<?> getWindowManagerImplClass() throws ClassNotFoundException {
    return Class.forName("android.view.WindowManagerImpl");
  }

  protected View[] getTopLevelViews() {
    try {
      Class<?> wmClass = getWindowManagerImplClass();
      Object wm = wmClass.getDeclaredMethod("getDefault").invoke(null);
      Field views = wmClass.getDeclaredField("mViews");
      views.setAccessible(true);
      synchronized (wm) {
        return ((View[]) views.get(wm)).clone();
      }
    } catch (ClassNotFoundException exception) {
      throw new WebDriverException(REFLECTION_ERROR_MESSAGE, exception);
    } catch (NoSuchMethodException exception) {
      throw new WebDriverException(REFLECTION_ERROR_MESSAGE, exception);
    } catch (NoSuchFieldException exception) {
      throw new WebDriverException(REFLECTION_ERROR_MESSAGE, exception);
    } catch (IllegalArgumentException exception) {
      throw new WebDriverException(REFLECTION_ERROR_MESSAGE, exception);
    } catch (InvocationTargetException exception) {
      throw new WebDriverException(REFLECTION_ERROR_MESSAGE, exception);
    } catch (SecurityException exception) {
      throw new WebDriverException(REFLECTION_ERROR_MESSAGE, exception);
    } catch (IllegalAccessException exception) {
      throw new WebDriverException(REFLECTION_ERROR_MESSAGE, exception);
    }
  }

  @Override
  public Iterable<AndroidNativeElement> getChildren() {
    View[] views = getTopLevelViews();
    List<AndroidNativeElement> children
        = Lists.newArrayListWithCapacity(views.length);
    for (View view : views) {
      children.add(context.newViewElement(view));
    }
    return children;
  }

  @Nullable
  @Override
  public AndroidNativeElement findElementByAndroidId(int id) {
    for (View view : getTopLevelViews()) {
      AndroidNativeElement found
          = context.newViewElement(view).findElementByAndroidId(id);
      if (found != null) {
        return found;
      }
    }
    return null;
  }
}
