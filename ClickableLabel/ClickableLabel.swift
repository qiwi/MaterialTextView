//
//  ClickableLabel.swift
//  QiwiUIKit
//
//  Created by a.bushmeleva on 27.08.2018.
//  Copyright © 2018 Qiwi. All rights reserved.
//

import UIKit
import CoreText

public class ClickableLabel: UILabel {
    
    private var handlerDictionary = [NSRange: Link]()
    private var backupAttributedText: NSAttributedString?
    
    private var _clickableText: ClickableText?
    public var clickableText: ClickableText? {
        get {
            return self._clickableText
        }
        set {
            self._clickableText = newValue
            updateAppearance()
        }
    }
	
	public init() {
		super.init(frame: CGRect.zero)
	}
    
    public init(item: ClickableText) {
        super.init(frame: CGRect.zero)
        self.clickableText = item
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateAppearance() {
        guard let item = clickableText else { return }
        
        isUserInteractionEnabled = (item.links.count > 0)
        lineBreakMode = .byWordWrapping
        numberOfLines = 0
        
        attributedText = item.title
        for link in item.links {
            setLinkAttributes(link)
        }
    }
    
    func setLinkAttributes(_ link: Link) {
        guard let attrText = attributedText else { return }
        
        let attributes = link.text.attributes(at: 0, effectiveRange: nil)
        let linkRange = (attrText.string as NSString).range(of: link.text.string) as NSRange

        let mutableAttributedString = NSMutableAttributedString(attributedString: attrText)
        mutableAttributedString.addAttributes(attributes, range: linkRange)

        attributedText = mutableAttributedString
        
        handlerDictionary[linkRange] = link
    }
}

extension ClickableLabel {
    
    // MARK: Event Handler
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let attrText = attributedText else { return }
        
        backupAttributedText = attributedText
        
        for touch in touches {
            if let range = attributedTextRange(point: touch.location(in: self)) {
                let attributedString = NSMutableAttributedString(attributedString: attrText)
                
                if let highlightColor = handlerDictionary[range]?.highlightColor {
                    attributedString.addAttributes([NSAttributedString.Key.foregroundColor : highlightColor], range: range)
                }
                
                UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve, animations: { [weak self] in
                    self?.attributedText = attributedString
                    }, completion: nil)
                return
            }
        }
        super.touchesBegan(touches, with: event)
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.attributedText = self?.backupAttributedText
            }, completion: nil)
        super.touchesCancelled(touches, with: event)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.attributedText = self?.backupAttributedText
            }, completion: nil)
        for touch in touches {
            if let rangeValue = attributedTextRange(point: touch.location(in: self)) {
                handlerDictionary[rangeValue]?.action()
                return
            }
        }
        super.touchesEnded(touches, with: event)
    }
    
    // MARK: Locator
    
    func characterIndex(point: CGPoint) -> NSInteger {
        guard let attrText = attributedText else { return -1 }
        
        let attrMutText = NSMutableAttributedString(attributedString: attrText)
		attrMutText.addAttributes([NSAttributedString.Key.font : font ?? UIFont.systemFont(ofSize: 16)], range: NSMakeRange(0, attrText.string.count))
        
        let textContainer = NSTextContainer(size: CGSize.zero)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.size = bounds.size
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        let textStorage = NSTextStorage(attributedString: attrMutText)
        textStorage.addLayoutManager(layoutManager)
        
        return layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
    }
    
    func attributedTextRange(point: CGPoint) -> NSRange? {
        let indexOfCharacter = characterIndex(point: point)
        
        for range in handlerDictionary.keys {
            if NSLocationInRange(indexOfCharacter, range) {
                return range
            }
        }
        return nil
    }
}

