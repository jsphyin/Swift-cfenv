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

import Foundation

public struct DateUtils {
    
    let dateFormatter: DateFormatter
    
    public init() {
        dateFormatter = DateFormatter()
        // Example: 2016-03-04 02:43:07 +0000
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = timeZone
    }
    
    /**
     * Converts to a NSDate object a string that comforms to the following
     * format yyyy-MM-dd HH:mm:ss ZZZ.
     */
    public func convertStringToDate(dateString: String?) -> Date? {
        guard let dateStr = dateString else {
            return nil
        }
        
        let resultDate: Date?
        #if os(Linux)
            resultDate = dateFormatter.dateFromString(dateStr)
        #else
            resultDate = dateFormatter.date(from: dateStr)
        #endif
        
        return resultDate
    }
    
    /**
     * Converts a NSDate object to a string that follows the following format:
     * yyyy-MM-dd HH:mm:ss ZZZ.
     */
    public func convertNSDateToString(withDate: Date?) -> String? {
        guard let dateObj = withDate else {
            return nil
        }
        let dateString: String? = dateFormatter.string(from: dateObj)
        return dateString
    }
    
}
