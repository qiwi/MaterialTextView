//
//  ViewController.swift
//  MaterialTextViewExample
//
//  Created by Mikhail Motyzhenkov on 07/03/2019.
//  Copyright © 2019 QIWI. All rights reserved.
//

import UIKit
import MaterialTextView

enum StyleTag: Int {
	case normalActive = 100
	case normalInactive
	case errorActive
	case errorInactive
}

class ViewController: UIViewController {
	@IBOutlet weak var tf: MaterialTextView!
	@IBOutlet weak var tv: MaterialTextView!
	@IBOutlet weak var titleField: UITextField!
	@IBOutlet weak var helpField: UITextField!
	@IBOutlet weak var animatableTitleSwitch: UISwitch!
	
	@IBOutlet weak var stackNormalActive: UIStackView!
	@IBOutlet weak var stackNormalInactive: UIStackView!
	@IBOutlet weak var stackErrorActive: UIStackView!
	@IBOutlet weak var stackErrorInactive: UIStackView!
	
	@IBOutlet weak var normalActiveLineHeightLabel: UILabel!
	@IBOutlet weak var normalInactiveLineHeightLabel: UILabel!
	@IBOutlet weak var errorActiveLineHeightLabel: UILabel!
	@IBOutlet weak var errorInactiveLineHeightLabel: UILabel!
	
	var lineHeightLabels: [UILabel]! = nil
	var fields: [MaterialTextView]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tf.accessibilityIdentifier = "TextField"
		tv.accessibilityIdentifier = "TextView"
		fields = [tf, tv]
		setupMaterialTextView(textView: tf, mode: .textField)
		setupMaterialTextView(textView: tv, mode: .textView)
		updateInputValidator()
		lineHeightLabels = [normalActiveLineHeightLabel, normalInactiveLineHeightLabel, errorActiveLineHeightLabel, errorInactiveLineHeightLabel]
		applyTagForAllSubviews(view: stackNormalActive, tag: StyleTag.normalActive.rawValue)
		applyTagForAllSubviews(view: stackNormalInactive, tag: StyleTag.normalInactive.rawValue)
		applyTagForAllSubviews(view: stackErrorActive, tag: StyleTag.errorActive.rawValue)
		applyTagForAllSubviews(view: stackErrorInactive, tag: StyleTag.errorInactive.rawValue)
	}
	
	private func setupMaterialTextView(textView: MaterialTextView, mode: MaterialTextView.TextComponentMode) {
		textView.placeholder = .init(type: .animated, text: titleField.text!)
		textView.help = helpField.text!
		textView.textComponentMode = mode
		textView.useTintColorForActiveLine = false
		textView.useTintColorForActiveTitle = false
		textView.rightButtonInfo = .init(imageName: "icon", action: {
			print("Button was touched")
		})
	}
	
	private func applyTagForAllSubviews(view: UIView, tag: Int) {
		view.tag = tag
		view.subviews.forEach { applyTagForAllSubviews(view: $0, tag: tag) }
	}

	@IBAction func tapAction(_ sender: UITapGestureRecognizer) {
		view.endEditing(true)
	}
	
	@IBAction func animatedPlaceholderWasTapped(_ sender: UISwitch) {
		fields.forEach { $0.placeholder.type = sender.isOn ? .animated : .normal }
	}
	
	@IBAction func rightButtonWasTapped(_ sender: UISwitch) {
		fields.forEach { $0.rightButtonInfo = sender.isOn ? .init(imageName: "icon", action: { print("Button was tapped") }) : nil }
	}
	
	@IBAction func titleChanged(_ sender: UITextField) {
		fields.forEach { $0.placeholder.text = sender.text! }
	}
	
	@IBAction func helpChanged(_ sender: UITextField) {
		fields.forEach { $0.help = sender.text! }
	}
	
	private func updateInputValidator() {
		fields.forEach {
			$0.inputValidator = { text in
				guard let text = text else { return .valid }
				return text.count > 4 ? .invalid(text: "Text is too long") : .valid
			}
		}
	}
	
	@IBAction func lineHeightValueChanged(_ sender: UIStepper) {
		fields.forEach {
			$0.style.visualState(byTag: sender.tag, completion: { visualState in
				visualState.lineHeight = CGFloat(sender.value)
				lineHeightLabels.first(where: { $0.tag == sender.tag })?.text = "\(UInt(sender.value))"
			})
		}
	}
	
	@IBAction func lineColorChanged(_ sender: UIButton) {
		fields.forEach {
			$0.style.visualState(byTag: sender.tag, completion: { visualState in
				visualState.lineColor = sender.backgroundColor!
			})
		}
	}
	
	@IBAction func titleColorChanged(_ sender: UIButton) {
		fields.forEach {
			$0.style.visualState(byTag: sender.tag, completion: { visualState in
				visualState.titleColor = sender.backgroundColor!
			})
		}
	}
	
	@IBAction func placeholderColorChanged(_ sender: UIButton) {
		fields.forEach {
			$0.style.visualState(byTag: sender.tag, completion: { visualState in
				visualState.placeholderColor = sender.backgroundColor!
			})
		}
	}
	
	@IBAction func helpColorChanged(_ sender: UIButton) {
		fields.forEach {
			$0.style.visualState(byTag: sender.tag, completion: { visualState in
				visualState.helpAttributes[NSAttributedString.Key.foregroundColor] = sender.backgroundColor!
			})
		}
	}
	
}

extension MaterialTextView.Style {
	mutating func visualState(byTag tag: Int, completion: (inout MaterialTextView.VisualState) -> Void) {
		guard let styleTag = StyleTag(rawValue: tag) else { return }
		switch styleTag {
		case .normalActive: completion(&self.normalActive)
		case .normalInactive: completion(&self.normalInactive)
		case .errorActive: completion(&self.errorActive)
		case .errorInactive: completion(&self.errorInactive)
		}
	}
}
