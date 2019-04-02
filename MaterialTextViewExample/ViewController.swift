//
//  ViewController.swift
//  MaterialTextViewExample
//
//  Created by Mikhail Motyzhenkov on 07/03/2019.
//  Copyright © 2019 QIWI. All rights reserved.
//

import UIKit

enum StyleTag: Int {
	case normalActive = 100
	case normalInactive
	case errorActive
	case errorInactive
}

class ViewController: UIViewController {
	@IBOutlet weak var tv: MaterialTextView!
	@IBOutlet weak var titleField: UITextField!
	@IBOutlet weak var helpField: UITextField!
	@IBOutlet weak var errorField: UITextField!
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tv.viewModel?.placeholder = MaterialTextViewModel.Placeholder(type: .animated, text: titleField.text!)
		tv.viewModel?.help = helpField.text!
		tv.viewModel?.lineMode = .multiple
		updateInputValidator()
		lineHeightLabels = [normalActiveLineHeightLabel, normalInactiveLineHeightLabel, errorActiveLineHeightLabel, errorInactiveLineHeightLabel]
		applyTagForAllSubviews(view: stackNormalActive, tag: StyleTag.normalActive.rawValue)
		applyTagForAllSubviews(view: stackNormalInactive, tag: StyleTag.normalInactive.rawValue)
		applyTagForAllSubviews(view: stackErrorActive, tag: StyleTag.errorActive.rawValue)
		applyTagForAllSubviews(view: stackErrorInactive, tag: StyleTag.errorInactive.rawValue)
	}
	
	private func applyTagForAllSubviews(view: UIView, tag: Int) {
		view.tag = tag
		view.subviews.forEach { applyTagForAllSubviews(view: $0, tag: tag) }
	}

	@IBAction func tapAction(_ sender: UITapGestureRecognizer) {
		view.endEditing(true)
	}
	
	@IBAction func animatedPlaceholderWasTapped(_ sender: UISwitch) {
		tv.viewModel?.placeholder.type = sender.isOn ? .animated : .normal
	}
	
	@IBAction func titleChanged(_ sender: UITextField) {
		tv.viewModel?.placeholder.text = sender.text!
	}
	
	@IBAction func helpChanged(_ sender: UITextField) {
		tv.viewModel?.help = sender.text!
	}
	
	@IBAction func errorChanged(_ sender: UITextField) {
		updateInputValidator()
	}
	
	private func updateInputValidator() {
		tv.viewModel?.inputValidator = { [weak self] text in
			guard let text = text, let errorField = self?.errorField else { return .valid }
			return text.count > 3 ? .invalid(text: errorField.text!) : .valid
		}
	}
	
	@IBAction func lineHeightValueChanged(_ sender: UIStepper) {
		tv.style.visualState(byTag: sender.tag, completion: { visualState in
			visualState.lineHeight = CGFloat(sender.value)
			lineHeightLabels.first(where: { $0.tag == sender.tag })?.text = "\(UInt(sender.value))"
		})
	}
	
	@IBAction func lineColorChanged(_ sender: UIButton) {
		tv.style.visualState(byTag: sender.tag, completion: { visualState in
			visualState.lineColor = sender.backgroundColor!
		})
	}
	
	@IBAction func titleColorChanged(_ sender: UIButton) {
		tv.style.visualState(byTag: sender.tag, completion: { visualState in
			visualState.titleColor = sender.backgroundColor!
		})
	}
	
	@IBAction func placeholderColorChanged(_ sender: UIButton) {
		tv.style.visualState(byTag: sender.tag, completion: { visualState in
			visualState.placeholderColor = sender.backgroundColor!
		})
	}
	
	@IBAction func helpColorChanged(_ sender: UIButton) {
		tv.style.visualState(byTag: sender.tag, completion: { visualState in			visualState.helpAttributes[NSAttributedString.Key.foregroundColor] = sender.backgroundColor!
		})
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
