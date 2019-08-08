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
public final class MaterialTextView: UIView, MaterialTextViewProtocol {
	
	public weak var delegate: MaterialTextViewDelegate?
	
	private var textComponentInternal: (MaterialTextComponentInternal & UIView)!
	public var textComponent: MaterialTextComponent & UIView {
		get {
			return textComponentInternal
		}
	}
	
	public var helpLabel = UILabel()
	private let textFieldHeightOffset: CGFloat = 1
	private var line = UIView()
	private var titleLabel = UILabel()
	private var attributedPlaceholder: NSAttributedString!
	private var rightButton = UIButton(type: .system)
	private var placeholderLayer = CATextLayer()
	
	private var helpLabelTopConstraint: NSLayoutConstraint!
	private var helpLabelBottomConstraint: NSLayoutConstraint!
	private var textViewHeightConstraint: NSLayoutConstraint!
	private var lineHeightConstraint: NSLayoutConstraint!
	private var textViewToRightButtonConstraint: NSLayoutConstraint!
	private var textViewToRightConstraint: NSLayoutConstraint!
	
	public var animationDuration: Double = 0.1
	
	@objc private func rightButtonAction(_ sender: UIButton) {
		viewModel?.rightButtonInfo?.action?()
	}
	
	public var viewModel: MaterialTextViewModel? = nil {
		didSet {
			self.didSetViewModel(viewModel)
		}
	}
	
	private func updateTextViewAttributedText(_ viewModel: MaterialTextViewModel) {
		if textComponentInternal.inputText != viewModel.text {
			textComponentInternal.inputText = viewModel.text
			self.textComponentDidChange()
			textComponentInternal.inputAttributes = viewModel.style.textAttributes
			textComponentInternal.maskAttributes = textComponentInternal.inputAttributes
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
		let viewModel = MaterialTextViewModel()
		self.viewModel = viewModel
		updateTextViewAttributedText(viewModel)
	}
	
	public convenience init(viewModel: MaterialTextViewModel) {
		self.init(frame: CGRect.zero)
		self.viewModel = viewModel
		didSetViewModel(viewModel)
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
	}
	
	private var placeholderStartFrame = CGRect.zero
	private func updateFont() {
		if let style = viewModel?.style, let font = style.textAttributes[.font] as? UIFont {
			if !(placeholderLayer.font is String) {
				placeholderLayer.uiFont = font
				titleLabel.attributedText = NSAttributedString(string: (placeholderLayer.string as? String).nonEmpty, attributes: [NSAttributedString.Key.font: UIFont(descriptor: font.fontDescriptor, size: style.titleFontSize)])
			}
		}
	}
	
	private func replaceTextComponent(_ viewModel: MaterialTextViewModel) {
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
		textComponentInternal.formatSymbols = viewModel.formatSymbols
		textComponentInternal.format = viewModel.format
		viewModelTextChanged(viewModel: viewModel)
		viewModelHelpChanged(newHelp: viewModel.help)
	}
	
	private func didSetViewModel(_ viewModel: MaterialTextViewModel?) {
		guard let viewModel = viewModel else { return }
		self.setupViewModel()
		
		replaceTextComponent(viewModel)
		
		placeholderLayer.foregroundColor = viewModel.style.normalInactive.titleColor.cgColor
		self.line.backgroundColor = viewModel.style.normalInactive.lineColor
		self.setNeedsLayout()
		self.layoutIfNeeded()
		
		viewModelPlaceholderChanged(newPlaceholder: viewModel.placeholder, typeIsChanged: false)
		updateTextViewAttributedText(viewModel)
		
		viewModelRightButtonChanged(viewModel: viewModel)
		updatePlaceholderPosition()
		viewModelStateChanged(viewModel: viewModel, placeholderTypeIsChanged: true)
	}
	
	private func hideRightButton() {
		rightButton.isHidden = true
		textViewToRightButtonConstraint.isActive = false
		textViewToRightConstraint.isActive = true
	}
	
	private func showRightButton() {
		rightButton.isHidden = false
		textViewToRightConstraint.isActive = false
		textViewToRightButtonConstraint.isActive = true
	}
	
	override public func becomeFirstResponder() -> Bool {
		return textComponentInternal.becomeFirstResponder()
	}
	
	private func getAttributedText(viewModel: MaterialTextViewModel) -> NSAttributedString {
		var attributedText = textComponentInternal.inputAttributedText
		if textComponentInternal.inputText.isEmpty {
			attributedText = NSAttributedString(string: " ", attributes: viewModel.style.textAttributes)
		}
		return attributedText
	}
	
	private func updateTextViewHeight(viewModel: MaterialTextViewModel) {
		let attributedText = getAttributedText(viewModel: viewModel)
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

		if let viewModel = viewModel, viewModel.textComponentMode == .textField {
			updatePlaceholderPosition()
		}
	}
}

extension MaterialTextView: MaterialTextViewModelDelegate {
	
	public func viewModelFormatChanged(format: String?) {
		textComponentInternal.format = format
	}
	
	public func viewModelRightButtonChanged(viewModel: MaterialTextViewModel) {
		if let info = viewModel.rightButtonInfo {
			rightButton.setImage(UIImage(named: info.imageName), for: .normal)
			showRightButton()
		} else {
			hideRightButton()
		}
	}
	
	public func viewModelStateChanged(viewModel: MaterialTextViewModel, placeholderTypeIsChanged: Bool) {
		updateTextViewHeight(viewModel: viewModel)
		changeTextStates(placeholderTypeIsChanged: placeholderTypeIsChanged)
		
		if viewModel.isActive && !textComponentInternal.isFirstResponder {
			textComponentInternal.becomeFirstResponder()
		} else if !viewModel.isActive && textComponent.isFirstResponder {
			textComponentInternal.resignFirstResponder()
		}
	}
	
	public func viewModelTextChanged(viewModel: MaterialTextViewModel) {
		updateTextViewAttributedText(viewModel)
		updateTextViewHeight(viewModel: viewModel)
		updateAccessibilityValue()
	}
	
	public func viewModelStyleChanged() {
		guard let viewModel = viewModel else { return }
		updateTextViewAttributedText(viewModel)
		updateFont()
		viewModelStateChanged(viewModel: viewModel, placeholderTypeIsChanged: false)
		viewModelPlaceholderChanged(newPlaceholder: viewModel.placeholder, typeIsChanged: false)
	}
	
	public func viewModelMaskAttributesChanged(newAttributes: [NSAttributedString.Key : Any]) {
		self.textComponentInternal.maskAttributes = newAttributes
	}
	
	public func viewModelHelpChanged(newHelp: String) {
		if !(viewModel?.errorState.isError ?? true) {
			viewModelHelpChangedInternal(newHelp: newHelp)
		}
	}
	
	public func viewModelFormatSymbolsChanged(formatSymbols: [Character : CharacterSet]) {
		self.textComponentInternal.formatSymbols = formatSymbols
	}
	
	public func viewModelTextComponentModeChanged(viewModel: MaterialTextViewModel) {
		replaceTextComponent(viewModel)
		updateAccessibilityLabelAndIdentifier()
	}
	
	private func viewModelHelpChangedInternal(newHelp: String) {
		guard let attributes = viewModel?.visualState.helpAttributes else { return }
		helpLabel.attributedText = NSAttributedString(string: newHelp, attributes: attributes)
		self.layoutIfNeeded()
	}
	
	public func viewModelPlaceholderChanged(newPlaceholder: MaterialTextViewModel.Placeholder, typeIsChanged: Bool) {
		updateFont()
		titleLabel.attributedText = NSAttributedString(string: newPlaceholder.text.nonEmpty,
													   attributes: titleLabel.attributedText?.safeAttributes(at: 0, range: nil) ?? [:])
		placeholderLayer.string = newPlaceholder.text
		changeTextStates(placeholderTypeIsChanged: typeIsChanged)
		updateAccessibilityLabelAndIdentifier()
	}
	
	private func updateAccessibilityLabelAndIdentifier() {
		let accessibilityLabel = viewModel?.placeholder.text ?? ""
		self.textComponentInternal.accessibilityLabel = accessibilityLabel
		let type = (textComponent is UITextField) ? "tf" : "tv"
		self.textComponentInternal.isAccessibilityElement = true
		
		let identifier = "\(type)_\(accessibilityLabel)"
		self.textComponentInternal.accessibilityIdentifier = identifier
		self.rightButton.accessibilityIdentifier = "\(identifier)_button"
		self.helpLabel.accessibilityIdentifier = "\(identifier)_help"
	}
	
	private func updateAccessibilityValue() {
		self.textComponentInternal.accessibilityValue = "\(viewModel?.text ?? "")"
	}
	
	private func changeTextStates(placeholderTypeIsChanged: Bool) {
		guard let viewModel = viewModel else { return }
		var helpText = viewModel.help
		
		switch viewModel.errorState {
		case .error(let text):
			helpText = text
		default:
			break
		}
		
		viewModelHelpChangedInternal(newHelp: helpText)
		
		switch viewModel.placeholder.type {
		case .animated:
			placeholderLayer.isHidden = false
			if let textFont = viewModel.style.textAttributes[.font] as? UIFont {
				if viewModel.isActive {
					let colorStyle = viewModel.errorState.isError ? viewModel.style.errorActive : viewModel.style.normalActive
					guard CATransform3DEqualToTransform(placeholderLayer.transform, CATransform3DIdentity) else {
						placeholderLayer.animate(duration: animationDuration) { layer in
							layer.foregroundColor = colorStyle.titleColor.cgColor
						}
						break
					}
					let scale = viewModel.style.titleFontSize/textFont.pointSize
					placeholderLayer.animate(animationDuration: animationDuration, newFrame: titleLabel.layer.frame, animationType: .scaleAndTranslate(scale: scale), newColor: colorStyle.titleColor.cgColor)
				} else {
					var newFrame: CGRect
					var animationType: CATextLayer.ScaleAnimationType
					var color: CGColor
					let colorStyle = viewModel.errorState.isError ? viewModel.style.errorInactive : viewModel.style.normalInactive
					if viewModel.text.isEmpty {
						newFrame = placeholderStartFrame
						animationType = .identity
						color = colorStyle.placeholderColor.cgColor
					} else {
						newFrame = titleLabel.layer.frame
						let scale = viewModel.style.titleFontSize/textFont.pointSize
						animationType = placeholderTypeIsChanged ? .scaleAndTranslate(scale: scale) : .skip
						color = colorStyle.titleColor.cgColor
					}
					
					placeholderLayer.animate(animationDuration: animationDuration, newFrame: newFrame, animationType: animationType, newColor: color)
				}
			}
		case .normal:
			placeholderLayer.isHidden = !viewModel.text.isEmpty
			placeholderLayer.animate(animationDuration: placeholderLayer.isHidden ? 0 : animationDuration, newFrame: placeholderStartFrame, animationType: .identity, newColor: viewModel.visualState.placeholderColor.cgColor)
		case .alwaysOnTop:
			placeholderLayer.isHidden = false
			if let textFont = viewModel.style.textAttributes[.font] as? UIFont {
				let newFrame = titleLabel.layer.frame
				let scale = viewModel.style.titleFontSize/textFont.pointSize
				let animationType: CATextLayer.ScaleAnimationType = placeholderTypeIsChanged ? .scaleAndTranslate(scale: scale) : .skip
				let colorStyle = viewModel.errorState.isError ? viewModel.style.errorInactive : viewModel.style.normalInactive
				let color = colorStyle.titleColor.cgColor
				placeholderLayer.animate(animationDuration: animationDuration, newFrame: newFrame, animationType: animationType, newColor: color)
			}
		}
		
		UIView.animate(withDuration: animationDuration, animations: {
			self.line.backgroundColor = viewModel.visualState.lineColor
			self.lineHeightConstraint.constant = viewModel.visualState.lineHeight
			self.layoutIfNeeded()
		})
		helpLabel.attributedText = NSAttributedString(string: helpText, attributes: viewModel.visualState.helpAttributes)
		updateAccessibilityValue()
	}
}

extension MaterialTextView {
	@objc func textComponentDidChange() {
		guard let viewModel = viewModel else { return }
		if viewModel.text != textComponentInternal.inputText {
			viewModel.text = textComponentInternal.inputText
			delegate?.materialTextViewDidChange(self)
		}
	}
	
	func textComponent(shouldChangeCharactersIn range: NSRange, replacementText text: String) -> Bool {
		if let delegate = delegate {
			let result = delegate.materialTextView(self, shouldChangeTextIn: range, replacementText: text)
			if !result { return false }
		}
		return true
	}
	
	func textComponentDidEndEditing() {
		viewModel?.isActive = false
		delegate?.materialTextViewDidEndEditing(self)
	}
	
	func textComponentDidBeginEditing() {
		guard let viewModel = viewModel else { return }
		viewModel.isActive = true
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

public protocol MaterialTextViewDelegate: class {
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
