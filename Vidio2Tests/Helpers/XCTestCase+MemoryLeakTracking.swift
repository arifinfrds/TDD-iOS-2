//
//  XCTestCase+MemoryLeakTracking.swift
//  Vidio2Tests
//
//  Created by Arifin Firdaus on 25/11/22.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeak(on instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

