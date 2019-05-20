//
//  ViewModel.swift
//  FaceRecognizer
//
//  Created by I Putu Krisna on 20/05/19.
//  Copyright © 2019 I Putu Krisna. All rights reserved.
//

import UIKit

class ViewModel: UIView {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.width/2
        layer.borderWidth = 5
        layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        backgroundColor = UIColor.clear
    }
    
}
