//
//  NSAttributedString+Extensions.swift
//  MaterialTextView
//
//  Created by Mikhail Motyzhenkov on 13/03/2019.
//  Copyright © 2019 QIWI. All rights reserved.
//

import Foundation
import UIKit

extension Optional where Wrapped == String {
	var nonEmpty: String {
		switch self {
		case .none:
			return " "
		case .some(let value):
			return value.nonEmpty
		}
	}
}

extension String {
	var nonEmpty: String {
		return self.isEmpty ? " " : self
	}
}

extension NSAttributedString {
	func safeAttributes(at: Int, range: NSRangePointer?) -> [NSAttributedString.Key: Any] {
		if self.string.isEmpty {
			return [:]
		}
		return self.attributes(at: at, effectiveRange: range)
	}
}

extension NSParagraphStyle {
	static var materialTextViewDefault: NSParagraphStyle {
		let para = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		para.minimumLineHeight = 16
		para.lineSpacing = 4
		return para
	}
}
