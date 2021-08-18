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
	internal var placeholderLayer = CATextLayer()
	internal var titleLabel = UILabel()
	internal var line = UIView()
	internal var shouldUpdate: Bool = true
	private let textFieldHeightOffset: CGFloat = 1
	private var attributedPlaceholder: NSAttributedString!
	private var hadInput: Bool = false
	
	internal var textViewToRightConstraint: NSLayoutConstraint!
	internal var textViewToRightButtonConstraint: NSLayoutConstraint!
	internal var textViewHeightConstraint: NSLayoutConstraint!
	internal var lineHeightConstraint: NSLayoutConstraint!
	private var helpLabelTopConstraint: NSLayoutConstraint!
	private var helpLabelBottomConstraint: NSLayoutConstraint!
	
	public var animationDuration: Double = 0.1
	internal var placeholderStartFrame = CGRect.zero

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
		updateFont()
		titleLabel.attributedText = NSAttributedString(string: newPlaceholder.text.nonEmpty,
													   attributes: titleLabel.attributedText?.safeAttributes(at: 0, range: nil) ?? [:])
		placeholderLayer.string = newPlaceholder.text
		changeTextStates(placeholderTypeIsChanged: typeIsChanged)
		updateAccessibilityLabelAndIdentifier()
		updatePlaceholderPosition()
		stateChanged(placeholderTypeIsChanged: true)
	}
	
	private func updateFont() {
		if let font = style.textAttributes[.font] as? UIFont {
			if !(placeholderLayer.font is String) {
				placeholderLayer.uiFont = font
			}
			
			titleLabel.attributedText = NSAttributedString(string: (placeholderLayer.string as? String).nonEmpty,
														   attributes:
			[
				NSAttributedString.Key.font: UIFont(descriptor: font.fontDescriptor, size: style.titleFontSize),
				NSAttributedString.Key.foregroundColor: style.normalActive.titleColor
			])
		}
	}
	
	private func changeTextStates(placeholderTypeIsChanged: Bool) {
		var helpText = help
		
		switch errorState {
		case .error(let text):
			helpText = text
		default:
			break
		}
		
		helpChanged(newHelp: helpText)
		
		switch placeholder.type {
		case .animated:
			placeholderLayer.isHidden = false
			if let textFont = style.textAttributes[.font] as? UIFont {
				if isActive {
					let colorStyle = errorState.isError ? style.errorActive : style.normalActive
					guard CATransform3DEqualToTransform(placeholderLayer.transform, CATransform3DIdentity) else {
						placeholderLayer.animate(duration: animationDuration) { layer in
							layer.foregroundColor = colorStyle.titleColor.cgColor
						}
						break
					}
					let scale = style.titleFontSize/textFont.pointSize
					placeholderLayer.animate(animationDuration: animationDuration, newFrame: titleLabel.layer.frame, animationType: .scaleAndTranslate(scale: scale), newColor: colorStyle.titleColor.cgColor)
				} else {
					var newFrame: CGRect
					var animationType: CATextLayer.ScaleAnimationType
					var color: CGColor
					let colorStyle = errorState.isError ? style.errorInactive : style.normalInactive
					if text.isEmpty {
						newFrame = placeholderStartFrame
						animationType = .identity
						color = colorStyle.placeholderColor.cgColor
					} else {
						newFrame = titleLabel.layer.frame
						let scale = style.titleFontSize/textFont.pointSize
						animationType = placeholderTypeIsChanged || !hadInput ? .scaleAndTranslate(scale: scale) : .skip
						color = colorStyle.titleColor.cgColor
					}
					
					placeholderLayer.animate(animationDuration: animationDuration, newFrame: newFrame, animationType: animationType, newColor: color)
				}
			}
		case .normal:
			placeholderLayer.isHidden = !text.isEmpty
			placeholderLayer.animate(animationDuration: placeholderLayer.isHidden ? 0 : animationDuration, newFrame: placeholderStartFrame, animationType: .identity, newColor: visualState.placeholderColor.cgColor)
		case .alwaysOnTop:
			placeholderLayer.isHidden = true
			let attr = NSMutableAttributedString(attributedString: titleLabel.attributedText ?? NSAttributedString())
			attr.addAttributes([NSAttributedString.Key.foregroundColor: visualState.placeholderColor], range: NSRange(location: 0, length: attr.string.count))
			titleLabel.attributedText = attr
			titleLabel.isHidden = false
		}
		
		UIView.animate(withDuration: animationDuration, animations: {
			self.line.backgroundColor = self.visualState.lineColor
			self.lineHeightConstraint.constant = self.visualState.lineHeight
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
	public var style: Style {
		get {
			return _style
		}
		set {
			if _style == newValue { return }
			_style = newValue
			didUpdateStyle()
		}
	}
	
	private func didUpdateStyle() {
		styleChanged()
		updateTintColor()
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
			textComponentModeChanged()
		}
	}
	
	private func maskAttributesChanged(newAttributes: [NSAttributedString.Key : Any]) {
		self.textComponentInternal.maskAttributes = newAttributes
	}
	
	private func formatSymbolsChanged(formatSymbols: [Character : CharacterSet]) {
		self.textComponentInternal.formatSymbols = formatSymbols
	}
	
	private func textComponentModeChanged() {
		replaceTextComponent()
		updateAccessibilityLabelAndIdentifier()
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
		var newStyle = _style
		if useTintColorForActiveLine {
			newStyle.normalActive.lineColor = tintColor
		}
		if useTintColorForActiveTitle {
			newStyle.normalActive.titleColor = tintColor
		}
		_style = newStyle
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
			formatSymbolsChanged(formatSymbols: newValue)
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
	public var inputValidator: Validator<String>?

	/// Результат последней валидации
	public var wasInputValid = true
	public var wasActionValid = false
	
	@objc private func rightButtonAction(_ sender: UIButton) {
		rightButtonInfo?.action?()
	}
	
	internal var currentFormat: String? {
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
		updateFont()
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
									 titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
									 titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)])
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
		
		makeLayout()
		placeholderLayer.contentsScale = UIScreen.main.scale
		layer.addSublayer(placeholderLayer)
		titleLabel.isHidden = true
		titleLabel.attributedText = NSAttributedString(string: " ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
		
		rightButton.addTarget(self, action: #selector(rightButtonAction(_:)), for: .touchUpInside)
		replaceTextComponent()
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
	
	fileprivate func updatePlaceholderPosition() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		placeholderStartFrame = textComponentInternal.frame
		let bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: rightButton.frame.origin.x, height: placeholderStartFrame.size.height))
		placeholderLayer.bounds = bounds
		placeholderLayer.position = CGPoint(x: placeholderLayer.bounds.width/2, y: placeholderStartFrame.midY)
		CATransaction.commit()
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()

		if textComponentMode == .textField {
			updatePlaceholderPosition()
		}
	}
}
