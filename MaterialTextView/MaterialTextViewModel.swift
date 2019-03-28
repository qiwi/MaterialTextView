//
//  MaterialTextViewModel.swift
//  QIWIWallet
//
//  Created by Mikhail Motyzhenkov on 23/04/2018.
//  Copyright © 2018 QIWI. All rights reserved.
//

import Foundation

protocol MaterialTextViewModelDelegate: class {
    func viewModelTextChanged(newText: String)
    func viewModelHelpChanged(newHelp: String)
	func viewModelStateChanged(isActive: Bool, errorState: MaterialTextViewModel.ErrorState)
	func viewModelPlaceholderChanged(newPlaceholder: MaterialTextViewModel.Placeholder, isChanged: Bool)
}

extension MaterialTextViewModelDelegate {
	func viewModelTextChanged(newText: String) {}
	func viewModelHelpChanged(newHelp: String) {}
	func viewModelStateChanged(isActive: Bool, errorState: MaterialTextViewModel.ErrorState) {}
	func viewModelPlaceholderChanged(newPlaceholder: MaterialTextViewModel.Placeholder, isChanged: Bool) {}
}

struct ButtonInfo {

    let imageName: String
    let action: EmptyClosure?

    init(imageName: String, action: EmptyClosure?) {
        self.imageName = imageName
        self.action = action
    }
}

protocol MaterialTextViewProtocol: MaterialTextViewModelDelegate {
    func setupViewModel()
    var viewModel: MaterialTextViewModel? { get set }
}

extension MaterialTextViewProtocol {
    func setupViewModel() {
        self.viewModel?.view = self
    }
}

public final class MaterialTextViewModel {
	
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

    enum PlaceholderType {
        case normal
        case animated
    }

	struct Placeholder: Equatable {
        var type: PlaceholderType
        var text: String
    }

	private var _placeholder: Placeholder
    var placeholder: Placeholder {
		get { return _placeholder }
        set {
			if _placeholder == newValue { return }
			let oldPlaceholder = _placeholder
			_placeholder = newValue
            self.view?.viewModelPlaceholderChanged(newPlaceholder: placeholder, isChanged: newValue != oldPlaceholder)
            self.delegate?.viewModelPlaceholderChanged(newPlaceholder: placeholder, isChanged: newValue != oldPlaceholder)
        }
    }

    enum LineMode {
        case single
        case multiple
    }
	
	var isActive: Bool = false {
		didSet {
			view?.viewModelStateChanged(isActive: isActive, errorState: errorState)
			delegate?.viewModelStateChanged(isActive: isActive, errorState: errorState)
		}
	}

	private var _errorState: ErrorState = .normal
    var errorState: ErrorState {
		get {
			return _errorState
		}
		set {
			if _errorState != newValue {
				_errorState = newValue
				view?.viewModelStateChanged(isActive: isActive, errorState: newValue)
				delegate?.viewModelStateChanged(isActive: isActive, errorState: newValue)
			}
		}
    }

    // Вызывается по viewModel.validate()
    public var actionValidator: Validator<String>
    // Вызывается при каждом изменении текста
    public var inputValidator: Validator<String>?

    /// Результат последней валидации
    public var wasInputValid = true
	public var wasActionValid = false
    fileprivate weak var view: MaterialTextViewModelDelegate?
    weak var delegate: MaterialTextViewModelDelegate?

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
					view?.viewModelStateChanged(isActive: isActive, errorState: errorState)
					delegate?.viewModelStateChanged(isActive: isActive, errorState: errorState)
				}
			}
			self.view?.viewModelTextChanged(newText: _text)
			self.delegate?.viewModelTextChanged(newText: _text)
        }
    }

    public var help: String = "" {
        didSet {
            self.view?.viewModelHelpChanged(newHelp: help)
            self.delegate?.viewModelHelpChanged(newHelp: help)
        }
    }

    let lineMode: LineMode
    let rightButtonInfo: ButtonInfo?
    let format: String?

    required init(text: String = "",
				  help: String = "",
				  lineMode: LineMode = .single,
				  placeholder: Placeholder = Placeholder(type: .normal, text: ""),
				  actionValidator: @escaping Validator<String> = { _ in return .valid },
				  inputValidator: Validator<String>? = nil,
				  format: String? = nil,
				  rightButtonInfo: ButtonInfo? = nil) {
        self._text = text
        self.help = help
        self.actionValidator = actionValidator
        self.inputValidator = inputValidator
        self.lineMode = lineMode
        self._placeholder = placeholder
        self.format = format
        self.rightButtonInfo = rightButtonInfo
    }
}

extension MaterialTextViewModel: Validatable {
    @discardableResult
    func validate() -> Bool {
		wasInputValid = validate(validator: actionValidator).isError
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
