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

extension String {
	
	/// Generates a `UIImage` instance from this string using a specified
	/// attributes and size.
	///
	/// - Parameters:
	///     - attributes: to draw this string with. Default is `nil`.
	///     - size: of the image to return.
	/// - Returns: a `UIImage` instance from this string using a specified
	/// attributes and size, or `nil` if the operation fails.
	func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil) -> UIImage? {
		let size = size ?? (self as NSString).size(withAttributes: attributes)
		return UIGraphicsImageRenderer(size: size).image { _ in
			(self as NSString).draw(in: CGRect(origin: .zero, size: size),
									withAttributes: attributes)
		}
	}
	
}
