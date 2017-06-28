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

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            }
        })
    }

    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailField.text, let psw = passwordField.text {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: psw, completion: { (user, error) in
                if error == nil {
                    print("BALINT: Email user authenticated with Firebase")
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: psw, completion: { (user, error) in
                        if error != nil {
                            print("BALINT: Unable to authenticate with Firebase using email")
                        } else {
                            print("BALINT: Succesfully authenticated with Firebase using email")
                        }
                    })
                }
            })
        }
    }
}

