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
		
		self.tv.help = "Max length is 5 symbols"
		self.tv.placeholder = .init(type: .animated, text: "Digits (TextView, animated)")
		self.tv.inputValidator = { $0.count > 5 ? .invalid(text: "Too long") : .valid }
		self.tv.formats = ["ddddddd"]
		self.tv.rightButtonInfo = .init(imageName: "icon", action: nil)
		self.tv.textComponentMode = .textView
		self.tv.text = "123456"
		
		self.tf.textComponentMode = .textField
		self.tf.placeholder = .init(type: .normal, text: "Alphabet symbols only (TextField)")
		self.tf.inputValidator = { $0.count > 5 ? .invalid(text: "Too long") : .valid }
		self.tf.formats = ["wwwwwwwwwwwwwwwwww"]
		self.tf.rightButtonInfo = .init(imageName: "icon", action: nil)
		
		let tv = MaterialTextView()
		tv.placeholder = .init(type: .animated, text: "Animated")
		tv.formats = ["ddddd $"]
		tv.text = "2"
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.textComponent.keyboardType = .numberPad
		stack.addArrangedSubview(tv)
		tv.text = ""
		tv.formatSymbols = ["d": CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ",."))]
		
		// Create MaterialTextView programmatically
		// set text to invalid value in order to check for glitches at start
		let tv2 = MaterialTextView()
		tv2.placeholder = .init(type: .alwaysOnTop, text: "Amount (always on top)")
		tv2.formats = ["ddddddddddddddddddddddddd $"]
		tv2.translatesAutoresizingMaskIntoConstraints = false
		tv2.text = "123"
		tv2.textComponent.keyboardType = .numberPad
		stack.addArrangedSubview(tv2)
		tv2.text = "Created programmatically"
		tv2.placeholder = .init(type: .alwaysOnTop, text: "Created programmatically")
		tv2.translatesAutoresizingMaskIntoConstraints = false
		
		let tv3 = MaterialTextView()
		tv3.placeholder = .init(type: .alwaysOnTop, text: "Telephone number")
		tv3.formats = ["+d (ddd) ddd-dd-dd"]
		tv3.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 10.0, *) {
			tv3.textComponent.textContentType = .telephoneNumber
			tv3.textComponent.keyboardType = .numberPad
			tv3.textComponent.allowSmartSuggestions = true
		}
		stack.addArrangedSubview(tv3)
    }

}
