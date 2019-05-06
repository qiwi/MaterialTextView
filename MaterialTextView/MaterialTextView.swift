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
	public let textView = FormattableKernTextView(frame: .zero)
	
	private var helpLabel = UILabel()
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
	
	@IBInspectable public var maxNumberOfLinesWithoutScrolling: CGFloat = 3
	@IBInspectable public var animationDuration: Double = 0.1
	
	@objc private func rightButtonAction(_ sender: UIButton) {
		viewModel?.rightButtonInfo?.action?()
	}
	
	public var viewModel: MaterialTextViewModel? = nil {
		didSet {
			self.didSetViewModel(viewModel)
		}
	}
	
	private var _style: Style!
	public var style: Style! {
		get {
			return _style
		}
		set {
			if _style == newValue { return }
			_style = newValue
			updateTintColor()
			guard let viewModel = viewModel else { return }
			updateTextViewAttributedText(text: viewModel.text)
			updateFont()
			viewModelStateChanged(isActive: viewModel.isActive, errorState: viewModel.errorState)
			viewModelPlaceholderChanged(newPlaceholder: viewModel.placeholder, isChanged: true)
			textView.maskAttributes = _style.textAttributes
		}
	}
	public var useTintColorForActiveLine = true
	public var useTintColorForActiveTitle = true
	
	private func updateTextViewAttributedText(text: String) {
		textView.attributedText = NSAttributedString(string: text, attributes: style.textAttributes)
		textView.delegate?.textViewDidChange?(textView)
		textView.inputAttributes = style.textAttributes
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
		updateTextViewAttributedText(text: viewModel.text)
	}
	
	public convenience init(viewModel: MaterialTextViewModel, style: Style = .defaultStyle, useTintColorForActiveLine: Bool = true, useTintColorForActiveTitle: Bool = true) {
		self.init(frame: CGRect.zero)
		self.useTintColorForActiveLine = useTintColorForActiveLine
		self.useTintColorForActiveTitle = useTintColorForActiveTitle
		self.style = style
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
		
		addSubview(textView)
		textViewToRightConstraint = textView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		textViewToRightConstraint.priority = .defaultHigh
		let textViewBottom = textView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		textViewBottom.priority = .defaultHigh
		textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 44)
		textViewHeightConstraint.priority = .required
		NSLayoutConstraint.activate([textView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
									 textViewToRightConstraint,
									 textViewBottom,
									 textViewHeightConstraint,
									 textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3)])
		textView.setContentHuggingPriority(.init(251), for: .horizontal)
		textView.setContentHuggingPriority(.init(251), for: .vertical)
		textView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		textView.setContentCompressionResistancePriority(.required, for: .vertical)
		
		addSubview(rightButton)
		textViewToRightButtonConstraint = rightButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor)
		NSLayoutConstraint.activate([rightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8),
									 rightButton.widthAnchor.constraint(equalToConstant: 40),
									 rightButton.heightAnchor.constraint(equalToConstant: 40),
									 rightButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor)])
		addSubview(line)
		lineHeightConstraint = line.heightAnchor.constraint(equalToConstant: 1)
		NSLayoutConstraint.activate([line.leadingAnchor.constraint(equalTo: self.leadingAnchor),
									 line.trailingAnchor.constraint(equalTo: self.trailingAnchor),
									 lineHeightConstraint,
									 line.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 6)])
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
	
	private func customInit() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder))
		addGestureRecognizer(tapGesture)
		
		textView.translatesAutoresizingMaskIntoConstraints = true
		textView.textContainerInset = UIEdgeInsets.zero
		textView.textContainer.lineFragmentPadding = 0
		textView.translatesAutoresizingMaskIntoConstraints = false
		makeLayout()
		placeholderLayer.contentsScale = UIScreen.main.scale
		layer.addSublayer(placeholderLayer)
		style = Style.defaultStyle
		textView.formatSymbols = ["d": CharacterSet.decimalDigits,
								  "w": CharacterSet.letters,
								  "*": CharacterSet.init(charactersIn: "").inverted]
		titleLabel.isHidden = true
		titleLabel.attributedText = NSAttributedString(string: " ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
		textView.inputAttributes = style.textAttributes
		textView.delegate = self
		textView.insetX = 0
		rightButton.addTarget(self, action: #selector(rightButtonAction(_:)), for: .touchUpInside)
	}
	
	private func updateTintColor() {
		var newStyle = _style!
		if useTintColorForActiveLine {
			newStyle.normalActive.lineColor = tintColor
		}
		if useTintColorForActiveTitle {
			newStyle.normalActive.titleColor = tintColor
		}
		_style = newStyle
	}
	
	private var placeholderStartFrame = CGRect.zero
	private func updateFont() {
		if let font = style.textAttributes[.font] as? UIFont {
			if !(placeholderLayer.font is String) {
				placeholderLayer.uiFont = font
				titleLabel.attributedText = NSAttributedString(string: (placeholderLayer.string as? String).nonEmpty, attributes: [NSAttributedString.Key.font: UIFont(descriptor: font.fontDescriptor, size: style.titleFontSize)])
			}
		}
	}
	
	private func updateLineMode(lineMode: MaterialTextViewModel.LineMode) {
		switch lineMode {
		case .single:
			textView.textContainer.maximumNumberOfLines = 1
			textView.textContainer.lineBreakMode = .byTruncatingTail
		case .multiple:
			textView.textContainer.maximumNumberOfLines = 0
			textView.textContainer.lineBreakMode = .byWordWrapping
		}
	}
	
	private func didSetViewModel(_ viewModel: MaterialTextViewModel?) {
		guard let viewModel = viewModel else { return }
		self.setupViewModel()
		textView.format = viewModel.format
		updateLineMode(lineMode: viewModel.lineMode)
		
		viewModelTextChanged(newText: viewModel.text)
		viewModelHelpChanged(newHelp: viewModel.help)
		
		placeholderLayer.foregroundColor = style.normalInactive.titleColor.cgColor
		self.line.backgroundColor = style.normalInactive.lineColor
		self.setNeedsLayout()
		self.layoutIfNeeded()
		
		viewModelPlaceholderChanged(newPlaceholder: viewModel.placeholder, isChanged: false)
		updateTextViewAttributedText(text: viewModel.text)
		
		if let info = viewModel.rightButtonInfo {
			rightButton.setImage(UIImage(named: info.imageName), for: .normal)
			showRightButton()
		} else {
			hideRightButton()
		}
	}
	
	private func hideRightButton() {
		rightButton.isHidden = true
		textViewToRightConstraint.isActive = true
		textViewToRightButtonConstraint.isActive = false
	}
	
	private func showRightButton() {
		rightButton.isHidden = false
		textViewToRightConstraint.isActive = false
		textViewToRightButtonConstraint.isActive = true
	}
	
	override public func becomeFirstResponder() -> Bool {
		return textView.becomeFirstResponder()
	}
	
	private func getAttributedText() -> NSAttributedString {
		var attributedText = textView.attributedText!
		if textView.text.isEmpty {
			attributedText = NSAttributedString(string: " ", attributes: style.textAttributes)
		}
		return attributedText
	}
	
	private func updateTextViewHeight() {
		let attributedText = getAttributedText()
		let size = attributedText.boundingRect(with: CGSize(width: textView.bounds.width, height: viewModel!.lineMode == .single ? textView.bounds.height : CGFloat.infinity), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
		let height = size.height
		let para = style.textAttributes[.paragraphStyle] as? NSParagraphStyle ?? NSParagraphStyle.materialTextViewDefault
		let lineHeight = para.minimumLineHeight + para.lineSpacing
		self.textViewHeightConstraint.constant = min(height, lineHeight * self.maxNumberOfLinesWithoutScrolling - lineHeight/6)
		
		self.superview?.layoutIfNeeded()

		if let selectedRange = textView.selectedTextRange {
			let cursorPositionCurrent = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
			let cursorPositionEnd = textView.text.count
			if cursorPositionCurrent == cursorPositionEnd {
				textView.scrollRangeToVisible(NSRange(location: textView.text.count-1, length: 1))
			}
		}
	}
	
	private func getVisualState() -> VisualState {
		guard let viewModel = viewModel else { return style.normalInactive }
		switch viewModel.errorState {
		case .normal:
			return viewModel.isActive ? style.normalActive : style.normalInactive
		case .error(_):
			return viewModel.isActive ? style.errorActive : style.errorInactive
		}
	}
}

extension MaterialTextView: MaterialTextViewModelDelegate {
	
	public func viewModelStateChanged(isActive: Bool, errorState: MaterialTextViewModel.ErrorState) {
		updateTextViewHeight()
		changeTextStates(placeholderIsChanged: false)
		
		if isActive && !textView.isFirstResponder {
			textView.becomeFirstResponder()
		} else if !isActive && textView.isFirstResponder {
			textView.resignFirstResponder()
		}
	}
	
	public func viewModelTextChanged(newText: String) {
		updateTextViewAttributedText(text: newText)
		updateTextViewHeight()
	}
	
	public func viewModelHelpChanged(newHelp: String) {
		if !(viewModel?.errorState.isError ?? true) {
			viewModelHelpChangedInternal(newHelp: newHelp)
		}
	}
	
	private func viewModelHelpChangedInternal(newHelp: String) {
		let attributes = getVisualState().helpAttributes
		helpLabel.attributedText = NSAttributedString(string: newHelp, attributes: attributes)
		self.layoutIfNeeded()
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		if let font = style.textAttributes[.font] as? UIFont {
			let numLines = (textView.contentSize.height / font.lineHeight)
			if round(numLines) == 1 {
				CATransaction.begin()
				CATransaction.setDisableActions(true)
				placeholderStartFrame = textView.frame
				placeholderLayer.bounds = CGRect(origin: CGPoint.zero, size: placeholderStartFrame.size)
				placeholderLayer.position = textView.layer.position
				CATransaction.commit()
			}
		}
	}
	
	public func viewModelLineModeChanged(newLineMode: MaterialTextViewModel.LineMode) {
		updateLineMode(lineMode: newLineMode)
	}
	
	public func viewModelPlaceholderChanged(newPlaceholder: MaterialTextViewModel.Placeholder, isChanged: Bool) {
		updateFont()
		titleLabel.attributedText = NSAttributedString(string: newPlaceholder.text.nonEmpty,
													   attributes: titleLabel.attributedText?.safeAttributes(at: 0, range: nil) ?? [:])
		placeholderLayer.string = newPlaceholder.text
		changeTextStates(placeholderIsChanged: isChanged)
	}
	
	
	private func changeTextStates(placeholderIsChanged: Bool) {
		let state = getVisualState()
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
			if let textFont = style.textAttributes[.font] as? UIFont {
				if viewModel.isActive {
					let colorStyle = viewModel.errorState.isError ? style.errorActive : style.normalActive
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
					let colorStyle = viewModel.errorState.isError ? style.errorInactive : style.normalInactive
					if viewModel.text.isEmpty {
						newFrame = placeholderStartFrame
						animationType = .identity
						color = colorStyle.placeholderColor.cgColor
					} else {
						newFrame = titleLabel.layer.frame
						let scale = style.titleFontSize/textFont.pointSize
						animationType = placeholderIsChanged ? .scaleAndTranslate(scale: scale) : .skip
						color = colorStyle.titleColor.cgColor
					}
					
					placeholderLayer.animate(animationDuration: animationDuration, newFrame: newFrame, animationType: animationType, newColor: color)
				}
			}
		case .normal:
			placeholderLayer.isHidden = !viewModel.text.isEmpty
			placeholderLayer.animate(animationDuration: placeholderLayer.isHidden ? 0 : animationDuration, newFrame: placeholderStartFrame, animationType: .identity, newColor: state.placeholderColor.cgColor)
		}
		
		UIView.animate(withDuration: animationDuration, animations: {
			self.line.backgroundColor = state.lineColor
			self.lineHeightConstraint.constant = state.lineHeight
			self.layoutIfNeeded()
		})
		helpLabel.attributedText = NSAttributedString(string: helpText, attributes: state.helpAttributes)
	}
}

extension MaterialTextView: UITextViewDelegate {
	
	public func textViewDidChange(_ textView: UITextView) {
		if viewModel?.text != textView.text {
			viewModel?.text = textView.text
			delegate?.materialTextViewDidChange(self)
		}
	}
	
	public func textViewDidBeginEditing(_ textView: UITextView) {
		viewModel?.isActive = true
		textView.typingAttributes = style.textAttributes
		delegate?.materialTextViewDidBeginEditing(self)
	}
	
	public func textViewDidEndEditing(_ textView: UITextView) {
		viewModel?.isActive = false
		delegate?.materialTextViewDidEndEditing(self)
	}
	
	public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		var finalText = text
		if let delegate = delegate {
			let (newText, result) = delegate.materialTextView(self, shouldChangeTextIn: range, replacementText: text)
			finalText = newText
			if !result { return false }
		}
		if let vm = viewModel {
			switch vm.lineMode {
			case .multiple:
				break
			case .single:
				if finalText.contains("\n") {
					return false
				}
			}
		}
		return true
	}
}

extension MaterialTextView {
	@IBInspectable public var keyboardTypeInt: Int {
		get {
			return self.textView.keyboardType.rawValue
		}
		set(value) {
			self.textView.keyboardType = UIKeyboardType(rawValue: value) ?? UIKeyboardType.default
		}
	}
}

extension MaterialTextView {
	
	public struct VisualState: Equatable {
		
		public static func == (lhs: MaterialTextView.VisualState, rhs: MaterialTextView.VisualState) -> Bool {
			return  lhs.lineHeight == rhs.lineHeight &&
					lhs.lineColor == rhs.lineColor &&
					lhs.placeholderColor == rhs.placeholderColor &&
					lhs.titleColor == rhs.titleColor &&
			areAttributesEqual(lhs.helpAttributes, rhs.helpAttributes)
		}
		
		public var helpAttributes: [NSAttributedString.Key: Any]
		public var titleColor: UIColor
		public var placeholderColor: UIColor
		public var lineColor: UIColor
		public var lineHeight: CGFloat
		
		public init(helpAttributes: [NSAttributedString.Key: Any], titleColor: UIColor, placeholderColor: UIColor, lineColor: UIColor, lineHeight: CGFloat) {
			self.helpAttributes = helpAttributes
			self.titleColor = titleColor
			self.placeholderColor = placeholderColor
			self.lineColor = lineColor
			self.lineHeight = lineHeight
		}
	}
	
	public struct Style: Equatable {
		
		public static func == (lhs: MaterialTextView.Style, rhs: MaterialTextView.Style) -> Bool {
			return lhs.normalActive == rhs.normalActive &&
				lhs.normalInactive == rhs.normalInactive &&
				lhs.errorActive == rhs.errorActive &&
				lhs.errorInactive == rhs.errorInactive &&
				lhs.titleFontSize == rhs.titleFontSize &&
				areAttributesEqual(lhs.textAttributes, rhs.textAttributes)
		}
		
		public var normalActive: VisualState
		public var normalInactive: VisualState
		public var errorActive: VisualState
		public var errorInactive: VisualState
		public var textAttributes: [NSAttributedString.Key: Any]
		public var titleFontSize: CGFloat
		
		public init(normalActive: VisualState, normalInactive: VisualState, errorActive: VisualState, errorInactive: VisualState, textAttributes: [NSAttributedString.Key: Any], titleFontSize: CGFloat) {
			self.normalActive = normalActive
			self.normalInactive = normalInactive
			self.errorActive = errorActive
			self.errorInactive = errorInactive
			self.textAttributes = textAttributes
			self.titleFontSize = titleFontSize
		}
		
		public static var defaultStyle =
			Style(normalActive: VisualState(helpAttributes: [.font: UIFont.systemFont(ofSize: 12),
														     .foregroundColor: UIColor.darkGray],
											titleColor: UIColor.black,
											placeholderColor: UIColor.lightGray,
											lineColor: UIColor.blue,
											lineHeight: 2),
				  normalInactive: VisualState(helpAttributes: [.font: UIFont.systemFont(ofSize: 12),
															 .foregroundColor: UIColor.darkGray],
											  titleColor: UIColor.gray,
											  placeholderColor: UIColor.lightGray,
											  lineColor: UIColor.black,
											  lineHeight: 1),
				  errorActive: VisualState(helpAttributes: [.font: UIFont.systemFont(ofSize: 12),
														  .foregroundColor: UIColor.red],
										   titleColor: UIColor.red,
										   placeholderColor: UIColor.lightGray,
										   lineColor: UIColor.red,
										   lineHeight: 2),
				  errorInactive: VisualState(helpAttributes: [.font: UIFont.systemFont(ofSize: 12),
															.foregroundColor: UIColor.red],
										   titleColor: UIColor.red,
										   placeholderColor: UIColor.lightGray,
										   lineColor: UIColor.red,
										   lineHeight: 1),
				  textAttributes: [.font: UIFont.systemFont(ofSize: 16),
								 .foregroundColor: UIColor.black],
				  titleFontSize: 10)
	}
}

public protocol MaterialTextViewDelegate: class {
	func materialTextViewDidChange(_ materialTextView: MaterialTextView)
	func materialTextViewDidBeginEditing(_ materialTextView: MaterialTextView)
	func materialTextViewDidEndEditing(_ materialTextView: MaterialTextView)
	func materialTextView(_ materialTextView: MaterialTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> (String, Bool)
}

public extension MaterialTextViewDelegate {
	func materialTextViewDidChange(_ materialTextView: MaterialTextView) { }
	func materialTextViewDidBeginEditing(_ materialTextView: MaterialTextView) { }
	func materialTextViewDidEndEditing(_ materialTextView: MaterialTextView) { }
	func materialTextView(_ materialTextView: MaterialTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> (String, Bool) { return (text, true) }
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
