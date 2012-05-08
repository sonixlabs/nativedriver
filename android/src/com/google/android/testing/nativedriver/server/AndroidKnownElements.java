package com.google.android.testing.nativedriver.server;

import java.util.HashMap;
import java.util.Map;

import org.openqa.selenium.By;

/**
 * 
 * @author Kazuhiro Yamada
 *
 */
public class AndroidKnownElements{
  private static final Map<String, ByWithIndex> elements = new HashMap<String, ByWithIndex>();

  public static void add(String elementId, By by, int index)
  {
    elements.put(elementId, new ByWithIndex(by, index));
  }

  public static ByWithIndex get(String elementId) {
    return ((ByWithIndex)elements.get(elementId));
  }
}

