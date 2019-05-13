//
//  MaterialTextViewModel.swift
//  QIWIWallet
//
//  Created by Mikhail Motyzhenkov on 23/04/2018.
//  Copyright © 2018 QIWI. All rights reserved.
//

import Foundation
import UIKit

public protocol MaterialTextViewModelDelegate: class {
	func viewModelTextChanged(viewModel: MaterialTextViewModel)
    func viewModelHelpChanged(newHelp: String)
	func viewModelStateChanged(viewModel: MaterialTextViewModel)
	func viewModelPlaceholderChanged(newPlaceholder: MaterialTextViewModel.Placeholder, typeIsChanged: Bool)
	func viewModelStyleChanged()
	func viewModelFormatSymbolsChanged(formatSymbols: [Character: CharacterSet])
	func viewModelFormatChanged(format: String?)
	func viewModelTextComponentModeChanged(viewModel: MaterialTextViewModel)
	func viewModelRightButtonChanged(viewModel: MaterialTextViewModel)
}

public extension MaterialTextViewModelDelegate {
	func viewModelTextChanged(viewModel: MaterialTextViewModel) {}
	func viewModelHelpChanged(newHelp: String) {}
	func viewModelStateChanged(viewModel: MaterialTextViewModel) {}
	func viewModelPlaceholderChanged(newPlaceholder: MaterialTextViewModel.Placeholder, typeIsChanged: Bool) {}
	func viewModelStyleChanged() {}
	func viewModelFormatSymbolsChanged(formatSymbols: [Character: CharacterSet]) {}
	func viewModelFormatChanged(format: String?) {}
	func viewModelTextComponentModeChanged(viewModel: MaterialTextViewModel) {}
	func viewModelRightButtonChanged(viewModel: MaterialTextViewModel) {}
}

public struct ButtonInfo {

    let imageName: String
    let action: EmptyClosure?

    public init(imageName: String, action: (() -> Void)?) {
        self.imageName = imageName
        self.action = action
    }
}

protocol MaterialTextViewProtocol: MaterialTextViewModelDelegate {
    func setupViewModel()
    var viewModel: MaterialTextViewModel? { get set }
}

extension MaterialTextViewProtocol where Self: UIView {
    func setupViewModel() {
        self.viewModel?.view = self
    }
}

public final class MaterialTextViewModel {
	
	public enum ErrorState: Equatable {
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

    public enum PlaceholderType {
        case normal
        case animated
    }

	public struct Placeholder: Equatable {
        public var type: PlaceholderType
        public var text: String
		
		public init(type: PlaceholderType, text: String) {
			self.type = type
			self.text = text
		}
    }

	private var _placeholder: Placeholder
    public var placeholder: Placeholder {
		get { return _placeholder }
        set {
			if _placeholder == newValue { return }
			let oldPlaceholder = _placeholder
			_placeholder = newValue
            self.view?.viewModelPlaceholderChanged(newPlaceholder: placeholder, typeIsChanged: newValue.type != oldPlaceholder.type)
            self.delegate?.viewModelPlaceholderChanged(newPlaceholder: placeholder, typeIsChanged: newValue != oldPlaceholder)
        }
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
		view?.viewModelStyleChanged()
		delegate?.viewModelStyleChanged()
		updateTintColor()
	}
	
	public var useTintColorForActiveLine = true
	public var useTintColorForActiveTitle = true
	
	private func updateTintColor() {
		guard let view = view else { return }
		var newStyle = _style
		if useTintColorForActiveLine {
			newStyle.normalActive.lineColor = view.tintColor
		}
		if useTintColorForActiveTitle {
			newStyle.normalActive.titleColor = view.tintColor
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
			view?.viewModelFormatSymbolsChanged(formatSymbols: newValue)
			delegate?.viewModelFormatSymbolsChanged(formatSymbols: newValue)
		}
	}
	
	public var isActive: Bool = false {
		didSet {
			view?.viewModelStateChanged(viewModel: self)
			delegate?.viewModelStateChanged(viewModel: self)
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
				view?.viewModelStateChanged(viewModel: self)
				delegate?.viewModelStateChanged(viewModel: self)
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

    // Вызывается по viewModel.validate()
    public var actionValidator: Validator<String>
    // Вызывается при каждом изменении текста
    public var inputValidator: Validator<String>?

    /// Результат последней валидации
    public var wasInputValid = true
	public var wasActionValid = false
    fileprivate weak var view: (UIView & MaterialTextViewModelDelegate)?
    public weak var delegate: MaterialTextViewModelDelegate?
	
	public var maxNumberOfLinesWithoutScrolling: CGFloat = 3

	private var _text: String
    public var text: String {
		get {
			return _text
		}
        set {
			if _text == newValue { return }
			let oldValue = _text
			_text = newValue
			if let inputValidator = inputValidator {
				errorState = validate(validator: inputValidator)
			}
			wasInputValid = !errorState.isError
			if placeholder.type == .normal {
				if oldValue.isEmpty || newValue.isEmpty {
					view?.viewModelStateChanged(viewModel: self)
					delegate?.viewModelStateChanged(viewModel: self)
				}
			}
			self.view?.viewModelTextChanged(viewModel: self)
			self.delegate?.viewModelTextChanged(viewModel: self)
        }
    }

    public var help: String = "" {
        didSet {
            self.view?.viewModelHelpChanged(newHelp: help)
            self.delegate?.viewModelHelpChanged(newHelp: help)
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
	
	var rightButtonInfo: ButtonInfo? {
		didSet {
			view?.viewModelRightButtonChanged(viewModel: self)
			delegate?.viewModelRightButtonChanged(viewModel: self)
		}
	}
	public var format: String? {
		didSet {
			view?.viewModelFormatChanged(format: format)
			delegate?.viewModelFormatChanged(format: format)
		}
	}

    public required init(text: String = "",
				  help: String = "",
				  style: Style = .defaultStyle,
				  textComponentMode: TextComponentMode = .textField,
				  placeholder: Placeholder = Placeholder(type: .normal, text: ""),
				  actionValidator: @escaping Validator<String> = { _ in return .valid },
				  inputValidator: Validator<String>? = nil,
				  format: String? = nil,
				  rightButtonInfo: ButtonInfo? = nil) {
        self._text = text
        self.help = help
		_textComponentMode = textComponentMode
        self.actionValidator = actionValidator
        self.inputValidator = inputValidator
        self._placeholder = placeholder
        self.format = format
        self.rightButtonInfo = rightButtonInfo
		_style = style
		didUpdateStyle()
    }
}

extension MaterialTextViewModel: Validatable {
    @discardableResult
	public func validate() -> Bool {
		errorState = validate(validator: actionValidator)
		wasActionValid = !errorState.isError
		view?.viewModelStateChanged(viewModel: self)
		delegate?.viewModelStateChanged(viewModel: self)
        return wasActionValid
    }

    @discardableResult
    fileprivate func validate(validator: Validator<String>) -> ErrorState {
        switch validator(text) {
        case .valid:
			return .normal
        case .invalid(let text):
            return .error(text)
        }
    }
}

extension MaterialTextViewModel {
	
	public struct VisualState: Equatable {
		
		public static func == (lhs: VisualState, rhs: VisualState) -> Bool {
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
		
		public static func == (lhs: Style, rhs: Style) -> Bool {
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
