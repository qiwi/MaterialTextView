//
//  MaterialTextViewModel.swift
//  QIWIWallet
//
//  Created by Mikhail Motyzhenkov on 23/04/2018.
//  Copyright © 2018 QIWI. All rights reserved.
//

import Foundation
import UIKit
import FormattableTextView

public protocol MaterialTextViewModelBaseDelegate: AnyObject {
	func viewModelTextChanged(viewModel: MaterialTextViewModel)
	func viewModelHelpChanged(viewModel: MaterialTextViewModel)
	func viewModelStateChanged(viewModel: MaterialTextViewModel, placeholderTypeIsChanged: Bool)
	func viewModelPlaceholderChanged(viewModel: MaterialTextViewModel, typeIsChanged: Bool)
	func viewModelStyleChanged(viewModel: MaterialTextViewModel)
	func viewModelFormatSymbolsChanged(viewModel: MaterialTextViewModel)
	func viewModelFormatsChanged(viewModel: MaterialTextViewModel)
	func viewModelTextComponentModeChanged(viewModel: MaterialTextViewModel)
	func viewModelRightButtonChanged(viewModel: MaterialTextViewModel)
}

public protocol MaterialTextViewModelDelegate: MaterialTextViewModelBaseDelegate {
}

internal protocol MaterialTextViewViewModelDelegate: MaterialTextViewModelBaseDelegate {
	var currentFormat: String? { get }
	var formattedText: String { get }
	var formatSelectionStrategy: FormatSelectionStrategy { get set }
}

public extension MaterialTextViewModelDelegate {
	func viewModelTextChanged(viewModel: MaterialTextViewModel) {}
	func viewModelHelpChanged(viewModel: MaterialTextViewModel) {}
	func viewModelStateChanged(viewModel: MaterialTextViewModel, placeholderTypeIsChanged: Bool) {}
	func viewModelPlaceholderChanged(viewModel: MaterialTextViewModel, typeIsChanged: Bool) {}
	func viewModelStyleChanged(viewModel: MaterialTextViewModel) {}
	func viewModelFormatSymbolsChanged(viewModel: MaterialTextViewModel) {}
	func viewModelFormatsChanged(viewModel: MaterialTextViewModel) {}
	func viewModelTextComponentModeChanged(viewModel: MaterialTextViewModel) {}
	func viewModelRightButtonChanged(viewModel: MaterialTextViewModel) {}
}

public struct ButtonInfo {

	let image: UIImage?
	let action: EmptyClosure?

	public init(imageName: String, action: (() -> Void)?) {
		self.image = UIImage(named: imageName)
		self.action = action
	}

	public init(image: UIImage?, action: (() -> Void)?) {
		self.image = image
		self.action = action
	}
}

struct HelpInfo {
	var text: String
	var linkText: String?
	var linkAction: EmptyClosure?

	init(text: String, linkText: String? = nil, linkAction: EmptyClosure? = nil) {
		self.text = text
		self.linkText = linkText
		self.linkAction = linkAction
	}
}

protocol MaterialTextViewProtocol: MaterialTextViewViewModelDelegate {
	func setupViewModel()
	var viewModel: MaterialTextViewModel { get set }
}

extension MaterialTextViewProtocol where Self: UIView {
	func setupViewModel() {
		self.viewModel.view = self
		self.viewModel.updateTintColor()
	}
}

public final class MaterialTextViewModel {

	public enum ErrorState: Equatable {
		case normal
		case error(text: String)
		case linkError(text: String, linkText: String)

		var isError: Bool {
			switch self {
			case .normal:
				return false
			case .error(_):
				return true
			case .linkError(_, _):
				return true
			}
		}
	}

	public enum PlaceholderType {
		case normal
		case animated
		case alwaysOnTop
	}

	public struct Placeholder: Equatable {
		public var type: PlaceholderType
		public var text: String

		public init(type: PlaceholderType, text: String) {
			self.type = type
			self.text = text
		}
	}

	public var textDidChange: ((String) -> Void)?
	public var didBeginEditing: EmptyClosure?
	public var didEndEditing: EmptyClosure?
	public var shouldChangeText: ((NSRange, String) -> Bool)?
	public var stateDidChange: ((ErrorState) -> Void)?
    public var linkAction: EmptyClosure?

	private var _placeholder: Placeholder
	public var placeholder: Placeholder {
		get { return _placeholder }
		set {
			if _placeholder == newValue { return }
			let oldPlaceholder = _placeholder
			_placeholder = newValue
			self.view?.viewModelPlaceholderChanged(viewModel: self, typeIsChanged: newValue.type != oldPlaceholder.type)
			self.delegate?.viewModelPlaceholderChanged(viewModel: self, typeIsChanged: newValue != oldPlaceholder)
		}
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
		updateTintColor()
		view?.viewModelStyleChanged(viewModel: self)
		delegate?.viewModelStyleChanged(viewModel: self)
	}

	private var _useTintColorForActiveLine = true
	public var useTintColorForActiveLine: Bool {
		get { _useTintColorForActiveLine }
		set {
			if _useTintColorForActiveLine == newValue { return }
			_useTintColorForActiveLine = newValue
			didUpdateStyle()
		}
	}
	private var _useTintColorForActiveTitle = true
	public var useTintColorForActiveTitle: Bool {
		get { _useTintColorForActiveTitle }
		set {
			if _useTintColorForActiveTitle == newValue { return }
			_useTintColorForActiveTitle = newValue
			didUpdateStyle()
		}
	}

	internal func updateTintColor() {
		guard let view = view else { return }
		var newStyle = _style
		if useTintColorForActiveLine {
			newStyle.normalActive.lineColor = view.tintColor
		} else {
			newStyle.normalActive.lineColor = _styleWithoutTintColor.normalActive.lineColor
		}

		if useTintColorForActiveTitle {
			newStyle.normalActive.titleAttributes[.foregroundColor] = view.tintColor
		} else {
			newStyle.normalActive.titleAttributes[.foregroundColor] = _styleWithoutTintColor.normalActive.titleAttributes[.foregroundColor]
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
			view?.viewModelFormatSymbolsChanged(viewModel: self)
			delegate?.viewModelFormatSymbolsChanged(viewModel: self)
		}
	}

	public var isActive: Bool = false {
		didSet {
			view?.viewModelStateChanged(viewModel: self, placeholderTypeIsChanged: false)
			delegate?.viewModelStateChanged(viewModel: self, placeholderTypeIsChanged: false)
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
				view?.viewModelStateChanged(viewModel: self, placeholderTypeIsChanged: false)
				delegate?.viewModelStateChanged(viewModel: self, placeholderTypeIsChanged: false)
				stateDidChange?(newValue)
			}
		}
	}

	public var visualState: VisualState {
		switch errorState {
		case .normal:
			return isActive ? style.normalActive : style.normalInactive
		case .error(_):
			return isActive ? style.errorActive : style.errorInactive
		case .linkError(_, _):
			return isActive ? style.errorActive : style.errorInactive
		}
	}

	// Вызывается по viewModel.validate()
	public var actionValidator: Validator<String>
	// Вызывается при каждом изменении текста
	public var inputValidator: Validator<String>?

	/// Результат последней валидации
	public var wasInputValid = true
	public var wasActionValid = false
	fileprivate weak var view: (UIView & MaterialTextViewViewModelDelegate)?
	public weak var delegate: MaterialTextViewModelDelegate?

	public var maxNumberOfLinesWithoutScrolling: CGFloat = 3 {
		didSet {
			view?.viewModelStateChanged(viewModel: self, placeholderTypeIsChanged: false)
		}
	}

	private var _text: String
	internal func validateInput() {
		if let inputValidator = inputValidator {
			errorState = validate(validator: inputValidator)
		}
		wasInputValid = !errorState.isError
	}

	private(set) var helpInfo = HelpInfo(text: "") {
		didSet {
			self.view?.viewModelHelpChanged(viewModel: self)
			self.delegate?.viewModelHelpChanged(viewModel: self)
		}
	}

	public var text: String {
		get {
			return _text
		}
		set {
			if _text == newValue { return }
			_text = newValue
			validateInput()
			view?.viewModelStateChanged(viewModel: self, placeholderTypeIsChanged: placeholder.type != .alwaysOnTop)
			delegate?.viewModelStateChanged(viewModel: self, placeholderTypeIsChanged: placeholder.type != .alwaysOnTop)
			self.view?.viewModelTextChanged(viewModel: self)
			self.delegate?.viewModelTextChanged(viewModel: self)
			self.textDidChange?(newValue)
		}
	}

	private var _textComponentMode: TextComponentMode = .textField
	public var textComponentMode: TextComponentMode {
		get { return _textComponentMode }
		set {
			if _textComponentMode == newValue { return }
			_textComponentMode = newValue
			view?.viewModelTextComponentModeChanged(viewModel: self)
			delegate?.viewModelTextComponentModeChanged(viewModel: self)
		}
	}

	public var rightButtonInfo: ButtonInfo? {
		didSet {
			view?.viewModelRightButtonChanged(viewModel: self)
			delegate?.viewModelRightButtonChanged(viewModel: self)
		}
	}
	public var formats: [String] {
		didSet {
			view?.viewModelFormatsChanged(viewModel: self)
			delegate?.viewModelFormatsChanged(viewModel: self)
		}
	}

	public var currentFormat: String? {
		view?.currentFormat
	}

	public var formatSelectionStrategy: FormatSelectionStrategy {
		get {
			guard let view = view else { return .startFromCurrent }
			return view.formatSelectionStrategy
		}
		set {
			guard let view = view else { return }
			if view.formatSelectionStrategy == newValue { return }
			view.formatSelectionStrategy = newValue
		}
	}

	public var formattedText: String? {
		view?.formattedText
	}

	public required init(text: String = "",
				  help: String = "",
				  style: Style,
				  textComponentMode: TextComponentMode = .textField,
				  placeholder: Placeholder = Placeholder(type: .normal, text: ""),
				  actionValidator: @escaping Validator<String> = { _ in return .valid },
				  inputValidator: Validator<String>? = nil,
				  formats: [String] = [],
				  formatSymbols: [Character: CharacterSet]? = nil,
				  rightButtonInfo: ButtonInfo? = nil) {
		self._text = text
		self.helpInfo.text = help
		_textComponentMode = textComponentMode
		self.actionValidator = actionValidator
		self.inputValidator = inputValidator
		self._placeholder = placeholder
		self.formats = formats
		if let formatSymbols = formatSymbols {
			self.formatSymbols = formatSymbols
		}
		self.rightButtonInfo = rightButtonInfo
		_style = style
		_styleWithoutTintColor = style
		didUpdateStyle()
	}


	public func updateHelp(helpText: String) {
		helpInfo.text = helpText
	}

    public func updateHelp(errorState: ErrorState, helpText: String, linkText: String?, linkAction: EmptyClosure?) {
        switch errorState {
        case .normal:
            helpInfo.text = helpText
            self.errorState = .normal
        case .error(_):
            self.errorState = .error(text: helpText)
        case .linkError(_, _):
            self.errorState = .linkError(text: helpText, linkText: linkText ?? "")
            self.linkAction = linkAction
        }
	}
}

extension MaterialTextViewModel: Validatable {
	@discardableResult
	public func validate() -> Bool {
		errorState = validate(validator: actionValidator)
		wasActionValid = !errorState.isError
		view?.viewModelStateChanged(viewModel: self, placeholderTypeIsChanged: false)
		delegate?.viewModelStateChanged(viewModel: self, placeholderTypeIsChanged: false)
		return wasActionValid
	}

	@discardableResult
	fileprivate func validate(validator: Validator<String>) -> ErrorState {
		switch validator(text) {
		case .valid:
			return .normal
		case .invalid(let text):
			return .error(text: text)
		}
	}
}

public extension MaterialTextViewModel {

	struct VisualState: Equatable {

		public static func == (lhs: VisualState, rhs: VisualState) -> Bool {
			return lhs.lineHeight == rhs.lineHeight &&
			lhs.lineColor == rhs.lineColor &&
			lhs.backgroundColor == rhs.backgroundColor &&
			areAttributesEqual(lhs.titleAttributes, rhs.titleAttributes) &&
			areAttributesEqual(lhs.helpAttributes, rhs.helpAttributes) &&
            areAttributesEqual(lhs.linkAttributes, rhs.linkAttributes)
		}

		public var helpAttributes: [NSAttributedString.Key: Any]
		public var titleAttributes: [NSAttributedString.Key: Any]
        public var linkAttributes: [NSAttributedString.Key: Any]
		public var backgroundColor: UIColor
		public var lineColor: UIColor
		public var lineHeight: CGFloat

		public init(helpAttributes: [NSAttributedString.Key: Any],
					titleAttributes: [NSAttributedString.Key: Any],
                    linkAttributes: [NSAttributedString.Key: Any],
					backgroundColor: UIColor,
					lineColor: UIColor,
					lineHeight: CGFloat) {
			self.helpAttributes = helpAttributes
			self.titleAttributes = titleAttributes
            self.linkAttributes = linkAttributes
			self.backgroundColor = backgroundColor
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
                                            linkAttributes: [.font: UIFont.systemFont(ofSize: 12),
                                                             .foregroundColor: UIColor.linkColor],
											backgroundColor: UIColor.white,
											lineColor: UIColor.blue,
											lineHeight: 2),
				  normalInactive: VisualState(helpAttributes: [.font: UIFont.systemFont(ofSize: 12),
															   .foregroundColor: UIColor.darkGray],
											  titleAttributes: [.font: UIFont.systemFont(ofSize: 10),
                                                                .foregroundColor: UIColor.gray],
                                              linkAttributes: [.font: UIFont.systemFont(ofSize: 12),
                                                               .foregroundColor: UIColor.linkColor],
											  backgroundColor: UIColor.white,
											  lineColor: UIColor.black,
											  lineHeight: 1),
				  errorActive: VisualState(helpAttributes: [.font: UIFont.systemFont(ofSize: 12),
															.foregroundColor: UIColor.red],
										   titleAttributes: [.font: UIFont.systemFont(ofSize: 10),
                                                             .foregroundColor: UIColor.red],
                                           linkAttributes: [.font: UIFont.systemFont(ofSize: 12),
                                                            .foregroundColor: UIColor.linkColor],
										   backgroundColor: UIColor.white,
										   lineColor: UIColor.red,
										   lineHeight: 2),
				  errorInactive: VisualState(helpAttributes: [.font: UIFont.systemFont(ofSize: 12),
															  .foregroundColor: UIColor.red],
											 titleAttributes: [.font: UIFont.systemFont(ofSize: 10),
                                                               .foregroundColor: UIColor.red],
                                             linkAttributes: [.font: UIFont.systemFont(ofSize: 12),
                                                              .foregroundColor: UIColor.linkColor],
											 backgroundColor: UIColor.white,
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

extension MaterialTextViewModel: Equatable {
	public static func == (lhs: MaterialTextViewModel, rhs: MaterialTextViewModel) -> Bool {
        lhs.style == rhs.style && lhs.text == rhs.text && lhs.helpInfo.text == rhs.helpInfo.text && lhs.helpInfo.linkText == rhs.helpInfo.linkText && lhs.placeholder == rhs.placeholder && lhs.useTintColorForActiveLine == rhs.useTintColorForActiveLine && lhs.useTintColorForActiveTitle == rhs.useTintColorForActiveTitle
	}
}
