//
//  UIColorTests.swift
//  CeriseTests
//
//  Created by bl4ckra1sond3tre on 2019/6/27.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import XCTest

class UIColorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAllColors() {
#if DEBUG
        XCTAssertFalse(UIColor.cerise.allColors.isEmpty, "Colors not empty")
#endif
    }
}
