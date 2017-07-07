//
//  CircleView.swift
//  devslopes-social
//
//  Created by Németh Bálint on 2017. 06. 30..
//  Copyright © 2017. Németh Bálint. All rights reserved.
//

import UIKit

class CircleView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }

}
