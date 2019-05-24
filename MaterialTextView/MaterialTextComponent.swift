//
//  MaterialTextComponent.swift
//  MaterialTextView
//
//  Created by Mikhail Motyzhenkov on 07/05/2019.
//  Copyright © 2019 QIWI. All rights reserved.
//

import Foundation
import FormattableTextView

public protocol MaterialTextComponent: class, UITextInput {
	var keyboardType: UIKeyboardType { get set }
	var keyboardAppearance: UIKeyboardAppearance { get set }
	var returnKeyType: UIReturnKeyType { get set }
	var autocapitalizationType: UITextAutocapitalizationType { get set }
	var autocorrectionType: UITextAutocorrectionType { get set }
	var inputAccessoryView: UIView? { get set }
}

internal protocol MaterialTextComponentInternal: MaterialTextComponent {
	var format: String? { get set }
	var maskAttributes: [NSAttributedString.Key: Any]! { get set }
	var inputAttributes: [NSAttributedString.Key: Any] { get set }
	var inputText: String { get set }
	var inputAttributedText: NSAttributedString { get set }
	var insetX: CGFloat { get set }
	var formatSymbols: [Character: CharacterSet] { get set }
	var typingAttributesInternal: [NSAttributedString.Key: Any] { get set }
}

extension FormattableKernTextView: MaterialTextComponentInternal {
	
	public var typingAttributesInternal: [NSAttributedString.Key : Any] {
		get { return typingAttributes }
		set { self.typingAttributes = newValue }
	}
	
	public var inputAttributedText: NSAttributedString {
		get { return attributedText }
		set { attributedText = newValue }
	}
	
	public var inputText: String {
		get { return self.attributedText.string }
		set { self.inputAttributedText = NSAttributedString(string: newValue, attributes: typingAttributes) }
	}
}

extension FormattableTextField: MaterialTextComponentInternal {
	
	public var typingAttributesInternal: [NSAttributedString.Key : Any] {
		get { return typingAttributes ?? [:] }
		set { self.typingAttributes = newValue }
	}
	
	public var inputAttributedText: NSAttributedString {
		get {
			if let attrText = attributedText {
				return attrText
			}
			let attrText = NSAttributedString(string: inputText, attributes: inputAttributes)
			self.attributedText = attrText
			return attrText
		}
		set { attributedText = newValue }
	}
	
	public var inputText: String {
		get { return self.inputAttributedText.string }
		set { self.inputAttributedText = NSAttributedString(string: newValue, attributes: typingAttributes) }
	}
}
