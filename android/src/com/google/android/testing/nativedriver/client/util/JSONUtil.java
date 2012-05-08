package com.google.android.testing.nativedriver.client.util;

import java.io.IOException;

import org.codehaus.jackson.JsonGenerationException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;

public class JSONUtil {
  public static String toJSON(Object obj) {
//    String json = JSON.encode(obj);
    ObjectMapper objectMapper = new ObjectMapper();
    String json = "";
    try {
      json = objectMapper.writeValueAsString(obj);
    } catch (JsonGenerationException e) {
      e.printStackTrace();
    } catch (JsonMappingException e) {
      e.printStackTrace();
    } catch (IOException e) {
      e.printStackTrace();
    }
    return json;
  }
}
