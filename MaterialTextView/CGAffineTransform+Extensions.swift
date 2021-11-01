//
//  CGAffineTransform+Extensions.swift
//  MaterialTextView
//
//  Created by Mikhail Motyzhenkov on 19.08.2021.
//  Copyright © 2021 QIWI. All rights reserved.
//

import Foundation
import UIKit

extension CGAffineTransform {
	init(sourceRect: CGRect, destinationRect: CGRect) {
		let scales = CGSize(width: destinationRect.size.width/sourceRect.size.width, height: destinationRect.size.height/sourceRect.size.height)
		let offset = CGPoint(x: destinationRect.midX - sourceRect.midX, y: destinationRect.midY - sourceRect.midY)
		self.init(a: scales.width, b: 0, c: 0, d: scales.height, tx: offset.x, ty: offset.y)
	}
}
