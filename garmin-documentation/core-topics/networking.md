# Networking in Connect IQ

## Overview

This guide covers making HTTP requests, OAuth authentication, background data sync, and error handling for network operations in Connect IQ applications.

---

## HTTP Requests

### Basic Web Request

```monkey-c
using Toybox.Communications;
using Toybox.System;

class NetworkManager {
    function makeGetRequest(url, params, callback) {
        // Check phone connection
        if (!System.getDeviceSettings().phoneConnected) {
            callback.invoke({
                :success => false,
                :error => "Phone not connected"
            });
            return;
        }

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(
            url,
            params,
            options,
            method(:onReceive).bindWith(callback)
        );
    }

    function onReceive(callback, responseCode, data) {
        if (responseCode == 200) {
            callback.invoke({
                :success => true,
                :data => data
            });
        } else {
            callback.invoke({
                :success => false,
                :error => "HTTP " + responseCode,
                :code => responseCode
            });
        }
    }
}

// Usage
var network = new NetworkManager();
network.makeGetRequest(
    "https://api.example.com/data",
    {"key" => "value"},
    new Lang.Method(self, :onDataReceived)
);

function onDataReceived(response) {
    if (response[:success]) {
        var data = response[:data];
        // Process data
    } else {
        System.println("Error: " + response[:error]);
    }
}
```

### HTTP Methods

```monkey-c
using Toybox.Communications;

class HttpClient {
    private const BASE_URL = "https://api.example.com";

    // GET request
    function get(endpoint, params, callback) {
        makeRequest(
            BASE_URL + endpoint,
            params,
            Communications.HTTP_REQUEST_METHOD_GET,
            callback
        );
    }

    // POST request
    function post(endpoint, data, callback) {
        makeRequest(
            BASE_URL + endpoint,
            data,
            Communications.HTTP_REQUEST_METHOD_POST,
            callback
        );
    }

    // PUT request
    function put(endpoint, data, callback) {
        makeRequest(
            BASE_URL + endpoint,
            data,
            Communications.HTTP_REQUEST_METHOD_PUT,
            callback
        );
    }

    // DELETE request
    function delete(endpoint, params, callback) {
        makeRequest(
            BASE_URL + endpoint,
            params,
            Communications.HTTP_REQUEST_METHOD_DELETE,
            callback
        );
    }

    private function makeRequest(url, data, method, callback) {
        var options = {
            :method => method,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
                "User-Agent" => "ConnectIQ/1.0"
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(
            url,
            data,
            options,
            method(:handleResponse).bindWith(callback)
        );
    }

    private function handleResponse(callback, responseCode, data) {
        callback.invoke(responseCode, data);
    }
}

// Usage
var client = new HttpClient();

// GET
client.get("/users", {"id" => "123"}, method(:onResponse));

// POST
client.post("/users", {"name" => "John", "age" => 30}, method(:onResponse));

// PUT
client.put("/users/123", {"name" => "John Doe"}, method(:onResponse));

// DELETE
client.delete("/users/123", {}, method(:onResponse));
```

### Request Headers

```monkey-c
function makeAuthenticatedRequest(url, data, token) {
    var options = {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
            "Authorization" => "Bearer " + token,
            "Accept" => "application/json",
            "User-Agent" => "MyApp/1.0"
        },
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };

    Communications.makeWebRequest(
        url,
        data,
        options,
        method(:onReceive)
    );
}
```

### Content Types

```monkey-c
// Request content types
Communications.REQUEST_CONTENT_TYPE_JSON
Communications.REQUEST_CONTENT_TYPE_URL_ENCODED

// Response content types
Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
Communications.HTTP_RESPONSE_CONTENT_TYPE_IMAGE_JPEG
Communications.HTTP_RESPONSE_CONTENT_TYPE_IMAGE_PNG

// JSON request
var options = {
    :method => Communications.HTTP_REQUEST_METHOD_POST,
    :headers => {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
    },
    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
};

var jsonData = {
    "name" => "John",
    "age" => 30,
    "active" => true
};

Communications.makeWebRequest(url, jsonData, options, callback);

// URL-encoded request
var urlEncodedOptions = {
    :method => Communications.HTTP_REQUEST_METHOD_POST,
    :headers => {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
    }
};

var formData = {
    "username" => "john",
    "password" => "secret"
};

Communications.makeWebRequest(url, formData, urlEncodedOptions, callback);
```

---

## OAuth Authentication

### OAuth Flow

```monkey-c
using Toybox.Communications;
using Toybox.Application.Storage;

class OAuthManager {
    private const CLIENT_ID = "your_client_id";
    private const CLIENT_SECRET = "your_client_secret";
    private const AUTH_URL = "https://oauth.example.com/authorize";
    private const TOKEN_URL = "https://oauth.example.com/token";
    private const REDIRECT_URI = "https://your-app.com/callback";

    function initialize() {
        // Register for OAuth messages
        Communications.registerForOAuthMessages(method(:onOAuthMessage));
    }

    function startOAuth() {
        // Initiate OAuth flow
        Communications.makeOAuthRequest(
            AUTH_URL,
            {
                "client_id" => CLIENT_ID,
                "response_type" => "code",
                "redirect_uri" => REDIRECT_URI,
                "scope" => "read write"
            },
            TOKEN_URL,
            Communications.OAUTH_RESULT_TYPE_URL,
            {
                "client_id" => CLIENT_ID,
                "client_secret" => CLIENT_SECRET,
                "grant_type" => "authorization_code"
            }
        );
    }

    function onOAuthMessage(message) {
        var data = message.data;

        if (data != null) {
            var accessToken = data["access_token"];
            var refreshToken = data["refresh_token"];
            var expiresIn = data["expires_in"];

            if (accessToken != null) {
                // Save tokens
                Storage.setValue("access_token", accessToken);

                if (refreshToken != null) {
                    Storage.setValue("refresh_token", refreshToken);
                }

                if (expiresIn != null) {
                    var expiryTime = Time.now().add(new Time.Duration(expiresIn));
                    Storage.setValue("token_expiry", expiryTime.value());
                }

                // Notify app
                notifyOAuthComplete(true);
            } else {
                notifyOAuthComplete(false);
            }
        } else {
            notifyOAuthComplete(false);
        }
    }

    function getAccessToken() {
        var token = Storage.getValue("access_token");
        var expiry = Storage.getValue("token_expiry");

        // Check if token is expired
        if (token != null && expiry != null) {
            var now = Time.now().value();
            if (now < expiry) {
                return token;
            } else {
                // Token expired, refresh it
                refreshAccessToken();
                return null;
            }
        }

        return token;
    }

    function refreshAccessToken() {
        var refreshToken = Storage.getValue("refresh_token");

        if (refreshToken == null) {
            // Need to re-authenticate
            startOAuth();
            return;
        }

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        var params = {
            "grant_type" => "refresh_token",
            "refresh_token" => refreshToken,
            "client_id" => CLIENT_ID,
            "client_secret" => CLIENT_SECRET
        };

        Communications.makeWebRequest(
            TOKEN_URL,
            params,
            options,
            method(:onRefreshResponse)
        );
    }

    function onRefreshResponse(responseCode, data) {
        if (responseCode == 200 && data != null) {
            var accessToken = data["access_token"];
            var refreshToken = data["refresh_token"];
            var expiresIn = data["expires_in"];

            if (accessToken != null) {
                Storage.setValue("access_token", accessToken);

                if (refreshToken != null) {
                    Storage.setValue("refresh_token", refreshToken);
                }

                if (expiresIn != null) {
                    var expiryTime = Time.now().add(new Time.Duration(expiresIn));
                    Storage.setValue("token_expiry", expiryTime.value());
                }
            }
        } else {
            // Refresh failed, need to re-authenticate
            Storage.deleteValue("access_token");
            Storage.deleteValue("refresh_token");
            Storage.deleteValue("token_expiry");
        }
    }

    function clearTokens() {
        Storage.deleteValue("access_token");
        Storage.deleteValue("refresh_token");
        Storage.deleteValue("token_expiry");
    }

    private function notifyOAuthComplete(success) {
        // Notify app that OAuth is complete
    }
}
```

### Making Authenticated Requests

```monkey-c
class AuthenticatedApi {
    private var _oauthManager;

    function initialize(oauthManager) {
        _oauthManager = oauthManager;
    }

    function makeAuthenticatedRequest(url, params, callback) {
        var token = _oauthManager.getAccessToken();

        if (token == null) {
            callback.invoke({
                :success => false,
                :error => "Not authenticated"
            });
            return;
        }

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Authorization" => "Bearer " + token,
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(
            url,
            params,
            options,
            method(:onResponse).bindWith(callback)
        );
    }

    function onResponse(callback, responseCode, data) {
        if (responseCode == 401) {
            // Token expired, refresh and retry
            _oauthManager.refreshAccessToken();
            callback.invoke({
                :success => false,
                :error => "Token expired, refreshing..."
            });
        } else if (responseCode == 200) {
            callback.invoke({
                :success => true,
                :data => data
            });
        } else {
            callback.invoke({
                :success => false,
                :error => "HTTP " + responseCode
            });
        }
    }
}
```

---

## Error Handling

### Comprehensive Error Handling

```monkey-c
class NetworkErrorHandler {
    function handleResponse(responseCode, data, callback) {
        if (responseCode == 200) {
            // Success
            callback.invoke({
                :success => true,
                :data => data
            });
        } else if (responseCode == 204) {
            // No content (success)
            callback.invoke({
                :success => true,
                :data => null
            });
        } else if (responseCode == 400) {
            // Bad request
            callback.invoke({
                :success => false,
                :error => "Invalid request",
                :code => 400
            });
        } else if (responseCode == 401) {
            // Unauthorized
            callback.invoke({
                :success => false,
                :error => "Authentication required",
                :code => 401
            });
        } else if (responseCode == 403) {
            // Forbidden
            callback.invoke({
                :success => false,
                :error => "Access denied",
                :code => 403
            });
        } else if (responseCode == 404) {
            // Not found
            callback.invoke({
                :success => false,
                :error => "Resource not found",
                :code => 404
            });
        } else if (responseCode == 429) {
            // Rate limited
            callback.invoke({
                :success => false,
                :error => "Too many requests",
                :code => 429
            });
        } else if (responseCode == 500) {
            // Server error
            callback.invoke({
                :success => false,
                :error => "Server error",
                :code => 500
            });
        } else if (responseCode == 503) {
            // Service unavailable
            callback.invoke({
                :success => false,
                :error => "Service unavailable",
                :code => 503
            });
        } else if (responseCode == -1) {
            // Network error
            callback.invoke({
                :success => false,
                :error => "Network error",
                :code => -1
            });
        } else if (responseCode == -400) {
            // Invalid HTTP body
            callback.invoke({
                :success => false,
                :error => "Invalid response format",
                :code => -400
            });
        } else {
            // Unknown error
            callback.invoke({
                :success => false,
                :error => "Unknown error: " + responseCode,
                :code => responseCode
            });
        }
    }
}
```

### Retry Logic

```monkey-c
class RetryableRequest {
    private const MAX_RETRIES = 3;
    private const RETRY_DELAY = 2000;  // 2 seconds

    private var _retryCount = 0;
    private var _retryTimer = null;

    function makeRequestWithRetry(url, params, options, callback) {
        Communications.makeWebRequest(
            url,
            params,
            options,
            method(:onResponse).bindWith(url, params, options, callback)
        );
    }

    function onResponse(url, params, options, callback, responseCode, data) {
        if (responseCode == 200) {
            // Success
            _retryCount = 0;
            callback.invoke(responseCode, data);
        } else if (shouldRetry(responseCode) && _retryCount < MAX_RETRIES) {
            // Retry
            _retryCount++;
            System.println("Retrying request (attempt " + _retryCount + ")");

            _retryTimer = new System.Timer();
            _retryTimer.start(
                method(:retry).bindWith(url, params, options, callback),
                RETRY_DELAY,
                false
            );
        } else {
            // Give up
            _retryCount = 0;
            callback.invoke(responseCode, data);
        }
    }

    function retry(url, params, options, callback) {
        makeRequestWithRetry(url, params, options, callback);
    }

    private function shouldRetry(responseCode) {
        // Retry on network errors and server errors
        return responseCode == -1 ||
               responseCode == 429 ||
               responseCode == 500 ||
               responseCode == 503;
    }

    function cancel() {
        if (_retryTimer != null) {
            _retryTimer.stop();
            _retryTimer = null;
        }
        _retryCount = 0;
    }
}
```

---

## Background Data Sync

### Background Service

```monkey-c
using Toybox.System;
using Toybox.Background;

// Background service class
(:background)
class BackgroundService extends System.ServiceDelegate {
    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
        // Sync data in background
        syncData();
    }

    private function syncData() {
        var url = "https://api.example.com/sync";
        var params = {
            "device_id" => System.getDeviceSettings().uniqueIdentifier
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(
            url,
            params,
            options,
            method(:onReceive)
        );
    }

    function onReceive(responseCode, data) {
        if (responseCode == 200) {
            // Store synced data
            Background.exit({
                :success => true,
                :data => data
            });
        } else {
            Background.exit({
                :success => false,
                :error => responseCode
            });
        }
    }
}

// Register background service in app
function getServiceDelegate() {
    return [new BackgroundService()];
}

// Register temporal event
function onStart(state) {
    // Register for background sync every 15 minutes
    var time = new Time.Duration(15 * 60);  // 15 minutes
    Background.registerForTemporalEvent(time);
}

// Handle background data in app
function onBackgroundData(data) {
    if (data != null && data[:success]) {
        var syncedData = data[:data];
        // Process synced data
        Storage.setValue("synced_data", syncedData);
    }
}
```

---

## Network State Management

### Connection Monitoring

```monkey-c
using Toybox.System;

class ConnectionMonitor {
    function isPhoneConnected() {
        return System.getDeviceSettings().phoneConnected;
    }

    function isBluetoothConnected() {
        var connectionInfo = System.getDeviceSettings().connectionInfo;
        if (connectionInfo != null && connectionInfo[:bluetooth] != null) {
            return connectionInfo[:bluetooth].state == System.CONNECTION_STATE_CONNECTED;
        }
        return false;
    }

    function isWifiConnected() {
        var connectionInfo = System.getDeviceSettings().connectionInfo;
        if (connectionInfo != null && connectionInfo[:wifi] != null) {
            return connectionInfo[:wifi].state == System.CONNECTION_STATE_CONNECTED;
        }
        return false;
    }

    function getConnectionStatus() {
        return {
            :phone => isPhoneConnected(),
            :bluetooth => isBluetoothConnected(),
            :wifi => isWifiConnected()
        };
    }

    function waitForConnection(callback, timeout) {
        if (isPhoneConnected()) {
            callback.invoke(true);
            return;
        }

        var timer = new System.Timer();
        var elapsed = 0;
        var checkInterval = 1000;  // 1 second

        timer.start(method(:checkConnection).bindWith(callback, timer, elapsed, timeout, checkInterval), checkInterval, true);
    }

    private function checkConnection(callback, timer, elapsed, timeout, interval) {
        elapsed += interval;

        if (isPhoneConnected()) {
            timer.stop();
            callback.invoke(true);
        } else if (elapsed >= timeout) {
            timer.stop();
            callback.invoke(false);
        }
    }
}
```

### Offline Mode

```monkey-c
class OfflineManager {
    private var _pendingRequests = [];

    function queueRequest(request) {
        _pendingRequests.add(request);
        Storage.setValue("pending_requests", _pendingRequests);
    }

    function processPendingRequests(callback) {
        if (!System.getDeviceSettings().phoneConnected) {
            callback.invoke({
                :success => false,
                :error => "No connection"
            });
            return;
        }

        var requests = Storage.getValue("pending_requests");
        if (requests == null || requests.size() == 0) {
            callback.invoke({
                :success => true,
                :processed => 0
            });
            return;
        }

        var processed = 0;
        for (var i = 0; i < requests.size(); i++) {
            var request = requests[i];
            sendRequest(request, method(:onRequestComplete).bindWith(callback, processed, requests.size()));
            processed++;
        }

        // Clear pending requests
        Storage.deleteValue("pending_requests");
        _pendingRequests = [];
    }

    private function sendRequest(request, callback) {
        Communications.makeWebRequest(
            request[:url],
            request[:params],
            request[:options],
            callback
        );
    }

    private function onRequestComplete(callback, processed, total, responseCode, data) {
        if (processed == total) {
            callback.invoke({
                :success => true,
                :processed => total
            });
        }
    }
}
```

---

## Best Practices

### Network Requests
✅ Check connection before making requests
✅ Handle all error codes
✅ Implement retry logic for transient failures
✅ Use appropriate timeouts

❌ Don't make requests without checking connection
❌ Don't ignore error responses
❌ Don't retry indefinitely
❌ Don't block UI during requests

### Authentication
✅ Store tokens securely
✅ Refresh tokens before expiry
✅ Handle token invalidation
✅ Clear tokens on logout

❌ Don't hardcode credentials
❌ Don't expose tokens in logs
❌ Don't ignore refresh token errors

### Data Management
✅ Queue requests when offline
✅ Sync in background when possible
✅ Validate response data
✅ Handle partial failures

❌ Don't lose data when offline
❌ Don't trust unvalidated data
❌ Don't ignore sync errors

### Performance
✅ Minimize request frequency
✅ Use efficient data formats (JSON)
✅ Compress large payloads
✅ Cache responses when appropriate

❌ Don't poll continuously
❌ Don't send unnecessary data
❌ Don't make redundant requests

---

## Resources

- **Communications API**: https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html
- **Background Processing**: https://developer.garmin.com/connect-iq/core-topics/backgrounding/
- **OAuth Guide**: https://developer.garmin.com/connect-iq/core-topics/authenticated-web-services/
