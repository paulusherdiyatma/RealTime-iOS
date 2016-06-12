//
//  CustomLabel.swift
//  RealTimeEverything
//
//  Created by paulus herdiyatma on 6/11/16.
//  Copyright © 2016 paulusherdiyatma. All rights reserved.
//

import Foundation
import UIKit

class CustomLabel :UILabel {

override func drawTextInRect(rect: CGRect) {
    let insets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
    super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets));
}
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = 5;
        self.clipsToBounds = true;
    }
}