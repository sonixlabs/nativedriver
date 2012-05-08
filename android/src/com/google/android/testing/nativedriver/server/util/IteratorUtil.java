package com.google.android.testing.nativedriver.server.util;


public class IteratorUtil {
  public static Object getLastElement(Iterable<?> iterable) {
    Object result = null;
    for(Object o :iterable){
      result = o;
    }
    return result;
  }
}
