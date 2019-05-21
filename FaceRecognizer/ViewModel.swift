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
        backgroundColor = UIColor.clear
    }
    
}
