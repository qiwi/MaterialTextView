//
//  MaterialTextViewSnapshotTests.swift
//  MaterialTextViewSnapshotTests
//
//  Created by Mikhail Motyzhenkov on 02.02.2022.
//  Copyright © 2022 QIWI. All rights reserved.
//

import XCTest
@testable import MaterialTextView
import SnapshotTesting

class MaterialTextViewSnapshotTests: XCTestCase {

    func testEmpty() throws {
		let tv = MaterialTextView(.init(style: .defaultStyle))
		tv.translatesAutoresizingMaskIntoConstraints = true
		tv.frame = CGRect(x: 0, y: 0, width: 240, height: 48)
		assert(tv)
    }
	
	func testText() throws {
		let tv = MaterialTextView(.init(text: "Text", style: .defaultStyle))
		tv.translatesAutoresizingMaskIntoConstraints = true
		tv.frame = CGRect(x: 0, y: 0, width: 240, height: 48)
		assert(tv)
	}
	
	func testTextAndHelp() throws {
		let tv = MaterialTextView(.init(text: "Text", help: "Help", style: .defaultStyle))
		tv.translatesAutoresizingMaskIntoConstraints = true
		tv.frame = CGRect(x: 0, y: 0, width: 240, height: 48)
		assert(tv)
	}
	
	func testValidation() throws {
		let tv = MaterialTextView(.init(text: "Text", help: "Help", style: .defaultStyle, actionValidator: { text in
			return text.count < 3 ? .valid : .invalid(text: "Max allowed number of symbols is 3. Very long text")
		}))
		tv.helpLabel.numberOfLines = 0
		NSLayoutConstraint.activate([
			tv.widthAnchor.constraint(equalToConstant: 120)
		])
		tv.validate()
		assert(tv, precision: 0.995)
	}
	
	func testNormalPlaceholder() throws {
		let tv = MaterialTextView(.init(style: .defaultStyle, placeholder: .init(type: .normal, text: "Placeholder")))
		tv.translatesAutoresizingMaskIntoConstraints = true
		tv.frame = CGRect(x: 0, y: 0, width: 240, height: 48)
		assert(tv)
	}

	func testPlaceholderOnTop() throws {
		let tv = MaterialTextView(.init(style: .defaultStyle, placeholder: .init(type: .alwaysOnTop, text: "Placeholder")))
		tv.translatesAutoresizingMaskIntoConstraints = true
		tv.frame = CGRect(x: 0, y: 0, width: 240, height: 48)
		assert(tv)
	}
	
	func testRightButton() throws {
		let tv = MaterialTextView(.init(text: "Text", style: .defaultStyle, placeholder: .init(type: .alwaysOnTop, text: "Placeholder"), rightButtonInfo: .init(image: "×".image(withAttributes: [.font: UIFont.systemFont(ofSize: 24)], size: nil), action: nil)))
		tv.translatesAutoresizingMaskIntoConstraints = true
		tv.frame = CGRect(x: 0, y: 0, width: 240, height: 48)
		assert(tv)
	}
	
	func testLongTextRightButton() throws {
		let tv = MaterialTextView(.init(text: "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.", style: .defaultStyle, placeholder: .init(type: .alwaysOnTop, text: "Placeholder"), rightButtonInfo: .init(image: "×".image(withAttributes: [.font: UIFont.systemFont(ofSize: 24)], size: nil), action: nil)))
		tv.translatesAutoresizingMaskIntoConstraints = true
		tv.frame = CGRect(x: 0, y: 0, width: 240, height: 48)
		assert(tv)
	}
}
