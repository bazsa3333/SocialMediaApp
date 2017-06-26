//
//  RoundBtn.swift
//  devslopes-social
//
//  Created by Németh Bálint on 2017. 06. 26..
//  Copyright © 2017. Németh Bálint. All rights reserved.
//

import UIKit

class RoundBtn: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GREY, green: SHADOW_GREY, blue: SHADOW_GREY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
        //Ez csak négyzetben kerekitené le de nekünk kör alak kell
        layer.cornerRadius = 5.0
        
        imageView?.contentMode = .scaleAspectFit
        
    }
    
    //ezzel érjük el a kör alakot plusz 
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.width / 2
    }
}
