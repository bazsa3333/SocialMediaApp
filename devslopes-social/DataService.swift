//
//  DataService.swift
//  devslopes-social
//
//  Created by Németh Bálint on 2017. 07. 04..
//  Copyright © 2017. Németh Bálint. All rights reserved.
//

import Foundation
import Firebase

//URL of the database - reference - u can find it in the gooleservice-info.plist
let DB_BASE = FIRDatabase.database().reference()

class DataService {
    
    //create the singelton - everyone has access to it
    static let ds = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POST: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        
        REF_USERS.child(uid).updateChildValues(userData)
    }
}
