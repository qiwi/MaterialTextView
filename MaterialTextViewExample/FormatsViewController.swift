//
//  FormatsViewController.swift
//  MaterialTextViewExample
//
//  Created by Mikhail Motyzhenkov on 07/08/2019.
//  Copyright © 2019 QIWI. All rights reserved.
//

import UIKit
import MaterialTextView

class FormatsViewController: UIViewController {

	@IBOutlet weak var tv: MaterialTextView!
	@IBOutlet weak var tf: MaterialTextView!
	@IBOutlet weak var stack: UIStackView!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		tv.viewModel = MaterialTextViewModel(textComponentMode: .textView,
											 placeholder: MaterialTextViewModel.Placeholder(type: .normal, text: "Digits (TextView)"),
														   actionValidator: { text in return .valid },
														   inputValidator: { text in
															guard let text = text else { return .valid }
															return text.count > 5 ? .invalid(text: "Too long") : .valid
											},
														   formats: ["ddddddd"],
														   rightButtonInfo: ButtonInfo(imageName: "icon", action: nil))
		
		tf.viewModel = MaterialTextViewModel(textComponentMode: .textField,
											 placeholder: MaterialTextViewModel.Placeholder(type: .normal, text: "Alphabet symbols only (TextField)"),
											 actionValidator: { text in return .valid },
											 inputValidator: { text in
												guard let text = text else { return .valid }
												return text.count > 5 ? .invalid(text: "Too long") : .valid
		},
											 formats: ["wwwwwwwwwwwwwwwwww"],
											 rightButtonInfo: ButtonInfo(imageName: "icon", action: nil))
		
		// Create MaterialTextView programmatically
		// set text to invalid value in order to check for glitches at start
		let tv = MaterialTextView(viewModel: MaterialTextViewModel(text: "", help: "", style: .defaultStyle, textComponentMode: .textField, placeholder: .init(type: .alwaysOnTop, text: "Amount (always on top)"), formats: ["ddddddddddddddddddddddddd $"], rightButtonInfo: nil))
		tv.translatesAutoresizingMaskIntoConstraints = false
		stack.addArrangedSubview(tv)
		
		let tv2 = MaterialTextView(viewModel: MaterialTextViewModel(text: "Created programmatically", help: "", style: .defaultStyle, textComponentMode: .textField, placeholder: .init(type: .alwaysOnTop, text: "Created programmatically"), formats: ["***************************"], rightButtonInfo: nil))
		tv2.translatesAutoresizingMaskIntoConstraints = false
		stack.addArrangedSubview(tv2)
		
		let tv3 = MaterialTextView(viewModel: MaterialTextViewModel(style: .defaultStyle, textComponentMode: .textView, placeholder: .init(type: .alwaysOnTop, text: "Telephone number"), formats: ["+d(ddd) ddd-dd-dd"], rightButtonInfo: nil))
		tv3.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 10.0, *) {
			tv3.textComponent.textContentType = .telephoneNumber
			tv3.textComponent.keyboardType = .numberPad
			tv3.textComponent.allowSmartSuggestions = true
		}
		stack.addArrangedSubview(tv3)
    }

}
