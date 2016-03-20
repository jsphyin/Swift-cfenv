/**
* Copyright IBM Corporation 2016
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
**/

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import XCTest
import Foundation
import SwiftyJSON

@testable import CFEnvironment

/**
* Online tool for escaping JSON: http://www.freeformatter.com/javascript-escape.html
* Online tool for removing new lines: http://www.textfixer.com/tools/remove-line-breaks.php
* Online JSON editor: http://jsonviewer.stack.hu/
*/
class UtilsTests : XCTestCase {

  var allTests : [(String, () throws -> Void)] {
    return [
        ("testConvertStringToJSON", testConvertStringToJSON),
        ("testConvertJSONArrayToStringArray", testConvertJSONArrayToStringArray),
        ("testGetApp", testGetApp),
        ("testGetServices", testGetServices)
    ]
  }

  func testConvertStringToJSON() {
    let VCAP_APPLICATION = "{ \"users\": null,  \"instance_id\": \"7d4f24cfba06462ba23d68aaf1d7354a\",  \"instance_index\": 0,  \"host\": \"0.0.0.0\",  \"port\": 61263,  \"started_at\": \"2016-03-04 02:43:07 +0000\",  \"started_at_timestamp\": 1457059387 }"
    if let json = Utils.convertStringToJSON(VCAP_APPLICATION) {
      //print("JSON object is: \(json)")
      //print("Type is \(json["users"].dynamicType)")
      XCTAssertNil(json["users"] as? AnyObject)
      XCTAssertEqual(json["instance_id"], "7d4f24cfba06462ba23d68aaf1d7354a", "instance_id should match.")
      XCTAssertEqual(json["instance_index"], 0, "instance_index should match.")
      XCTAssertEqual(json["host"], "0.0.0.0", "host should match.")
      XCTAssertEqual(json["port"], 61263, "port should match.")
      XCTAssertEqual(json["started_at"], "2016-03-04 02:43:07 +0000", "started_at should match.")
      XCTAssertEqual(json["started_at_timestamp"], 1457059387, "started_at_timestamp should match.")
    } else {
      XCTFail("Could not generate JSON object!")
    }
  }

  func testConvertJSONArrayToStringArray() {
    let jsonStr = "{ \"tags\": [ \"data_management\", \"ibm_created\", \"ibm_dedicated_public\" ] }"
    if let json = Utils.convertStringToJSON(jsonStr) {
      let strArray: [String] = Utils.convertJSONArrayToStringArray(json, fieldName: "tags")
        XCTAssertEqual(strArray.count, 3, "There should be 3 elements in the string array.")
        UtilsTests.verifyElementInArrayExists(strArray, element: "data_management")
        UtilsTests.verifyElementInArrayExists(strArray, element: "ibm_created")
        UtilsTests.verifyElementInArrayExists(strArray, element: "ibm_dedicated_public")
    } else {
      XCTFail("Could not generate JSON object!")
    }
  }

  func testGetApp() {
    let options = "{ \"vcap\": { \"application\": { \"limits\": { \"mem\": 128, \"disk\": 1024, \"fds\": 16384 }, \"application_id\": \"e582416a-9771-453f-8df1-7b467f6d78e4\", \"application_version\": \"e5e029d1-4a1a-4004-9f79-655d550183fb\", \"application_name\": \"swift-test\", \"application_uris\": [ \"swift-test.mybluemix.net\" ], \"version\": \"e5e029d1-4a1a-4004-9f79-655d550183fb\", \"name\": \"swift-test\", \"space_name\": \"dev\", \"space_id\": \"b15eb0bb-cbf3-43b6-bfbc-f76d495981e5\", \"uris\": [ \"swift-test.mybluemix.net\" ], \"users\": null, \"instance_id\": \"7d4f24cfba06462ba23d68aaf1d7354a\", \"instance_index\": 0, \"host\": \"0.0.0.0\", \"port\": 61263, \"started_at\": \"2016-03-04 02:43:07 +0000\", \"started_at_timestamp\": 1457059387, \"start\": \"2016-03-04 02:43:07 +0000\", \"state_timestamp\": 1457059387 } } }"
    do {
      if let json = Utils.convertStringToJSON(options) {
        let appEnv = try CFEnvironment.getAppEnv(json)
        //print(appEnv.app)
        let app = appEnv.getApp()
        //print("app: \(app)")
        XCTAssertNotNil(app)
        XCTAssertEqual(app.port, 61263, "Application port number should match.")
        XCTAssertEqual(app.id, "e582416a-9771-453f-8df1-7b467f6d78e4", "Application ID value should match.")
        XCTAssertEqual(app.version, "e5e029d1-4a1a-4004-9f79-655d550183fb", "Application version number should match.")
        XCTAssertEqual(app.name, "swift-test", "App name should match.")
        XCTAssertEqual(app.instanceId, "7d4f24cfba06462ba23d68aaf1d7354a", "Application instance ID value should match.")
        XCTAssertEqual(app.instanceIndex, 0, "Application instance index value should match.")
        XCTAssertEqual(app.spaceId, "b15eb0bb-cbf3-43b6-bfbc-f76d495981e5", "Application space ID value should match.")
        let limits = app.limits
        //print("limits: \(limits)")
        XCTAssertNotNil(limits)
        XCTAssertEqual(limits!.memory, 128, "Memory value should match.")
        XCTAssertEqual(limits!.disk, 1024, "Disk value should match.")
        XCTAssertEqual(limits!.fds, 16384, "FDS value should match.")
        let uris = app.uris
        XCTAssertNotNil(uris)
        XCTAssertEqual(uris!.count, 1, "There should be only 1 uri in the uris array.")
        XCTAssertEqual(uris![0], "swift-test.mybluemix.net", "URI value should match.")
        XCTAssertEqual(app.name, "swift-test", "Application name should match.")
        let startedAt: NSDate? = app.startedAt
        XCTAssertNotNil(startedAt)
        let dateUtils = DateUtils()
        let startedAtStr = dateUtils.convertNSDateToString(startedAt)
        XCTAssertEqual(startedAtStr, "2016-03-04 02:43:07 +0000", "Application startedAt date should match.")
        XCTAssertNotNil(app.startedAtTs, "Application startedAt ts should not be nil.")
        XCTAssertEqual(app.startedAtTs, 1457059387, "Application startedAt ts should match.")
      } else {
        XCTFail("Could not generate JSON object!")
      }
    } catch let error as NSError {
      print("Error domain: \(error.domain)")
      print("Error code: \(error.code)")
      XCTFail("Could not get AppEnv object!")
    }
  }

  func testGetServices() {
    let options = "{ \"vcap\": { \"services\": { \"cloudantNoSQLDB\": [ { \"name\": \"Cloudant NoSQL DB-kd\", \"label\": \"cloudantNoSQLDB\", \"tags\": [ \"data_management\", \"ibm_created\", \"ibm_dedicated_public\" ], \"plan\": \"Shared\", \"credentials\": { \"username\": \"09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix\", \"password\": \"06c19ae06b1915d8a6649df5901eca85e885182421ffa9ef89e14bbc1b76efd4\", \"host\": \"09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix.cloudant.com\", \"port\": 443, \"url\": \"https://09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix:06c19ae06b1915d8a6649df5901eca85e885182421ffa9ef89e14bbc1b76efd4@09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix.cloudant.com\" } } ] } } }"
    do {
      if let json = Utils.convertStringToJSON(options) {
        //print("json \(json)")
        let appEnv = try CFEnvironment.getAppEnv(json)
        //let servs = appEnv.services
        //print("servs \(servs)")
        let services = appEnv.getServices()
        //print("services \(services)")
        XCTAssertEqual(services.count, 1, "There should be only 1 service in the services array.")
        for (name, service) in services {
          XCTAssertEqual(service.name, name, "Key in dictionary and service name should match.")
          XCTAssertEqual(service.name, "Cloudant NoSQL DB-kd", "Service name should match.")
          XCTAssertEqual(service.label, "cloudantNoSQLDB", "Service label should match.")
          XCTAssertEqual(service.plan, "Shared", "Service plan should match.")
          let tags = service.tags
          XCTAssertEqual(tags.count, 3, "There should be 3 tags in the tags array.")
          XCTAssertEqual(tags[0], "data_management", "Service tag #0 should match.")
          XCTAssertEqual(tags[1], "ibm_created", "Serivce tag #1 should match.")
          XCTAssertEqual(tags[2], "ibm_dedicated_public", "Serivce tag #2 should match.")
          let credentials: JSON? = service.credentials
          XCTAssertNotNil(credentials)
          XCTAssertEqual(credentials!.count, 5, "There should be 5 elements in the credentials object.")
          for (key, value) in credentials! {
            switch key {
              case "password":
                XCTAssertEqual(value, "06c19ae06b1915d8a6649df5901eca85e885182421ffa9ef89e14bbc1b76efd4", "Password in credentials object should match.")
              case "url":
                XCTAssertEqual(value, "https://09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix:06c19ae06b1915d8a6649df5901eca85e885182421ffa9ef89e14bbc1b76efd4@09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix.cloudant.com", "URL in credentials object should match.")
              case "port" :
                XCTAssertEqual(value, 443, "Port in credentials object should match.")
              case "host":
                XCTAssertEqual(value, "09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix.cloudant.com", "Host in credentials object should match.")
              case "username":
                XCTAssertEqual(value, "09ed7c8a-fae8-48ea-affa-0b44b2224ec0-bluemix", "Username in credentials object should match.")
              default:
                XCTFail("Unexpected key in credentials: \(key)")
            }
          }
        }
      } else {
        XCTFail("Could not generate JSON object!")
      }
    } catch let error as NSError {
      print("Error domain: \(error.domain)")
      print("Error code: \(error.code)")
      XCTFail("Could not get AppEnv object!")
    }
  }

  private class func verifyElementInArrayExists(strArray: [String], element: String) {
    let index: Int? = strArray.indexOf(element)
    XCTAssertNotNil(index, "Array should contain element: \(element)")
  }

 }