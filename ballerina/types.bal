// Copyright (c) 2026 WSO2 LLC (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/data.jsondata;
import ballerina/http;

# A message sent to an agent's `chat` endpoint, e.g. from the Agent Manager console's Try It page.
#
# In JSON, the session identifier is the `session_id` field. Fields other than the ones below are
# kept as rest fields, so a caller can send extra data without the request being rejected.
#
# + sessionId - Identifies the conversation, sent as `session_id`. Messages with the same ID belong
#               to the same conversation, so pass it to the agent to keep its memory per session
#               (e.g. `agent.run(request.message, request.sessionId)`)
# + message - The user's message to the agent
# + context - Additional context for this message, if any. The Agent Manager console sends an
#             empty object
public type ChatRequest record {
    @jsondata:Name {value: "session_id"}
    string sessionId;
    string message;
    map<json> context?;
};

# An agent's reply from its `chat` endpoint, sent to the caller as JSON.
#
# Fields other than `response` are sent as-is, so a service can return extra data alongside the
# reply; the Agent Manager console displays only `response`.
#
# + response - The agent's reply to the user's message
public type ChatResponse record {
    string response;
};

# A service that exposes an agent through the `POST /chat` endpoint that the Agent Manager
# console's Try It page calls. Attach it to an `amp:Listener`; the endpoint is served at `chat`
# under the service's base path.
#
# A `ChatService` must implement the `post chat` resource below. Annotate its request parameter
# with `@http:Payload`; without the annotation, the request is not read from the JSON body and
# every call fails with `400 Bad Request`.
#
# ```ballerina
# service amp:ChatService / on new amp:Listener(8000) {
#     resource function post chat(@http:Payload amp:ChatRequest request) returns amp:ChatResponse|error {
#         string reply = check agent.run(request.message, request.sessionId);
#         return {response: reply};
#     }
# }
# ```
public type ChatService distinct service object {
    *http:Service;

    # Handles a message sent to the agent.
    #
    # + request - The message, read from the JSON request body
    # + return - The agent's reply, sent as JSON with `201 Created`, or an error, which is sent as
    #            `500 Internal Server Error`
    resource function post chat(@http:Payload ChatRequest request) returns ChatResponse|error;
};
