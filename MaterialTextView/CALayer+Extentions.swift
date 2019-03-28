//
//  MaterialTextView+Extentions.swift
//  QIWIWallet
//
//  Created by a.bushmeleva on 29.11.2018.
//  Copyright © 2018 QIWI. All rights reserved.
//

import Foundation
import UIKit

internal extension CALayer {
	@objc func animate(duration: Double, animations: (CALayer) -> Void) {
		CATransaction.begin()
		CATransaction.setAnimationDuration(duration)
		animations(self)
		CATransaction.commit()
	}
}


internal extension CATextLayer {

	@objc override func animate(duration: Double, animations: (CATextLayer) -> Void) {
		super.animate(duration: duration) { layer in
			guard let caLayer = layer as? CATextLayer else {
				assertionFailure("CATextLayer extension: casting error")
				return
			}
			animations(caLayer )
		}
	}

	var uiFont: UIFont {
		get {
			guard let font = self.font as? String else {
				assertionFailure("CATextLayer extension: casting error")
				return UIFont()
			}
			return UIFont(name: font, size: self.fontSize)!
		}
		set(value) {
			self.font = value.fontName as CFTypeRef?
			self.animate(duration: 0) { textLayer in
				textLayer.fontSize = value.pointSize
			}
		}
	}

	enum ScaleAnimationType {
		case identity
		case skip
		case scaleAndTranslate(scale: CGFloat)
	}

	func animate(animationDuration: TimeInterval, newFrame: CGRect, animationType: ScaleAnimationType = .identity, newColor: CGColor? = nil) {
		CATransaction.begin()
		CATransaction.setAnimationDuration(animationDuration)
		CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear))

		switch animationType {
		case .skip:
			break
		case .identity:
			if CATransform3DEqualToTransform(self.transform, CATransform3DIdentity) { break }
			let transform = CATransform3DIdentity
			let transformAnimation = CABasicAnimation(keyPath: #keyPath(CATextLayer.transform))
			transformAnimation.fromValue = self.transform
			transformAnimation.toValue = transform
			self.transform = transform
			self.add(transformAnimation, forKey: #keyPath(CATextLayer.transform))
		case .scaleAndTranslate(let scale):
			if scale == 1 {
				break
			}
			let startFrame = self.frame
			let dx: CGFloat = -startFrame.width * (1-scale)/2 - (startFrame.origin.x - newFrame.origin.x)
			let dy = -startFrame.height * (1-scale)/2 - (startFrame.origin.y - newFrame.origin.y)
			let transform = CATransform3D(m11: scale, m12: 0, m13: 0, m14: 0,
										  m21: 0, m22: scale, m23: 0, m24: 0,
										  m31: 0, m32: 0, m33: 1, m34: 0,
										  m41: dx, m42: dy, m43: 0, m44: 1)

			let transformAnimation = CABasicAnimation(keyPath: #keyPath(CATextLayer.transform))
			transformAnimation.fromValue = self.transform
			transformAnimation.toValue = transform
			self.transform = transform
			self.add(transformAnimation, forKey: #keyPath(CATextLayer.transform))
		}

		if let newColor = newColor {
			let colorAnimation = CABasicAnimation(keyPath: #keyPath(CATextLayer.foregroundColor))
			colorAnimation.fromValue = self.foregroundColor
			colorAnimation.toValue = newColor
			self.foregroundColor = newColor
			self.add(colorAnimation, forKey: #keyPath(CATextLayer.foregroundColor))
		}

		CATransaction.commit()
	}
}
