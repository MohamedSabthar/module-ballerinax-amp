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

import ballerina/http;
import ballerina/test;

const CHAT_PORT = 9590;
const SHARED_PORT = 9591;

service ChatService /agent on new Listener(CHAT_PORT) {
    resource function post chat(@http:Payload ChatRequest request) returns ChatResponse|error {
        if request.message == "fail" {
            return error("agent failed");
        }
        return {
            response: string `${request.sessionId}: ${request.message}`,
            "context": request?.context,
            "extra": request["extra"]
        };
    }
}

listener http:Listener sharedHttpListener = new (SHARED_PORT);

service ChatService /shared on new Listener(sharedHttpListener) {
    resource function post chat(@http:Payload ChatRequest request) returns ChatResponse {
        return {response: request.message};
    }
}

final http:Client chatClient = check new (string `localhost:${CHAT_PORT}/agent`);

@test:Config
function testJsonReply() returns error? {
    json reply = check chatClient->/chat.post({session_id: "session-123", message: "Hi", context: {}, extra: 1});
    test:assertEquals(reply, {response: "session-123: Hi", context: {}, extra: 1});
}

@test:Config
function testJsonReplyWithoutContext() returns error? {
    ChatResponse reply = check chatClient->/chat.post({session_id: "s1", message: "Hi"});
    test:assertEquals(reply.response, "s1: Hi");
}

@test:Config
function testMissingSessionId() returns error? {
    http:Response response = check chatClient->/chat.post({message: "Hi"});
    test:assertEquals(response.statusCode, 400);
}

@test:Config
function testErrorReply() returns error? {
    http:Response response = check chatClient->/chat.post({session_id: "s1", message: "fail"});
    test:assertEquals(response.statusCode, 500);
}

@test:Config
function testExistingHttpListener() returns error? {
    http:Client sharedClient = check new (string `localhost:${SHARED_PORT}/shared`);
    ChatResponse reply = check sharedClient->/chat.post({session_id: "s1", message: "Hi"});
    test:assertEquals(reply.response, "Hi");
}

