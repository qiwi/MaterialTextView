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
	internal var hadInput: Bool = false
	private let textFieldHeightOffset: CGFloat = 1
	private var attributedPlaceholder: NSAttributedString!
	private var isFirstInput: Bool = true
	
	internal var textViewToRightConstraint: NSLayoutConstraint!
	internal var textViewToRightButtonConstraint: NSLayoutConstraint!
	internal var textViewHeightConstraint: NSLayoutConstraint!
	internal var lineHeightConstraint: NSLayoutConstraint!
	private var helpLabelTopConstraint: NSLayoutConstraint!
	private var helpLabelBottomConstraint: NSLayoutConstraint!
	
	public var placeholderAnimationDuration: Double = 0.15
	public var lineAnimationDuration: Double = 0.1
	
	public var viewModel: MaterialTextViewModel = .init() {
		didSet {
			didSetViewModel()
		}
	}
	
	private func didSetViewModel() {
		setupViewModel()
		replaceTextComponent()
		styleChanged()
		viewModelRightButtonChanged(viewModel: self.viewModel)
		viewModel.validateInput()
	}
	
	private func placeholderChanged(newPlaceholder: MaterialTextViewModel.Placeholder, typeIsChanged: Bool, styleIsChanged: Bool) {
		if styleIsChanged {
			placeholderLabel.attributedText = NSAttributedString(string: newPlaceholder.text,
															 attributes: viewModel.style.placeholderAttributes)
			updateAccessibilityLabelAndIdentifier()
		}
		
		stateChanged(placeholderTypeIsChanged: true)
	}
	
	private func changeTextStates(placeholderTypeIsChanged: Bool) {
		let placeholder = self.viewModel.placeholder
		
		var helpText = viewModel.help
		var isError = false
		
		switch viewModel.errorState {
		case .error(let text):
			helpText = text
			isError = true
		default:
			break
		}
		
		helpChanged(newHelp: helpText)
		var animation: EmptyClosure?
		var placeholderAnimationDuration = self.placeholderAnimationDuration
		var attributes = [NSAttributedString.Key: Any]()
		let formattedText = self.formattedText
		
		switch placeholder.type {
		case .animated, .normal:
			if placeholder.type == .normal {
				self.titleLabel.alpha = 0
				placeholderAnimationDuration = 0
			}
			if viewModel.isActive {
				attributes = isError ? self.viewModel.style.errorActive.titleAttributes : self.viewModel.style.normalActive.titleAttributes
				animation = {
					if placeholder.type == .animated {
						self.titleLabel.alpha = 1
					}
					self.placeholderLabel.alpha = placeholder.type == .normal && formattedText.isEmpty && self.viewModel.text.isEmpty ? 1 : 0
					self.titleLabel.transform = .identity
					if placeholder.type == .animated && self.placeholderLabel.transform == .identity {
						self.placeholderLabel.transform = .init(sourceRect: self.placeholderLabel.frame, destinationRect: self.titleLabel.frame)
					}
				}
			} else {
				attributes = isError ? self.viewModel.style.errorInactive.titleAttributes : self.viewModel.style.normalInactive.titleAttributes
				
				animation = {
					self.titleLabel.alpha = placeholder.type == .animated && (!formattedText.isEmpty || !self.viewModel.text.isEmpty) ? 1 : 0
					self.placeholderLabel.alpha = formattedText.isEmpty && self.viewModel.text.isEmpty ? 1 : 0
					self.setNeedsLayout()
					self.layoutIfNeeded()
					if placeholder.type == .animated && formattedText.isEmpty && self.viewModel.text.isEmpty && self.titleLabel.bounds.width > 0 {
						self.placeholderLabel.transform = .identity
						self.titleLabel.transform = .init(sourceRect: self.titleLabel.frame, destinationRect: self.placeholderLabel.frame)
					} else {
						self.titleLabel.transform = .identity
					}
				}
			}
		case .alwaysOnTop:
			if viewModel.isActive {
				attributes = isError ? self.viewModel.style.errorActive.titleAttributes : self.viewModel.style.normalActive.titleAttributes
			} else {
				attributes = isError ? self.viewModel.style.errorInactive.titleAttributes : self.viewModel.style.normalInactive.titleAttributes
			}
			self.titleLabel.transform = .identity
			self.titleLabel.alpha = 1
			self.placeholderLabel.alpha = 0
			self.placeholderLabel.transform = .identity
		}
		self.titleLabel.attributedText = NSAttributedString(string: placeholder.text, attributes: attributes)
		UIView.animate(withDuration: hadInput ? placeholderAnimationDuration : 0) {
			animation?()
		}
		if hadInput {
			UIView.animate(withDuration: self.lineAnimationDuration) {
				self.changeLineStyle()
				self.layoutIfNeeded()
			}
		} else {
			self.changeLineStyle()
		}

		helpLabel.attributedText = NSAttributedString(string: helpText, attributes: viewModel.visualState.helpAttributes)
		updateAccessibilityValue()
	}
	
	private func changeLineStyle() {
		self.line.backgroundColor = self.viewModel.visualState.lineColor
		self.lineHeightConstraint.constant = self.viewModel.visualState.lineHeight
	}
	
	private func updateAccessibilityValue() {
		self.textComponentInternal.accessibilityValue = viewModel.text
	}
	
	private func updateAccessibilityLabelAndIdentifier() {
		let accessibilityLabel = viewModel.placeholder.text
		self.textComponentInternal.accessibilityLabel = accessibilityLabel
		let type = (textComponent is UITextField) ? "tf" : "tv"
		self.textComponentInternal.isAccessibilityElement = true
		
		let identifier = "\(type)_\(accessibilityLabel)"
		self.textComponentInternal.accessibilityIdentifier = identifier
		self.rightButton.accessibilityIdentifier = "\(identifier)_button"
		self.helpLabel.accessibilityIdentifier = "\(identifier)_help"
	}
	
	public var maskAppearance: MaskAppearance {
		get {
			textComponentInternal.maskAppearance
		}
		set {
			textComponentInternal.maskAppearance = newValue
		}
	}
	
	internal var formattedText: String {
		textComponent.formattedText
	}
	
	internal func helpChanged(newHelp: String) {
		helpLabel.attributedText = NSAttributedString(string: newHelp, attributes: viewModel.visualState.helpAttributes)
		self.layoutIfNeeded()
	}
	
	public var maskAttributes: [NSAttributedString.Key: Any] {
		get {
			textComponentInternal.maskAttributes
		}
		set {
			textComponentInternal.maskAttributes = newValue
		}
	}
	
	private func rightButtonChanged() {
		if let info = viewModel.rightButtonInfo {
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
	
	@objc private func rightButtonAction(_ sender: UIButton) {
		viewModel.rightButtonInfo?.action?()
	}
	
	internal var currentFormat: String? {
		textComponentInternal.currentFormat
	}
	
	internal func updateAttributedText() {
		self.shouldUpdate = false
		textComponentInternal.inputAttributes = viewModel.style.textAttributes
		textComponentInternal.maskAttributes = textComponentInternal.inputAttributes
		self.shouldUpdate = true
		
		if textComponentInternal.inputText != viewModel.text {
			textComponentInternal.inputText = viewModel.text
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
		setupViewModel()
		customInit()
		updateAttributedText()
		styleChanged()
		viewModelRightButtonChanged(viewModel: self.viewModel)
	}
	
	public convenience init(_ viewModel: MaterialTextViewModel = .init()) {
		self.init(frame: CGRect.zero)
		if self.viewModel != viewModel {
			self.viewModel = viewModel
			self.didSetViewModel()
		}
	}
	
	private func updateAttributes() {
		if shouldUpdate {
			updateAttributedText()
		}
		updateTextViewHeight()
	}
	
	private func styleChanged() {
		updateAttributedText()
		placeholderChanged(newPlaceholder: viewModel.placeholder, typeIsChanged: false, styleIsChanged: true)
	}
	
	private func formatsChanged(formats: [String]) {
		textComponentInternal.formats = formats
	}
	
	internal func stateChanged(placeholderTypeIsChanged: Bool) {
		updateTextViewHeight()
		changeTextStates(placeholderTypeIsChanged: placeholderTypeIsChanged)
		
		if viewModel.isActive && !textComponentInternal.isFirstResponder {
			textComponentInternal.becomeFirstResponder()
		} else if !viewModel.isActive && textComponent.isFirstResponder {
			textComponentInternal.resignFirstResponder()
		}
	}
	
	private func updateTextViewHeight() {
		let attributedText = getAttributedText()
		let size = attributedText.boundingRect(with: CGSize(width: textComponent.bounds.width, height: CGFloat.infinity), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
		let para = viewModel.style.textAttributes[.paragraphStyle] as? NSParagraphStyle ?? NSParagraphStyle.materialTextViewDefault
		let lineHeight = para.minimumLineHeight + para.lineSpacing
		if viewModel.textComponentMode == .textField {
			self.textViewHeightConstraint.constant = lineHeight+1
		} else {
			self.textViewHeightConstraint.constant = max(min(size.height, lineHeight * viewModel.maxNumberOfLinesWithoutScrolling - lineHeight/6), lineHeight)
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
		let text = self.currentFormat == nil ? textComponentInternal.inputText : viewModel.text
		var attributedText: NSAttributedString
		if text.isEmpty {
			attributedText = NSAttributedString(string: " ", attributes: viewModel.style.textAttributes)
		} else {
			attributedText = self.currentFormat == nil ? textComponentInternal.inputAttributedText : NSAttributedString(string: text, attributes: viewModel.style.textAttributes)
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
		textViewHeightConstraint = textComponentInternal.heightAnchor.constraint(equalToConstant: 44)

		NSLayoutConstraint.activate([textComponentInternal.leadingAnchor.constraint(equalTo: self.leadingAnchor),
									 textViewToRightConstraint,
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
		
		titleLabel.attributedText = NSAttributedString(string: viewModel.placeholder.text,
													   attributes: viewModel.style.normalInactive.titleAttributes)
		placeholderLabel.attributedText = NSAttributedString(string: viewModel.placeholder.text,
															 attributes: viewModel.style.placeholderAttributes)
		makeLayout()
		
		rightButton.addTarget(self, action: #selector(rightButtonAction(_:)), for: .touchUpInside)
		replaceTextComponent()
	}
	
	internal func replaceTextComponent() {
		if textComponentInternal != nil {
			textComponentInternal.removeFromSuperview()
		}
		
		switch viewModel.textComponentMode {
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
		let text = self.viewModel.text
		textComponentInternal.formatSymbols = viewModel.formatSymbols
		textComponentInternal.formats = viewModel.formats
		self.viewModel.text = text
		updateAttributes()
	}
	
    @discardableResult
	override public func becomeFirstResponder() -> Bool {
		return textComponentInternal.becomeFirstResponder()
	}
}

extension MaterialTextView: MaterialTextViewProtocol {
	
	public func viewModelTextChanged(viewModel: MaterialTextViewModel) {
		updateAccessibilityValue()
		updateAttributes()
		placeholderChanged(newPlaceholder: viewModel.placeholder, typeIsChanged: false, styleIsChanged: false)
	}
	
	public func viewModelHelpChanged(viewModel: MaterialTextViewModel) {
		helpChanged(newHelp: viewModel.help)
	}
	
	public func viewModelStateChanged(viewModel: MaterialTextViewModel, placeholderTypeIsChanged: Bool) {
		stateChanged(placeholderTypeIsChanged: placeholderTypeIsChanged)
	}
	
	public func viewModelPlaceholderChanged(viewModel: MaterialTextViewModel, typeIsChanged: Bool) {
		placeholderChanged(newPlaceholder: viewModel.placeholder, typeIsChanged: typeIsChanged, styleIsChanged: true)
	}
	
	public func viewModelStyleChanged(viewModel: MaterialTextViewModel) {
		styleChanged()
	}
	
	public func viewModelFormatSymbolsChanged(viewModel: MaterialTextViewModel) {
		textComponentInternal.formatSymbols = viewModel.formatSymbols
	}
	
	public func viewModelFormatsChanged(viewModel: MaterialTextViewModel) {
		formatsChanged(formats: viewModel.formats)
	}
	
	public func viewModelTextComponentModeChanged(viewModel: MaterialTextViewModel) {
		replaceTextComponent()
		updateAccessibilityLabelAndIdentifier()
	}
	
	public func viewModelRightButtonChanged(viewModel: MaterialTextViewModel) {
		rightButtonChanged()
		updateAccessibilityLabelAndIdentifier()
	}
}
