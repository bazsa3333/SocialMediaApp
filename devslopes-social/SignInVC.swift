//
//  ViewController.swift
//  devslopes-social
//
//  Created by Németh Bálint on 2017. 03. 27..
//  Copyright © 2017. Németh Bálint. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    
    //Segues need to be performed in viewDidAppear!!!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
            print("BALINT: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
    
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                
                //Berakom a BALINT-ot mert igy az output-ok között tudok filterezni és megtalálom mi vonatkozik rám
                print("BALINT: Unable to authenticate with Facebook")
            } else if result?.isCancelled == true {
               
                print("BALINT: User cancelled Facebook authentication")
            } else {
                
                print("BALINT: Succesfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    //Hiányzott a LSApplicationQueriesSchemes az info.plist-ből. Kiirta a hibaüzenetet mikor nem történt meg a kivétel elkapása...
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                
                print("BALINT: Unable to authenticate with Firebase")
            } else {
                
                print("BALINT: Succesfully authenticated with Firebase")
                
                if let user = user {
                    
                    //azért raktunk ide credential.provider-t mert igy meg tudjuk különböztetni a facebook bejelentkezéseket. Amugy ha user.providerID-t rakunk akkor csak "Firebase" az eredmény
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            
            }
        })
    }

    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailField.text, let psw = passwordField.text {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: psw, completion: { (user, error) in
                if error == nil {
                    print("BALINT: Email user authenticated with Firebase")
                    
                    if let user = user {
                     
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: psw, completion: { (user, error) in
                        if error != nil {
                            print("BALINT: Unable to authenticate with Firebase using email")
                        } else {
                            print("BALINT: Succesfully authenticated with Firebase using email")
                            
                            if let user = user {
                                
                             let userData = ["provider": user.providerID]
                             self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {

        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("BALINT: Data saved to keychainresult: \(keychainResult)")
    
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

