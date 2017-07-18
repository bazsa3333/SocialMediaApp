//
//  FeedVC.swift
//  devslopes-social
//
//  Created by Németh Bálint on 2017. 06. 28..
//  Copyright © 2017. Németh Bálint. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

//UINavigationControllerDelegate because we need to change the view
class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FancyField!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        //ez le is szedi az adatokat amiket a firebase-be manuálisan bevittünk 
        DataService.ds.REF_POST.observe(.value, with: { (snapshot) in
           
            //print(snapshot.value)
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
//        print("BALINT: \(post.caption)")
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                
                cell.configureCell(post: post, img: nil)
                return cell
            }
            
        }
        else {
            return PostCell()
        }
    }
    
    //eltünik mikor befejeztük a pickelést
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("BALINT: Valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        
        //ha a guard statement utáni dolog nem igaz akkor megy az else ágba
        guard let caption = captionField.text, caption != "" else {
            print("BALINT: Caption must be entered")
            return
        }
        
        guard let img = imageAdd.image, imageSelected == true else {
            print("BALINT: Image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            //unique identifier
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata, completion: { (metadata, error) in
                
                if error != nil {
                    print("BALINT: Unabled to upload image to Firebase storage")
                } else {
                    
                    print("BALINT: Succesfully uploaded image to Firebase storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    
                    //self -> closure
                    if let url = downloadUrl {
                        self.postToFirebase(imageUrl: url)
                    }
                }
            })
        }
    }
    
    func postToFirebase(imageUrl: String) {
        
        let post: Dictionary<String, AnyObject> = [
            "caption" : captionField.text as AnyObject,
            "imageUrl" : imageUrl as AnyObject,
            "likes" : 0 as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_POST.childByAutoId()
        firebasePost.setValue(post)
        
        //mindent visszaállitok alaphelyzetre a posztolás után
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        //tableView.reloadData()
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        //Tap gesture recognizer-t kell rárakni a sign-out kepre és enable-re kell állítani a user interaction-t mert különben nem csinál semmit a tapi-ra
        
        //let removeSuccessful: Bool = KeychainWrapper.standard.remove(key: "myKey")
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("BALINT: ID removed from keychain\(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
    

}

