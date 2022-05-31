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
	func materialTextViewStateDidChange(_ materialTextView: MaterialTextView, errorState: MaterialTextViewModel.ErrorState)
}

public extension MaterialTextViewDelegate {
	func materialTextViewDidChange(_ materialTextView: MaterialTextView) { }
	func materialTextViewDidBeginEditing(_ materialTextView: MaterialTextView) { }
	func materialTextViewDidEndEditing(_ materialTextView: MaterialTextView) { }
	func materialTextView(_ materialTextView: MaterialTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { return true }
	func materialTextViewStateDidChange(_ materialTextView: MaterialTextView, errorState: MaterialTextViewModel.ErrorState) { }
}

extension MaterialTextView {
	@objc func textComponentDidChange() {
		if shouldUpdate && viewModel.text != textComponentInternal.inputText {
			shouldUpdate = false
			viewModel.text = textComponentInternal.inputText
			delegate?.materialTextViewDidChange(self)
			shouldUpdate = true
		}
	}
	
	func textComponent(shouldChangeCharactersIn range: NSRange, replacementText text: String) -> Bool {
		if let delegate = delegate {
			let result = delegate.materialTextView(self, shouldChangeTextIn: range, replacementText: text)
			if !result { return false }
		}
		if let result = viewModel.shouldChangeText?(range, text) {
			return result
		}
		return true
	}
	
	func textComponentDidEndEditing() {
		viewModel.isActive = false
		viewModel.didEndEditing?()
		delegate?.materialTextViewDidEndEditing(self)
	}
	
	func textComponentDidBeginEditing() {
		hadInput = true
		viewModel.isActive = true
		viewModel.didBeginEditing?()
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
		viewModel.errorState = validate(validator: viewModel.actionValidator)
		viewModel.wasActionValid = !viewModel.errorState.isError
		stateChanged(placeholderTypeIsChanged: false)
		return viewModel.wasActionValid
	}

	@discardableResult
	internal func validate(validator: Validator<String>) -> MaterialTextViewModel.ErrorState {
		switch validator(viewModel.text) {
		case .valid:
			return .normal
		case .invalid(let info):
			if info.linkText != nil || info.urlString != nil {
				return .linkError(text: info.text, linkText: info.linkText, urlString: info.urlString)
			}
			return .error(text: info.text)
		}
	}
}
