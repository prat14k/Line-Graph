//
//  GraphLabel.swift
//  LineGraph
//
//  Created by Prateek Sharma on 8/14/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit

struct GraphLabel {
    var text: String
    var color: UIColor
    var font: UIFont

    init(text: String, color: UIColor, font: UIFont = UIFont.systemFont(ofSize: 15)) {
        self.text = text
        self.color = color
        self.font = font
    }
}
