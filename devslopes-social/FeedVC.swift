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

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        //let removeSuccessful: Bool = KeychainWrapper.standard.remove(key: "myKey")
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("BALINT: ID removed from keychain\(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }

}
