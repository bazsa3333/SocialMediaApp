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
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!
    //feltettem ide hogy ne keljen többször leírni a func-okba
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //programatikusan kell hozzáadni a tapGestureRecognizer-t a like gombhoz mert nem ismerné fell ha manuállisan adnánk hozzá, nem tudná melyikről lenne szó a TableView-ban
        //Először csak létrehozza aztán majd utána adjuk hozzá
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
        
    }
    
    //img is optional, beacuse it isn't cached yet
    func configureCell(post: Post, img: UIImage? = nil) {
        
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
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
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Firebase-be NSNull-ként hivatkozok a nil-re
            //Hogyha nincs lájkolva üres sziv ha van akkor telített szív - csak lecsekkolja
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Az ellenkezőjét csinálom mint felül - ha megnyomom a like-gombot és még nincs lájk akkor kitölti, ha van akkor leveszi a lájkot
            //felhasználói részen történik ez most az adatbázisban és ott csak referencia van, hogy adott felasználó lájkolta e vagy sem.
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
}
