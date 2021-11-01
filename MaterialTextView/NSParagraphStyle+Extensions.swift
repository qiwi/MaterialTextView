//
//  NSAttributedString+Extensions.swift
//  MaterialTextView
//
//  Created by Mikhail Motyzhenkov on 13/03/2019.
//  Copyright © 2019 QIWI. All rights reserved.
//

import Foundation
import UIKit

extension NSParagraphStyle {
	static var materialTextViewDefault: NSParagraphStyle {
		let para = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		para.minimumLineHeight = 16
		para.lineSpacing = 4
		return para
	}
}
