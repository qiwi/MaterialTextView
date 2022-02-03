//
//  SnapshotTestHelper.swift
//  MaterialTextViewSnapshotTests
//
//  Created by Mikhail Motyzhenkov on 02.02.2022.
//  Copyright © 2022 QIWI. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import SnapshotTesting

func assert(_ view: UIView,
			file: StaticString = #file,
			testName: String = #function,
			line: UInt = #line) {
	guard UIScreen.main.scale == 3 else {
		fatalError("Use 3x device")
	}
	let named = "iOS\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)"
	if let result = verifySnapshot(matching: view, as: .image, named: named, file: file, testName: testName, line: line) {
		XCTFail(result)
	}
}
