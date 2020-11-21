//
//  ProfileHeaderViewModel.swift
//  InstagramClone
//
//  Created by 久保田陽人 on 2020/11/12.
//

import Foundation
import UIKit

struct ProfileHeaderViewModel {
    let user: User
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var followButtonText: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor: UIColor {
        return user.isCurrentUser ? .white : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        return user.isCurrentUser ? .black : .white
    }
    
    var numberOfFollowers: NSAttributedString {
        return attributedStackText(value: user.stats.followers, label: "followers")
    }
    
    var numberOfFollowing: NSAttributedString {
        return attributedStackText(value: user.stats.follwoing, label: "following")
    }
    
    var numberOfPosts: NSAttributedString {
        return attributedStackText(value: user.stats.posts, label: "posts")
    }
    
    init(user: User) {
        self.user = user
    }
    
    func attributedStackText(value: Int,label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value)\n",attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: label,attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
}
