package com.google.android.testing.nativedriver.client;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.BindException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Map;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.client.params.HttpClientParams;
import org.apache.http.conn.ClientConnectionManager;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.SingleClientConnManager;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;
import org.apache.http.util.EntityUtils;
import org.openqa.selenium.WebDriverException;
import org.openqa.selenium.net.Urls;
import org.openqa.selenium.remote.BeanToJsonConverter;
import org.openqa.selenium.remote.Command;
import org.openqa.selenium.remote.CommandExecutor;
import org.openqa.selenium.remote.JsonToBeanConverter;
import org.openqa.selenium.remote.Response;
import org.openqa.selenium.remote.ReusingSocketSocketFactory;
import org.openqa.selenium.remote.SessionId;

import com.google.android.testing.nativedriver.common.AndroidNativeDriverCommand;
import com.google.common.base.Throwables;
import com.google.common.collect.ImmutableMap;

public class HttpCommandExecutor2 implements CommandExecutor {
	private static final int MAX_REDIRECTS = 10;
	private final HttpHost targetHost;
	private final URL remoteServer;
	private final Map<String, CommandInfo> nameToUrl;
	private final HttpClient client;

	private static ClientConnectionManager getClientConnectionManager(
			HttpParams httpParams) {
		SchemeRegistry registry = new SchemeRegistry();
		registry.register(new Scheme("http", ReusingSocketSocketFactory
				.getSocketFactory(), 80));
		registry.register(new Scheme("https", SSLSocketFactory
				.getSocketFactory(), 443));
		return new SingleClientConnManager(httpParams, registry);
	}

	public HttpCommandExecutor2(URL addressOfRemoteServer) {
		try {
			this.remoteServer = ((addressOfRemoteServer == null) ? new URL(
					System.getProperty("webdriver.remote.server"))
					: addressOfRemoteServer);
		} catch (MalformedURLException e) {
			throw new WebDriverException(e);
		}

		HttpParams params = new BasicHttpParams();

		params.setParameter("http.socket.linger", Integer.valueOf(-1));
		HttpClientParams.setRedirecting(params, false);

		this.client = new DefaultHttpClient(getClientConnectionManager(params),
				params);
		if (addressOfRemoteServer.getUserInfo() != null) {
			UsernamePasswordCredentials credentials = new UsernamePasswordCredentials(
					addressOfRemoteServer.getUserInfo());
			((DefaultHttpClient) this.client).getCredentialsProvider()
					.setCredentials(AuthScope.ANY, credentials);
		}

		String host = this.remoteServer.getHost().replace(".localdomain", "");

		this.targetHost = new HttpHost(host, this.remoteServer.getPort(),
				this.remoteServer.getProtocol());

		// this.nameToUrl = ImmutableMap.builder()
		this.nameToUrl = ImmutableMap
				.<String, CommandInfo> builder()
				.put("newSession", post("/session"))
				.put("quit", delete("/session/:sessionId"))
				.put("getCurrentWindowHandle",
						get("/session/:sessionId/window_handle"))
				.put("getWindowHandles",
						get("/session/:sessionId/window_handles"))
				.put("get", post("/session/:sessionId/url"))
				.put("dismissAlert", post("/session/:sessionId/dismiss_alert"))
				.put("acceptAlert", post("/session/:sessionId/accept_alert"))
				.put("getAlertText", get("/session/:sessionId/alert_text"))
				.put("setAlertValue", post("/session/:sessionId/alert_text"))
				.put("goForward", post("/session/:sessionId/forward"))
				.put("goBack", post("/session/:sessionId/back"))
				.put("refresh", post("/session/:sessionId/refresh"))
				.put("executeScript", post("/session/:sessionId/execute"))
				.put("executeAsyncScript",
						post("/session/:sessionId/execute_async"))
				.put("getCurrentUrl", get("/session/:sessionId/url"))
				.put("getTitle", get("/session/:sessionId/title"))
				.put("getPageSource", get("/session/:sessionId/source"))
				.put("screenshot", get("/session/:sessionId/screenshot"))
				.put("setBrowserVisible", post("/session/:sessionId/visible"))
				.put("isBrowserVisible", get("/session/:sessionId/visible"))
				.put("findElement", post("/session/:sessionId/element"))
				.put("findElements", post("/session/:sessionId/elements"))
				.put("getActiveElement",
						post("/session/:sessionId/element/active"))
				.put("findChildElement",
						post("/session/:sessionId/element/:id/element"))
				.put("findChildElements",
						post("/session/:sessionId/element/:id/elements"))
				.put("clickElement",
						post("/session/:sessionId/element/:id/click"))
				.put("clearElement",
						post("/session/:sessionId/element/:id/clear"))
				.put("submitElement",
						post("/session/:sessionId/element/:id/submit"))
				.put("getElementText",
						get("/session/:sessionId/element/:id/text"))
				.put("sendKeysToElement",
						post("/session/:sessionId/element/:id/value"))
				.put("getElementValue",
						get("/session/:sessionId/element/:id/value"))
				.put("getElementTagName",
						get("/session/:sessionId/element/:id/name"))
				.put("isElementSelected",
						get("/session/:sessionId/element/:id/selected"))
				.put("setElementSelected",
						post("/session/:sessionId/element/:id/selected"))
				.put("toggleElement",
						post("/session/:sessionId/element/:id/toggle"))
				.put("isElementEnabled",
						get("/session/:sessionId/element/:id/enabled"))
				.put("isElementDisplayed",
						get("/session/:sessionId/element/:id/displayed"))
				.put("hoverOverElement",
						post("/session/:sessionId/element/:id/hover"))
				.put("getElementLocation",
						get("/session/:sessionId/element/:id/location"))
				.put("getElementLocationOnceScrolledIntoView",
						get("/session/:sessionId/element/:id/location_in_view"))
				.put("getElementSize",
						get("/session/:sessionId/element/:id/size"))
				.put("getElementAttribute",
						get("/session/:sessionId/element/:id/attribute/:name"))
				.put("elementEquals",
						get("/session/:sessionId/element/:id/equals/:other"))
				.put("getCookies", get("/session/:sessionId/cookie"))
				.put("addCookie", post("/session/:sessionId/cookie"))
				.put("deleteAllCookies", delete("/session/:sessionId/cookie"))
				.put("deleteCookie", delete("/session/:sessionId/cookie/:name"))
				.put("switchToFrame", post("/session/:sessionId/frame"))
				.put("switchToWindow", post("/session/:sessionId/window"))
				.put("close", delete("/session/:sessionId/window"))
				.put("dragElement",
						post("/session/:sessionId/element/:id/drag"))
				.put("getElementValueOfCssProperty",
						get("/session/:sessionId/element/:id/css/:propertyName"))
				.put("implicitlyWait",
						post("/session/:sessionId/timeouts/implicit_wait"))
				.put("setScriptTimeout",
						post("/session/:sessionId/timeouts/async_script"))
				.put("executeSQL", post("/session/:sessionId/execute_sql"))
				.put("getLocation", get("/session/:sessionId/location"))
				.put("setLocation", post("/session/:sessionId/location"))
				.put("getAppCache",
						get("/session/:sessionId/application_cache"))
				.put("getStatus",
						get("/session/:sessionId/application_cache/status"))
				.put("isBrowserOnline",
						get("/session/:sessionId/browser_connection"))
				.put("setBrowserOnline",
						post("/session/:sessionId/browser_connection"))
				.put("getLocalStorageItem",
						get("/session/:sessionId/local_storage/:key"))
				.put("removeLocalStorageItem",
						delete("/session/:sessionId/local_storage/:key"))
				.put("getLocalStorageKeys",
						get("/session/:sessionId/local_storage"))
				.put("setLocalStorageItem",
						post("/session/:sessionId/local_storage"))
				.put("clearLocalStorage",
						delete("/session/:sessionId/local_storage"))
				.put("getLocalStorageSize",
						get("/session/:sessionId/local_storage/size"))
				.put("getSessionStorageItem",
						get("/session/:sessionId/session_storage/:key"))
				.put("removeSessionStorageItem",
						delete("/session/:sessionId/session_storage/:key"))
				.put("getSessionStorageKey",
						get("/session/:sessionId/session_storage"))
				.put("setSessionStorageItem",
						post("/session/:sessionId/session_storage"))
				.put("clearSessionStorage",
						delete("/session/:sessionId/session_storage"))
				.put("getSessionStorageSize",
						get("/session/:sessionId/session_storage/size"))
				.put("getScreenOrientation",
						get("/session/:sessionId/orientation"))
				.put("setScreenOrientation",
						post("/session/:sessionId/orientation"))
				.put("mouseClick", post("/session/:sessionId/click"))
				.put("mouseDoubleClick",
						post("/session/:sessionId/doubleclick"))
				.put("mouseButtonDown", post("/session/:sessionId/buttondown"))
				.put("mouseButtonUp", post("/session/:sessionId/buttonup"))
				.put("mouseMoveTo", post("/session/:sessionId/moveto"))
				.put("sendModifierKeyToActiveElement",
						post("/session/:sessionId/modifier"))
				.put("imeGetAvailableEngines",
						get("/session/:sessionId/ime/available_engines"))
				.put("imeGetActiveEngine",
						get("/session/:sessionId/ime/active_engine"))
				.put("imeIsActivated", get("/session/:sessionId/ime/activated"))
				.put("imeDeactivate",
						post("/session/:sessionId/ime/deactivate"))
				.put("imeActivateEngine",
						post("/session/:sessionId/ime/activate"))
		
				.put(AndroidNativeDriverCommand.SET_TEXT_TO_ELEMENT, 
						post("/session/:sessionId/element/:id/setText"))
						
				.build();
		
	}

	public URL getAddressOfRemoteServer() {
		return this.remoteServer;
	}

	public Response execute(Command command) throws IOException {
		HttpContext context = new BasicHttpContext();

		CommandInfo info = (CommandInfo) this.nameToUrl.get(command.getName());
		try {
			HttpUriRequest httpMethod = info.getMethod(this.remoteServer,
					command);

			setAcceptHeader(httpMethod);

			if (httpMethod instanceof HttpPost) {
				String payload = new BeanToJsonConverter().convert(command
						.getParameters());
				((HttpPost) httpMethod).setEntity(new StringEntity(payload,
						"utf-8"));
				httpMethod.addHeader("Content-Type",
						"application/json; charset=utf-8");
			}

			HttpResponse response = fallBackExecute(context, httpMethod);

			response = followRedirects(this.client, context, response, 0);

			EntityWithEncoding entityWithEncoding = new EntityWithEncoding(
					response.getEntity());

			return createResponse(response, context, entityWithEncoding);
		} catch (NullPointerException e) {
			if ("quit".equals(command.getName())) {
				return new Response();
			}
			throw e;
		}
	}

	private HttpResponse fallBackExecute(HttpContext context,
			HttpUriRequest httpMethod) throws IOException {
		try {
			return this.client.execute(this.targetHost, httpMethod, context);
		} catch (BindException localBindException) {
			try {
				Thread.sleep(2000L);
			} catch (InterruptedException ie) {
				throw Throwables.propagate(ie);
			}
		}
		return this.client.execute(this.targetHost, httpMethod, context);
	}

	private void setAcceptHeader(HttpUriRequest httpMethod) {
		httpMethod.addHeader("Accept", "application/json, image/png");
	}

	private HttpResponse followRedirects(HttpClient client,
			HttpContext context, HttpResponse response, int redirectCount) {
		if (!(isRedirect(response))) {
			return response;
		}

		if (redirectCount > 10) {
			throw new WebDriverException(
					"Maximum number of redirects exceeded. Aborting");
		}

		String location = response.getFirstHeader("location").getValue();
		URI uri = null;
		try {
			uri = buildUri(context, location);

			HttpEntity httpEntity = response.getEntity();
			if (httpEntity != null) {
				httpEntity.consumeContent();
			}

			HttpGet get = new HttpGet(uri);
			setAcceptHeader(get);
			HttpResponse newResponse = client.execute(this.targetHost, get,
					context);
			return followRedirects(client, context, newResponse,
					redirectCount + 1);
		} catch (URISyntaxException e) {
			throw new WebDriverException(e);
		} catch (ClientProtocolException e) {
			throw new WebDriverException(e);
		} catch (IOException e) {
			throw new WebDriverException(e);
		}
	}

	private URI buildUri(HttpContext context, String location)
			throws URISyntaxException {
		URI uri = new URI(location);
		if (!(uri.isAbsolute())) {
			HttpHost host = (HttpHost) context.getAttribute("http.target_host");
			uri = new URI(host.toURI() + location);
		}
		return uri;
	}

	private boolean isRedirect(HttpResponse response) {
		int code = response.getStatusLine().getStatusCode();

		return ((((code == 301) || (code == 302) || (code == 303) || (code == 307))) && (response
				.containsHeader("location")));
	}

	private Response createResponse(HttpResponse httpResponse,
			HttpContext context, EntityWithEncoding entityWithEncoding)
			throws IOException {
		Header header = httpResponse.getFirstHeader("Content-Type");
		Response response;
		if ((header != null)
				&& (header.getValue().startsWith("application/json"))) {
			String responseAsText = entityWithEncoding.getContentString();
			// Response response;
			try {
				response = (Response) new JsonToBeanConverter().convert(
						Response.class, responseAsText);
			} catch (ClassCastException e) {
				if ((responseAsText != null) && ("".equals(responseAsText))) {
					return null;
				}
				throw new WebDriverException(
						"Cannot convert text to response: " + responseAsText, e);
			}
		} else {
			response = new Response();

			if ((header != null) && (header.getValue().startsWith("image/png")))
				response.setValue(entityWithEncoding.getContent());
			else if (entityWithEncoding.hasEntityContent()) {
				response.setValue(entityWithEncoding.getContentString());
			}

			HttpHost finalHost = (HttpHost) context
					.getAttribute("http.target_host");
			String uri = finalHost.toURI();
			int sessionIndex = uri.indexOf("/session/");
			if (sessionIndex != -1) {
				sessionIndex += "/session/".length();
				int nextSlash = uri.indexOf("/", sessionIndex);
				if (nextSlash != -1) {
					response.setSessionId(uri
							.substring(sessionIndex, nextSlash));
				}
			}

			int statusCode = httpResponse.getStatusLine().getStatusCode();
			if ((statusCode <= 199) || (statusCode >= 300)) {
				if ((statusCode > 399) && (statusCode < 500))
					response.setStatus(9);
				else if ((statusCode > 499) && (statusCode < 600)) {
					if (response.getStatus() == 0)
						response.setStatus(13);
				} else {
					response.setStatus(13);
				}

			}

			if (response.getValue() instanceof String) {
				response.setValue(((String) response.getValue()).replace(
						"\r\n", "\n"));
			}
		}
		return response;
	}

	class EntityWithEncoding {
		private final String charSet;
		private final byte[] content;

		EntityWithEncoding(HttpEntity paramHttpEntity) throws IOException {
			if (paramHttpEntity != null) {
				this.content = EntityUtils.toByteArray(paramHttpEntity);
				this.charSet = EntityUtils.getContentCharSet(paramHttpEntity);
				paramHttpEntity.consumeContent();
			} else {
				this.content = new byte[0];
				this.charSet = null;
			}
		}

		public String getContentString() throws UnsupportedEncodingException {
			return new String(this.content,
					(this.charSet != null) ? this.charSet : "utf-8");
		}

		public byte[] getContent() {
			return this.content;
		}

		public boolean hasEntityContent() {
			return (this.content != null);
		}
	}

	private enum HttpVerb {
		GET() {
			@Override
			public HttpUriRequest createMethod(String url) {
				return new HttpGet(url);
			}
		},
		POST() {
			@Override
			public HttpUriRequest createMethod(String url) {
				return new HttpPost(url);
			}
		},
		DELETE() {
			@Override
			public HttpUriRequest createMethod(String url) {
				return new HttpDelete(url);
			}
		};

		public abstract HttpUriRequest createMethod(String url);
	}

	private static CommandInfo get(String url) {
		return new CommandInfo(url, HttpVerb.GET);
	}

	private static CommandInfo post(String url) {
		return new CommandInfo(url, HttpVerb.POST);
	}

	private static CommandInfo delete(String url) {
		return new CommandInfo(url, HttpVerb.DELETE);
	}

	private static class CommandInfo {

		private final String url;
		private final HttpVerb verb;

		private CommandInfo(String url, HttpVerb verb) {
			this.url = url;
			this.verb = verb;
		}

		public HttpUriRequest getMethod(URL base, Command command) {
			StringBuilder urlBuilder = new StringBuilder();

			urlBuilder.append(base.toExternalForm().replaceAll("/$", ""));
			for (String part : url.split("/")) {
				if (part.length() == 0) {
					continue;
				}

				urlBuilder.append("/");
				if (part.startsWith(":")) {
					String value = get(part.substring(1), command);
					if (value != null) {
						urlBuilder.append(get(part.substring(1), command));
					}
				} else {
					urlBuilder.append(part);
				}
			}

			return verb.createMethod(urlBuilder.toString());
		}

		private String get(String propertyName, Command command) {
			if ("sessionId".equals(propertyName)) {
				SessionId id = command.getSessionId();
				if (id == null) {
					throw new WebDriverException("Session ID may not be null");
				}
				return id.toString();
			}

			// Attempt to extract the property name from the parameters
			Object value = command.getParameters().get(propertyName);
			if (value != null) {
				return Urls.urlEncode(String.valueOf(value));
			}
			return null;
		}
	}
}
