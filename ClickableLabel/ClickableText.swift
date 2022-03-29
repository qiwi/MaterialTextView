//
//  ClickableText.swift
//  QiwiUIKit
//
//  Created by a.bushmeleva on 30.08.2018.
//  Copyright © 2018 Qiwi. All rights reserved.
//

import Foundation
import UIKit

public struct Link {
    public var text: NSAttributedString
    public var highlightColor: UIColor?
    public var action: () -> Void
    
    public init(text: NSAttributedString, highlightColor: UIColor?, action: @escaping () -> Void) {
        self.text = text
        self.highlightColor = highlightColor
        self.action = action
    }
}

public struct ClickableText {
    
    public static var empty = ClickableText(title: NSAttributedString(string: ""))
    
    public var title: NSAttributedString
    public var links: [Link]
    
    public init(title: NSAttributedString, links: [Link] = []) {
        self.title = title
        self.links = links
    }
}
