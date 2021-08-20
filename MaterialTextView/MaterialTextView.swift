//
//  MaterialTextView.swift
//  QIWIWallet
//
//  Created by Mikhail Motyzhenkov on 23/04/2018.
//  Copyright © 2018 QIWI. All rights reserved.
//

import Foundation
import UIKit
import FormattableTextView

@IBDesignable
public final class MaterialTextView: UIView {
	
	public weak var delegate: MaterialTextViewDelegate?
	
	internal var textComponentInternal: (MaterialTextComponentInternal & UIView)!
	public var textComponent: MaterialTextComponent & UIView {
		get {
			return textComponentInternal
		}
	}
	
	public var helpLabel = UILabel()
	internal var rightButton = UIButton(type: .system)
	internal var placeholderLabel = UILabel()
	internal var titleLabel = UILabel()
	internal var line = UIView()
	internal var shouldUpdate: Bool = true
	private let textFieldHeightOffset: CGFloat = 1
	private var attributedPlaceholder: NSAttributedString!
	private var hadInput: Bool = false
	private var isFirstInput: Bool = true
	
	internal var textViewToRightConstraint: NSLayoutConstraint!
	internal var textViewToRightButtonConstraint: NSLayoutConstraint!
	internal var textViewHeightConstraint: NSLayoutConstraint!
	internal var lineHeightConstraint: NSLayoutConstraint!
	private var helpLabelTopConstraint: NSLayoutConstraint!
	private var helpLabelBottomConstraint: NSLayoutConstraint!
	
	public var textDidChange: EmptyClosure? = { }
	public var didBeginEditing: EmptyClosure? = { }
	public var didEndEditing: EmptyClosure? = { }
	public var shouldChangeText: ((NSRange, String) -> Bool)? = { _, _ in return true}
	
	public var animationDuration: Double = 1

	private var _placeholder: Placeholder = .init(type: .animated, text: "")
	public var placeholder: Placeholder {
		get { return _placeholder }
		set {
			if _placeholder == newValue { return }
			let oldPlaceholder = _placeholder
			_placeholder = newValue
			placeholderChanged(newPlaceholder: placeholder, typeIsChanged: newValue.type != oldPlaceholder.type)
		}
	}
	
	private func placeholderChanged(newPlaceholder: Placeholder, typeIsChanged: Bool) {
		placeholderLabel.attributedText = NSAttributedString(string: placeholder.text,
															 attributes: style.placeholderAttributes)
		updateAccessibilityLabelAndIdentifier()
		stateChanged(placeholderTypeIsChanged: true)
	}
	
	private func changeTextStates(placeholderTypeIsChanged: Bool) {
		var helpText = help
		var isError = false
		
		switch errorState {
		case .error(let text):
			helpText = text
			isError = true
		default:
			break
		}
		
		helpChanged(newHelp: helpText)
		var animation: EmptyClosure?
		
		switch placeholder.type {
		case .animated, .normal:
			if isActive {
				self.titleLabel.attributedText = NSAttributedString(string: self.placeholder.text,
																	attributes: isError ? self.style.errorActive.titleAttributes : self.style.normalActive.titleAttributes)
//				if self.placeholder.type == .animated && self.text.isEmpty && self.titleLabel.transform == .identity && isFirstInput {
//					isFirstInput = false
//					self.titleLabel.transform = .init(sourceRect: self.titleLabel.frame, destinationRect: self.placeholderLabel.frame)
//				}
				animation = {
					self.titleLabel.alpha = self.placeholder.type == .animated ? 1 : 0
					self.placeholderLabel.alpha = self.placeholder.type == .normal && self.text.isEmpty ? 1 : 0
//					if self.placeholder.type == .animated && self.placeholderLabel.bounds.width > 0 {
//						if self.titleLabel.transform != .identity {
							self.titleLabel.transform = .identity
//						}
//						if self.placeholderLabel.transform == .identity {
							self.placeholderLabel.transform = .init(sourceRect: self.placeholderLabel.frame, destinationRect: self.titleLabel.frame)
//						}
//					}
				}
			} else {
				self.titleLabel.attributedText = NSAttributedString(string: self.placeholder.text,
																	attributes: isError ? self.style.errorInactive.titleAttributes : self.style.normalInactive.titleAttributes)
//				if self.placeholder.type == .animated && self.text.isEmpty && self.titleLabel.bounds.width > 0 {
//					if self.titleLabel.transform != .identity {
//						self.titleLabel.transform = .identity
//					}
//					if self.placeholderLabel.transform == .identity {
//						self.placeholderLabel.transform = .init(sourceRect: self.placeholderLabel.frame, destinationRect: self.titleLabel.frame)
//					}
//				}
				animation = {
					self.titleLabel.alpha = self.placeholder.type == .animated && !self.text.isEmpty ? 1 : 0
					self.placeholderLabel.alpha = self.text.isEmpty ? 1 : 0
					if self.placeholder.type == .animated && self.text.isEmpty && self.titleLabel.bounds.width > 0 {
						self.placeholderLabel.transform = .identity
						self.titleLabel.transform = .init(sourceRect: self.titleLabel.frame, destinationRect: self.placeholderLabel.frame)
					}
				}
			}
		case .alwaysOnTop:
			var attributes: [NSAttributedString.Key : Any]
			if isActive {
				attributes = isError ? self.style.errorActive.titleAttributes : self.style.normalActive.titleAttributes
			} else {
				attributes = isError ? self.style.errorInactive.titleAttributes : self.style.normalInactive.titleAttributes
			}
			self.titleLabel.transform = .identity
			self.titleLabel.alpha = 1
			self.titleLabel.attributedText = NSAttributedString(string: self.placeholder.text,
																attributes: attributes)
			self.placeholderLabel.alpha = 0
			self.placeholderLabel.transform = .identity
		}
		let animationDuration = hadInput ? self.animationDuration : 0
		UIView.animate(withDuration: animationDuration, animations: {
			self.line.backgroundColor = self.visualState.lineColor
			self.lineHeightConstraint.constant = self.visualState.lineHeight
			animation?()
			self.layoutIfNeeded()
		})
		helpLabel.attributedText = NSAttributedString(string: helpText, attributes: visualState.helpAttributes)
		updateAccessibilityValue()
	}
	
	private func updateAccessibilityValue() {
		self.textComponentInternal.accessibilityValue = text
	}
	
	private func updateAccessibilityLabelAndIdentifier() {
		let accessibilityLabel = placeholder.text
		self.textComponentInternal.accessibilityLabel = accessibilityLabel
		let type = (textComponent is UITextField) ? "tf" : "tv"
		self.textComponentInternal.isAccessibilityElement = true
		
		let identifier = "\(type)_\(accessibilityLabel)"
		self.textComponentInternal.accessibilityIdentifier = identifier
		self.rightButton.accessibilityIdentifier = "\(identifier)_button"
		self.helpLabel.accessibilityIdentifier = "\(identifier)_help"
	}
	
	private var _style: Style = .defaultStyle
	private var _styleWithoutTintColor: Style = .defaultStyle
	public var style: Style {
		get {
			return _style
		}
		set {
			if _style == newValue { return }
			_style = newValue
			_styleWithoutTintColor = newValue
			didUpdateStyle()
		}
	}
	
	private func didUpdateStyle() {
		styleChanged()
		updateTintColor()
	}
	
	public var maskAppearance: MaskAppearance {
		get {
			textComponentInternal.maskAppearance
		}
		set {
			textComponentInternal.maskAppearance = newValue
		}
	}
	
	public var maxNumberOfLinesWithoutScrolling: CGFloat = 3

	private var _text: String = ""
	public var text: String {
		get {
			return _text
		}
		set {
			if _text == newValue { return }
			let oldValue = _text
			_text = newValue
			if let inputValidator = inputValidator {
				errorState = self.validate(validator: inputValidator)
			}
			wasInputValid = !errorState.isError
			if oldValue.isEmpty || newValue.isEmpty {
				stateChanged(placeholderTypeIsChanged: placeholder.type != .alwaysOnTop)
			}
			textChanged()
		}
	}

	public var help: String = "" {
		didSet {
			if !errorState.isError {
				helpChanged(newHelp: help)
			}
		}
	}
	
	internal func helpChanged(newHelp: String) {
		helpLabel.attributedText = NSAttributedString(string: newHelp, attributes: visualState.helpAttributes)
		self.layoutIfNeeded()
	}
	
	private var _textComponentMode: TextComponentMode = .textField
	public var textComponentMode: TextComponentMode {
		get { return _textComponentMode }
		set {
			if _textComponentMode == newValue { return }
			_textComponentMode = newValue
			replaceTextComponent()
			updateAccessibilityLabelAndIdentifier()
			stateChanged(placeholderTypeIsChanged: true)
		}
	}
	
	public var maskAttributes: [NSAttributedString.Key: Any] {
		get {
			textComponentInternal.maskAttributes
		}
		set {
			textComponentInternal.maskAttributes = newValue
		}
	}
	
	public var rightButtonInfo: ButtonInfo? {
		didSet {
			rightButtonChanged()
		}
	}
	
	private func rightButtonChanged() {
		if let info = rightButtonInfo {
			rightButton.setImage(UIImage(named: info.imageName), for: .normal)
			showRightButton()
		} else {
			hideRightButton()
		}
	}
	
	private func showRightButton() {
		rightButton.isHidden = false
		textViewToRightConstraint.isActive = false
		textViewToRightButtonConstraint.isActive = true
	}
	
	private func hideRightButton() {
		rightButton.isHidden = true
		textViewToRightButtonConstraint.isActive = false
		textViewToRightConstraint.isActive = true
	}
	
	public var formats: [String] = [] {
		didSet {
			formatsChanged(formats: formats)
		}
	}
	
	public var useTintColorForActiveLine = true
	public var useTintColorForActiveTitle = true
	
	private func updateTintColor() {
		if useTintColorForActiveLine {
			_style.normalActive.lineColor = tintColor
		} else {
			_style.normalActive.lineColor = _styleWithoutTintColor.normalActive.lineColor
		}
		
		if useTintColorForActiveTitle {
			_style.normalActive.titleAttributes[.foregroundColor] = tintColor
		} else {
			_style.normalActive.titleAttributes[.foregroundColor] = _styleWithoutTintColor.normalActive.titleAttributes
		}
	}
	
	public enum TextComponentMode {
		case textField
		case textView
	}
	
	private var _formatSymbols: [Character: CharacterSet] = ["d": CharacterSet.decimalDigits,
															 "w": CharacterSet.letters,
															 "*": CharacterSet.init(charactersIn: "").inverted]
	public var formatSymbols: [Character: CharacterSet] {
		get {
			return _formatSymbols
		}
		set {
			if _formatSymbols == newValue { return }
			_formatSymbols = newValue
			textComponentInternal.formatSymbols = newValue
		}
	}
	
	public var isActive: Bool = false {
		didSet {
			if isActive {
				hadInput = true
			}
			stateChanged(placeholderTypeIsChanged: false)
		}
	}

	private var _errorState: ErrorState = .normal
	public var errorState: ErrorState {
		get {
			return _errorState
		}
		set {
			if _errorState != newValue {
				_errorState = newValue
				stateChanged(placeholderTypeIsChanged: false)
			}
		}
	}
	
	public var visualState: VisualState {
		switch errorState {
		case .normal:
			return isActive ? style.normalActive : style.normalInactive
		case .error(_):
			return isActive ? style.errorActive : style.errorInactive
		}
	}

	// Вызывается по validate()
	public var actionValidator: Validator<String>?
	// Вызывается при каждом изменении текста
	public var inputValidator: Validator<String>? {
		didSet {
			if let inputValidator = inputValidator {
				errorState = self.validate(validator: inputValidator)
			}
			wasInputValid = !errorState.isError
			stateChanged(placeholderTypeIsChanged: placeholder.type != .alwaysOnTop)
		}
	}

	/// Результат последней валидации
	public var wasInputValid = true
	public var wasActionValid = false
	
	@objc private func rightButtonAction(_ sender: UIButton) {
		rightButtonInfo?.action?()
	}
	
	public var currentFormat: String? {
		textComponentInternal.currentFormat
	}
	
	internal var formattedText: String? {
		textComponentInternal.formattedText
	}
	
	internal func updateAttributedText() {
		self.shouldUpdate = false
		textComponentInternal.inputAttributes = style.textAttributes
		textComponentInternal.maskAttributes = textComponentInternal.inputAttributes
		self.shouldUpdate = true
		
		if textComponentInternal.inputText != text {
			textComponentInternal.inputText = text
			self.textComponentDidChange()
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		defaultInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		defaultInit()
	}
	
	private func defaultInit() {
		customInit()
		updateAttributedText()
	}
	
	public convenience init() {
		self.init(frame: CGRect.zero)
	}
	
	private func textChanged() {
		updateAccessibilityValue()
		updateAttributes()
	}
	
	private func updateAttributes() {
		if shouldUpdate {
			updateAttributedText()
		}
		updateTextViewHeight()
	}
	
	private func styleChanged() {
		updateAttributedText()
		placeholderChanged(newPlaceholder: placeholder, typeIsChanged: false)
	}
	
	private func formatsChanged(formats: [String]) {
		textComponentInternal.formats = formats
	}
	
	internal func stateChanged(placeholderTypeIsChanged: Bool) {
		updateTextViewHeight()
		changeTextStates(placeholderTypeIsChanged: placeholderTypeIsChanged)
		
		if isActive && !textComponentInternal.isFirstResponder {
			textComponentInternal.becomeFirstResponder()
		} else if !isActive && textComponent.isFirstResponder {
			textComponentInternal.resignFirstResponder()
		}
	}
	
	private func updateTextViewHeight() {
		let attributedText = getAttributedText()
		let size = attributedText.boundingRect(with: CGSize(width: textComponent.bounds.width, height: CGFloat.infinity), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
		let para = style.textAttributes[.paragraphStyle] as? NSParagraphStyle ?? NSParagraphStyle.materialTextViewDefault
		let lineHeight = para.minimumLineHeight + para.lineSpacing
		if textComponentMode == .textField {
			self.textViewHeightConstraint.constant = lineHeight+1
		} else {
			self.textViewHeightConstraint.constant = max(min(size.height, lineHeight * maxNumberOfLinesWithoutScrolling - lineHeight/6), lineHeight)
		}
		
		self.superview?.layoutIfNeeded()
		
		if let textView = textComponentInternal as? UITextView, let selectedRange = textComponentInternal.selectedTextRange {
			let cursorPositionCurrent = textComponentInternal.offset(from: textComponentInternal.beginningOfDocument, to: selectedRange.start)
			let cursorPositionEnd = textComponentInternal.inputText.count
			if cursorPositionCurrent == cursorPositionEnd {
				textView.scrollRangeToVisible(NSRange(location: textComponentInternal.inputText.count-1, length: 1))
			}
		}
	}
	
	private func getAttributedText() -> NSAttributedString {
		let text = self.currentFormat == nil ? textComponentInternal.inputText : text
		var attributedText: NSAttributedString
		if text.isEmpty {
			attributedText = NSAttributedString(string: " ", attributes: style.textAttributes)
		} else {
			attributedText = self.currentFormat == nil ? textComponentInternal.inputAttributedText : NSAttributedString(string: text, attributes: style.textAttributes)
		}
		return attributedText
	}
	
	private func makeLayout() {
		[self, titleLabel, rightButton, line, helpLabel].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		addSubview(titleLabel)
		NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
									 titleLabel.topAnchor.constraint(equalTo: self.topAnchor)])
		titleLabel.setContentHuggingPriority(.init(249), for: .horizontal)
		titleLabel.setContentHuggingPriority(.init(249), for: .vertical)
		
		addSubview(rightButton)
		NSLayoutConstraint.activate([rightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8),
									 rightButton.widthAnchor.constraint(equalToConstant: 40),
									 rightButton.heightAnchor.constraint(equalToConstant: 40)])
		addSubview(line)
		lineHeightConstraint = line.heightAnchor.constraint(equalToConstant: 1)
		NSLayoutConstraint.activate([line.leadingAnchor.constraint(equalTo: self.leadingAnchor),
									 line.trailingAnchor.constraint(equalTo: self.trailingAnchor),
									 lineHeightConstraint])
		addSubview(helpLabel)
		helpLabelTopConstraint = helpLabel.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 8)
		helpLabelBottomConstraint = helpLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		NSLayoutConstraint.activate([helpLabelTopConstraint,
									 helpLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
									 helpLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
									 helpLabelBottomConstraint])
		helpLabel.setContentHuggingPriority(.init(251), for: .horizontal)
		helpLabel.setContentHuggingPriority(.init(251), for: .vertical)
		helpLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		
		placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
		insertSubview(placeholderLabel, at: 1)
		NSLayoutConstraint.activate([
			placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			placeholderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3)
		])
	}
	
	private func addTextComponent() {
		textComponentInternal.translatesAutoresizingMaskIntoConstraints = false
		insertSubview(textComponentInternal, at: 0)
		textViewToRightConstraint = textComponentInternal.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		textViewToRightConstraint.priority = .required
		let textViewBottom = textComponentInternal.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		textViewBottom.priority = .defaultHigh
		textViewHeightConstraint = textComponentInternal.heightAnchor.constraint(equalToConstant: 44)

		NSLayoutConstraint.activate([textComponentInternal.leadingAnchor.constraint(equalTo: self.leadingAnchor),
									 textViewToRightConstraint,
									 textViewBottom,
									 textViewHeightConstraint,
									 textComponentInternal.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3)])
		
		textViewToRightButtonConstraint = rightButton.leadingAnchor.constraint(equalTo: textComponentInternal.trailingAnchor)
		NSLayoutConstraint.activate([
			rightButton.centerYAnchor.constraint(equalTo: textComponentInternal.centerYAnchor),
			line.bottomAnchor.constraint(equalTo: textComponentInternal.bottomAnchor, constant: 6 - (textComponentInternal is UITextField ? textFieldHeightOffset : 0))
		])
	}
	
	private func customInit() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder))
		addGestureRecognizer(tapGesture)
		
		titleLabel.attributedText = NSAttributedString(string: placeholder.text,
													   attributes: style.normalInactive.titleAttributes)
		placeholderLabel.attributedText = NSAttributedString(string: placeholder.text,
															 attributes: style.placeholderAttributes)
		makeLayout()
		
		rightButton.addTarget(self, action: #selector(rightButtonAction(_:)), for: .touchUpInside)
		replaceTextComponent()
		
		placeholderChanged(newPlaceholder: self.placeholder, typeIsChanged: true)
	}
	
	internal func replaceTextComponent() {
		if textComponentInternal != nil {
			textComponentInternal.removeFromSuperview()
		}
		
		switch textComponentMode {
		case .textField:
			textComponentInternal = FormattableTextField()
			if let tf = textComponentInternal as? UITextField {
				tf.delegate = self
				tf.addTarget(self, action: #selector(textComponentDidChange), for: UIControl.Event.editingChanged)
			}
		case .textView:
			textComponentInternal = FormattableKernTextView(frame: .zero)
			if let tv = textComponentInternal as? UITextView {
				tv.delegate = self
				tv.textContainer.maximumNumberOfLines = 0
				tv.textContainer.lineBreakMode = .byWordWrapping
			}
		}
		textComponentInternal.insetX = 0
		addTextComponent()
		let text = self.text
		textComponentInternal.formatSymbols = formatSymbols
		textComponentInternal.formats = formats
		self.text = text
		updateAttributes()
		helpChanged(newHelp: help)
	}
	
    @discardableResult
	override public func becomeFirstResponder() -> Bool {
		return textComponentInternal.becomeFirstResponder()
	}
}
