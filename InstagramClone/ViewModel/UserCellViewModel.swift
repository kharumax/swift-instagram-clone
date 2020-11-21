//
//  UserCellViewModel.swift
//  InstagramClone
//
//  Created by 久保田陽人 on 2020/11/13.
//

import Foundation

struct UserCellViewModel {
    private let user: User
    
    var porfileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var username: String {
        return user.username
    }
    
    var fullname: String {
        return user.fullname
    }
    
    init(user: User) {
        self.user = user
    }
}
