# MaterialTextView

<img src="material.gif"/>

## Description
This is QIWI's implementation of text field/view according to Material Design. It supports formattable input with masks since it uses [FormattableTextView](https://github.com/qiwi/FormattableTextView).

This component is highly customizable via styles in real time.
You can check user input for validity manually by firing `validate()` method (it checks the text according to `actionValidator` property) or automatically during user's input by setting `inputValidator` property.

Placeholder has 2 modes: animatable and normal.

## Requirements
* iOS 9.0+

## Installation

### CocoaPods
```
pod 'FormattableTextView', :git => 'https://github.com/qiwi/FormattableTextView'
pod 'MaterialTextView', :git => 'https://github.com/qiwi/MaterialTextView'
```

### Carthage
```
git "https://github.com/qiwi/MaterialTextView" "master"
```

## Usage

### Example 1
```swift
let tv = MaterialTextView(.init(style: .defaultStyle))
```

### Example 2
```swift
let viewModel = MaterialTextViewModel(
	style: .defaultStyle,
	placeholder: .init(type: .alwaysOnTop, text: "Telephone number"),
	formats: ["+d (ddd) ddd-dd-dd", "+ddddddddddddddddd"]
)
viewModel.formatSelectionStrategy = .startFromFirst
let tv = MaterialTextView(viewModel)
if #available(iOS 10.0, *) {
	tv.textComponent.textContentType = .telephoneNumber
	tv.textComponent.keyboardType = .numberPad
	tv.textComponent.allowSmartSuggestions = true
}
```


## License
Distributed under the MIT License.
