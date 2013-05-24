package com.google.android.testing.nativedriver.server;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author Kazuhiro Yamada
 *
 */
public class ActivityDumper {
  public Map<String, Object> dumpActivity(AndroidNativeElement activityElement) {
    return getElementMap(activityElement, null, "");
  }

  private Map<String, Integer>idSeqMap = new HashMap<String, Integer>();
  private Map<String, Integer>textSeqMap = new HashMap<String, Integer>();

  public List<Map<String, Object>> getElementChildrenMap(
      AndroidNativeElement androidNativeElement, String uid) {
    if (androidNativeElement == null) {
      return null;
    }
    List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
    int i = 0;
    for (AndroidNativeElement el : androidNativeElement.getChildren()) {
      list.add(getElementMap(el, androidNativeElement.getTagName(), uid + "/"
          + i));
      i++;
    }
    return list;
  }

  public String getMethod(String id, String text, String parentTagName) {
    if (text != "") {
      return "text";
    } else if (id != "") {
      return "id";
    } else {
      return "uid";
    }
  }

  public Map<String, Object> getElementMap(AndroidNativeElement el,
      String parentTagName, String uid) {
    Map<String, Object> map = new HashMap<String, Object>();
    String id = "";
    try {
      id = el.getResourceEntryName() == null ? "" : el
        .getResourceEntryName();
    } catch (Exception ignored) {
    }
    if (id != "") {
      if (!idSeqMap.containsKey(id)) {
        idSeqMap.put(id, 0);
      }
      map.put("id", id + "(" + idSeqMap.get(id) + ")");
      idSeqMap.put(id, idSeqMap.get(id) + 1);
    }
    String text = el.getText();
    if (text != "") {
      if (!textSeqMap.containsKey(text)) {
        textSeqMap.put(text, 0);
      }
      map.put("text", text + "(" + textSeqMap.get(text) + ")");
      textSeqMap.put(text, textSeqMap.get(text) + 1);
    }
    map.put("tag", el.getTagName());
    map.put("x", el.getLocation().x);
    map.put("y", el.getLocation().y);
    map.put("h", el.getSize().height);
    map.put("w", el.getSize().width);
    String method = getMethod(id, el.getText(), parentTagName);
    map.put("m", method);
    if ("uid".equals(method)) {
      map.put("uid", uid);
    }
    map.put("children", getElementChildrenMap(el, uid));
    return map;
  }
}
