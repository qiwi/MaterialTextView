//
//  MaterialTextView+Extensions.swift
//  MaterialTextView
//
//  Created by Mikhail Motyzhenkov on 13.08.2021.
//  Copyright © 2021 QIWI. All rights reserved.
//

import Foundation
import UIKit

public protocol MaterialTextViewDelegate: AnyObject {
	func materialTextViewDidChange(_ materialTextView: MaterialTextView)
	func materialTextViewDidBeginEditing(_ materialTextView: MaterialTextView)
	func materialTextViewDidEndEditing(_ materialTextView: MaterialTextView)
	func materialTextView(_ materialTextView: MaterialTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
}

public extension MaterialTextViewDelegate {
	func materialTextViewDidChange(_ materialTextView: MaterialTextView) { }
	func materialTextViewDidBeginEditing(_ materialTextView: MaterialTextView) { }
	func materialTextViewDidEndEditing(_ materialTextView: MaterialTextView) { }
	func materialTextView(_ materialTextView: MaterialTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { return true }
}

extension MaterialTextView {
	@objc func textComponentDidChange() {
		if shouldUpdate && text != textComponentInternal.inputText {
			shouldUpdate = false
			text = textComponentInternal.inputText
			textDidChange?()
			delegate?.materialTextViewDidChange(self)
			shouldUpdate = true
		}
	}
	
	func textComponent(shouldChangeCharactersIn range: NSRange, replacementText text: String) -> Bool {
		if let delegate = delegate {
			let result = delegate.materialTextView(self, shouldChangeTextIn: range, replacementText: text)
			if !result { return false }
		}
		if let result = shouldChangeText?(range, text) {
			return result
		}
		return true
	}
	
	func textComponentDidEndEditing() {
		isActive = false
		didEndEditing?()
		delegate?.materialTextViewDidEndEditing(self)
	}
	
	func textComponentDidBeginEditing() {
		isActive = true
		didBeginEditing?()
		delegate?.materialTextViewDidBeginEditing(self)
	}
}

extension MaterialTextView: UITextViewDelegate {
	
	public func textViewDidChange(_ textView: UITextView) {
		textComponentDidChange()
	}
	
	public func textViewDidBeginEditing(_ textView: UITextView) {
		textComponentDidBeginEditing()
	}
	
	public func textViewDidEndEditing(_ textView: UITextView) {
		textComponentDidEndEditing()
	}
	
	public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		return textComponent(shouldChangeCharactersIn: range, replacementText: text)
	}
}

extension MaterialTextView: UITextFieldDelegate {
	public func textFieldDidBeginEditing(_ textField: UITextField) {
		textComponentDidBeginEditing()
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		textComponentDidEndEditing()
	}
	
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		return textComponent(shouldChangeCharactersIn: range, replacementText: string)
	}
}

extension MaterialTextView: Validatable {
	@discardableResult
	public func validate() -> Bool {
		if let actionValidator = actionValidator {
			errorState = validate(validator: actionValidator)
		}
		wasActionValid = !errorState.isError
		stateChanged(placeholderTypeIsChanged: false)
		return wasActionValid
	}

	@discardableResult
	internal func validate(validator: Validator<String>) -> ErrorState {
		switch validator(text) {
		case .valid:
			return .normal
		case .invalid(let text):
			return .error(text)
		}
	}
}

public extension MaterialTextView {
	struct ButtonInfo {
		let imageName: String
		let action: EmptyClosure?

		public init(imageName: String, action: (() -> Void)?) {
			self.imageName = imageName
			self.action = action
		}
	}
	
	enum ErrorState: Equatable {
		case normal
		case error(String)
		
		var isError: Bool {
			switch self {
			case .normal:
				return false
			case .error(_):
				return true
			}
		}
	}

	enum PlaceholderType: Equatable {
		case normal
		case animated
		case alwaysOnTop
	}

	struct Placeholder: Equatable {
		public var type: PlaceholderType
		public var text: String
		
		public init(type: PlaceholderType, text: String) {
			self.type = type
			self.text = text
		}
	}
}

public extension MaterialTextView {
	
	struct VisualState: Equatable {
		
		public static func == (lhs: VisualState, rhs: VisualState) -> Bool {
			return  lhs.lineHeight == rhs.lineHeight &&
				lhs.lineColor == rhs.lineColor &&
				areAttributesEqual(lhs.titleAttributes, rhs.titleAttributes) &&
				areAttributesEqual(lhs.helpAttributes, rhs.helpAttributes)
		}
		
		public var helpAttributes: [NSAttributedString.Key: Any]
		public var titleAttributes: [NSAttributedString.Key: Any]
		public var lineColor: UIColor
		public var lineHeight: CGFloat
		
		public init(helpAttributes: [NSAttributedString.Key: Any],
					titleAttributes: [NSAttributedString.Key: Any],
					lineColor: UIColor,
					lineHeight: CGFloat) {
			self.helpAttributes = helpAttributes
			self.titleAttributes = titleAttributes
			self.lineColor = lineColor
			self.lineHeight = lineHeight
		}
	}
	
	struct Style: Equatable {
		
		public static func == (lhs: Style, rhs: Style) -> Bool {
			return lhs.normalActive == rhs.normalActive &&
				lhs.normalInactive == rhs.normalInactive &&
				lhs.errorActive == rhs.errorActive &&
				lhs.errorInactive == rhs.errorInactive &&
				areAttributesEqual(lhs.textAttributes, rhs.textAttributes) &&
				areAttributesEqual(lhs.placeholderAttributes, rhs.placeholderAttributes)
		}
		
		public var normalActive: VisualState
		public var normalInactive: VisualState
		public var errorActive: VisualState
		public var errorInactive: VisualState
		public var textAttributes: [NSAttributedString.Key: Any]
		public var placeholderAttributes: [NSAttributedString.Key: Any]
		
		public init(normalActive: VisualState,
					normalInactive: VisualState,
					errorActive: VisualState,
					errorInactive: VisualState,
					textAttributes: [NSAttributedString.Key: Any],
					placeholderAttributes: [NSAttributedString.Key: Any]) {
			self.normalActive = normalActive
			self.normalInactive = normalInactive
			self.errorActive = errorActive
			self.errorInactive = errorInactive
			self.textAttributes = textAttributes
			self.placeholderAttributes = placeholderAttributes
		}
		
		public static var defaultStyle =
			Style(normalActive: VisualState(helpAttributes: [.font: UIFont.systemFont(ofSize: 12),
															 .foregroundColor: UIColor.darkGray],
											titleAttributes: [.font: UIFont.systemFont(ofSize: 10),
															  .foregroundColor: UIColor.black],
											lineColor: UIColor.blue,
											lineHeight: 2),
				  normalInactive: VisualState(helpAttributes: [.font: UIFont.systemFont(ofSize: 12),
															   .foregroundColor: UIColor.darkGray],
											  titleAttributes: [.font: UIFont.systemFont(ofSize: 10),
																.foregroundColor: UIColor.gray],
											  lineColor: UIColor.black,
											  lineHeight: 1),
				  errorActive: VisualState(helpAttributes: [.font: UIFont.systemFont(ofSize: 12),
															.foregroundColor: UIColor.red],
										   titleAttributes: [.font: UIFont.systemFont(ofSize: 10),
															 .foregroundColor: UIColor.red],
										   lineColor: UIColor.red,
										   lineHeight: 2),
				  errorInactive: VisualState(helpAttributes: [.font: UIFont.systemFont(ofSize: 12),
															  .foregroundColor: UIColor.red],
											 titleAttributes: [.font: UIFont.systemFont(ofSize: 10),
															   .foregroundColor: UIColor.red],
											 lineColor: UIColor.red,
											 lineHeight: 1),
				  textAttributes: [.font: UIFont.systemFont(ofSize: 16),
								   .foregroundColor: UIColor.black],
				  placeholderAttributes: [.font: UIFont.systemFont(ofSize: 16),
										  .foregroundColor: UIColor.lightGray]
			)
	}
}

private func areAttributesEqual(_ left: [NSAttributedString.Key: Any], _ right: [NSAttributedString.Key: Any]) -> Bool {
	let leftFont = left[NSAttributedString.Key.font] as? UIFont
	let rightFont = right[NSAttributedString.Key.font] as? UIFont
	let leftColor = left[NSAttributedString.Key.foregroundColor] as? UIColor
	let rightColor = right[NSAttributedString.Key.foregroundColor] as? UIColor
	let leftKern = left[NSAttributedString.Key.kern] as? NSNumber
	let rightKern = right[NSAttributedString.Key.kern] as? NSNumber
	let leftPara = left[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle
	let rightPara = right[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle
	return leftFont == rightFont &&
		leftColor == rightColor &&
		leftKern == rightKern &&
		leftPara == rightPara
}
