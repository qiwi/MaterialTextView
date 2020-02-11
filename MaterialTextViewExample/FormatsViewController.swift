//
//  FormatsViewController.swift
//  MaterialTextViewExample
//
//  Created by Mikhail Motyzhenkov on 07/08/2019.
//  Copyright © 2019 QIWI. All rights reserved.
//

import UIKit

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
														   format: "ddddddd",
														   rightButtonInfo: ButtonInfo(imageName: "icon", action: nil))
		
		tf.viewModel = MaterialTextViewModel(textComponentMode: .textField,
											 placeholder: MaterialTextViewModel.Placeholder(type: .normal, text: "Alphabet symbols only (TextField)"),
											 actionValidator: { text in return .valid },
											 inputValidator: { text in
												guard let text = text else { return .valid }
												return text.count > 5 ? .invalid(text: "Too long") : .valid
		},
											 format: "wwwwwwwwww",
											 rightButtonInfo: ButtonInfo(imageName: "icon", action: nil))
		
		// Create MaterialTextView programmatically
		let tv = MaterialTextView(viewModel: MaterialTextViewModel(text: "", help: "", style: .defaultStyle, textComponentMode: .textField, placeholder: .init(type: .alwaysOnTop, text: "Amount (always on top)"), actionValidator: { _ in return .valid }, inputValidator: { _ in return .valid }, format: "dddddd $", rightButtonInfo: nil))
		tv.translatesAutoresizingMaskIntoConstraints = false
		stack.addArrangedSubview(tv)
		
		let tv2 = MaterialTextView(viewModel: MaterialTextViewModel(text: "Created programmatically", help: "", style: .defaultStyle, textComponentMode: .textField, placeholder: .init(type: .alwaysOnTop, text: "Created programmatically"), actionValidator: { _ in return .valid }, inputValidator: { _ in return .valid }, format: "***************************", rightButtonInfo: nil))
		tv2.translatesAutoresizingMaskIntoConstraints = false
		stack.addArrangedSubview(tv2)
    }

}
