package com.google.android.testing.nativedriver.server;

import org.openqa.selenium.By;

public class ByAndIndex {
 By by;
 int index;
 
 public ByAndIndex(By by, int index){
   this.by = by;
   this.index = index;
 }
 
 public String toString() {
  return "by:" + by + "/ index:" + index;
 }
}
