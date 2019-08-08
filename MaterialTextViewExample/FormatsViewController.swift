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
	
	override func viewDidLoad() {
        super.viewDidLoad()

		tv.viewModel = MaterialTextViewModel(textComponentMode: .textView,
											 placeholder: MaterialTextViewModel.Placeholder(type: .alwaysOnTop, text: "TextView"),
														   actionValidator: { text in return .valid },
														   inputValidator: { text in
															guard let text = text else { return .valid }
															return text.count > 5 ? .invalid(text: "Too long") : .valid
											},
														   format: "ddddddd ₽",
														   rightButtonInfo: ButtonInfo(imageName: "icon", action: nil))
		
		tf.viewModel = MaterialTextViewModel(textComponentMode: .textField,
											 placeholder: MaterialTextViewModel.Placeholder(type: .alwaysOnTop, text: "TextField"),
											 actionValidator: { text in return .valid },
											 inputValidator: { text in
												guard let text = text else { return .valid }
												return text.count > 5 ? .invalid(text: "Too long") : .valid
		},
											 format: "ddddddd ₽",
											 rightButtonInfo: ButtonInfo(imageName: "icon", action: nil))
    }

}
