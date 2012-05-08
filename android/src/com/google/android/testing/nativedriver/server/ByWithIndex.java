package com.google.android.testing.nativedriver.server;

import org.openqa.selenium.By;

public class ByWithIndex {
 By by;
 int index;
 
 public ByWithIndex(By by, int index){
   this.by = by;
   this.index = index;
 }
 
 public String toString() {
  return "by:" + by + "/ index:" + index;
 }
}
