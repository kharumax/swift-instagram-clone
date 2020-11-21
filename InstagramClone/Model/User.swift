//
//  User.swift
//  InstagramClone
//
//  Created by 久保田陽人 on 2020/11/12.
//

import Foundation
import Firebase

struct User {
    let email: String
    let fullname: String
    let profileImageUrl: String
    let username: String
    let uid: String
    
    var isFollowed = false
    var stats: UserStats!
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    
    init(dictionary: [String: Any]) {
        // [??]はデフォルトの値を与えている
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        
        self.stats = UserStats(followers: 0, follwoing: 0,posts: 0)
    }
}

struct UserStats {
    let followers: Int
    let follwoing: Int
    let posts: Int
}
