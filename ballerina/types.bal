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

# A request sent to the agent's `chat` endpoint, e.g. by the Agent Manager console's Try It page.
# Additional fields sent by the caller are retained as rest fields.
#
# + sessionId - Conversation identifier, sent as `session_id`; reused for follow-up messages
# + message - The user's message
# + context - Optional context; the console sends an empty object
public type ChatRequest record {
    @jsondata:Name {value: "session_id"}
    string sessionId;
    string message;
    map<json> context?;
};

# A JSON reply from the agent's `chat` endpoint. Additional fields are sent as-is.
#
# + response - The agent's reply
public type ChatResponse record {
    string response;
};

# Defines a chat service compatible with the Agent Manager console's Try It page. The service
# exposes `POST /chat` (relative to its base path), which replies with a `ChatResponse` as JSON.
#
# The request parameter must be annotated with `@http:Payload`:
# ```ballerina
# service amp:ChatService /agent on new amp:Listener(9090) {
#     resource function post chat(@http:Payload amp:ChatRequest request) returns amp:ChatResponse|error {
#         return {response: check agent.run(request.message, request.sessionId)};
#     }
# }
# ```
public type ChatService distinct service object {
    *http:Service;

    resource function post chat(@http:Payload ChatRequest request) returns ChatResponse|error;
};

