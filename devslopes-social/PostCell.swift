//
//  PostCell.swift
//  devslopes-social
//
//  Created by Németh Bálint on 2017. 07. 03..
//  Copyright © 2017. Németh Bálint. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //img is optional, beacuse it isn't cached yet
    func configureCell(post: Post, img: UIImage? = nil) {
        
        self.post = post
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        //if it's in the cache
        //Nagyon fontos mert ha a cache-ben van nem tölti le mégegyszer ugyan azt a képet!!!
        if img != nil {
            
            self.postImg.image = img
            //If not, we need to download it
        } else {
            
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 3 * 1024 * 1024, completion: { (data, error) in
                
                if error != nil {
                    
                    print("BALINT: Unabled download image from Firebase storage")
                } else {
                    
                    print("BALINT: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
    }

}
