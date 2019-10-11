//
//  UIFont+Extensions.swift
//  MaterialTextView
//
//  Created by Mikhail Motyzhenkov on 11/10/2019.
//  Copyright © 2019 QIWI. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
	func getFontName() -> String {
		if #available(iOS 13.0, *) {
			if self.fontName.starts(with: ".") {
				return String(self.fontName.dropFirst())
			}
		}
		return self.fontName
	}
}
