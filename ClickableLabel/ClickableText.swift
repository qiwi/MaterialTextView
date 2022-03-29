//
//  ClickableText.swift
//  QiwiUIKit
//
//  Created by a.bushmeleva on 30.08.2018.
//  Copyright © 2018 Qiwi. All rights reserved.
//

import Foundation
import UIKit

struct Link {
    var text: NSAttributedString
    var highlightColor: UIColor?
    var action: () -> Void
    
    public init(text: NSAttributedString, highlightColor: UIColor?, action: @escaping () -> Void) {
        self.text = text
        self.highlightColor = highlightColor
        self.action = action
    }
}

struct ClickableText {
    
    static var empty = ClickableText(title: NSAttributedString(string: ""))
    
    var title: NSAttributedString
    var links: [Link]
    
    init(title: NSAttributedString, links: [Link] = []) {
        self.title = title
        self.links = links
    }
}
