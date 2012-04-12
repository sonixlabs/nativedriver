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
  private static final Map<String, ByAndIndex> elements = new HashMap<String, ByAndIndex>();

  public static void add(String elementId, By by, int index)
  {
    elements.put(elementId, new ByAndIndex(by, index));
  }

  public static ByAndIndex get(String elementId) {
    return ((ByAndIndex)elements.get(elementId));
  }
  
  // for Debug
  public static void dump(){
    for(Map.Entry<String, ByAndIndex> e : elements.entrySet()) {
      System.out.println(e.getKey() + " : " + e.getValue());
    }
  }

}

