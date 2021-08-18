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
		
		tv.text = "123"
		tv.textComponentMode = .textView
		tv.placeholder = .init(type: .animated, text: "Digits (TextView, animated)")
		tv.inputValidator = { $0?.count ?? 999 > 5 ? .invalid(text: "Too long") : .valid }
		tv.formats = ["ddddddd"]
		tv.rightButtonInfo = .init(imageName: "icon", action: nil)
		
		tf.textComponentMode = .textField
		tf.placeholder = .init(type: .normal, text: "Alphabet symbols only (TextField)")
		tf.inputValidator = { $0?.count ?? 999 > 5 ? .invalid(text: "Too long") : .valid }
		tf.formats = ["wwwwwwwwwwwwwwwwww"]
		tf.rightButtonInfo = .init(imageName: "icon", action: nil)
		
		// Create MaterialTextView programmatically
		// set text to invalid value in order to check for glitches at start
		let tv = MaterialTextView()
		tv.placeholder = .init(type: .alwaysOnTop, text: "Amount (always on top)")
		tv.formats = ["ddddddddddddddddddddddddd $"]
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.text = "123"
		tv.textComponent.keyboardType = .numberPad
		stack.addArrangedSubview(tv)
		
		let tv2 = MaterialTextView()
		tv2.text = "Created programmatically"
		tv.placeholder = .init(type: .alwaysOnTop, text: "Created programmatically")
		tv2.translatesAutoresizingMaskIntoConstraints = false
		
		let tv3 = MaterialTextView()
		tv3.placeholder = .init(type: .alwaysOnTop, text: "Telephone number")
		tv3.formats = ["+d (ddd) ddd-dd-dd"]
		tv3.translatesAutoresizingMaskIntoConstraints = false
		tv3.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 10.0, *) {
			tv3.textComponent.textContentType = .telephoneNumber
			tv3.textComponent.keyboardType = .numberPad
			tv3.textComponent.allowSmartSuggestions = true
		}
		stack.addArrangedSubview(tv3)
    }

}
