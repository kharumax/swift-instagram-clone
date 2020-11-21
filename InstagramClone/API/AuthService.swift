//
//  AuthService.swift
//  InstagramClone
//
//  Created by 久保田陽人 on 2020/11/11.
//

import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let prifileImage: UIImage
}

struct AuthService {
    
    static func logUserIn(withEmail email: String,password: String,completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    // staticメソッドはインスタンスではなく、クラス領域に定義するもの(全インスタンスで共有)
    // completion以下はクロージャー。@escapingを使うことで非同期かつ、関数完了後に呼ばれる
    static func registerUser(withCredential credentials: AuthCredentials,completion: @escaping(Error?) -> Void) {
        ImageUploader.uploadImage(image: credentials.prifileImage) { imageUrl in
            // ここの処理がImageUploaderの最後のcompletionで呼ばれる
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
                if let error = error {
                    print("DEBUG:  Failed to register user \(error.localizedDescription)")
                    return
                }
                guard let uid = result?.user.uid else { return }
                
                // FireStoremに送信するデータ
                let data: [String: Any] = ["email": credentials.email,"fullname": credentials.fullname,
                                           "username": credentials.username,"uid": uid,"profileImageUrl": imageUrl]
                
                // 下の処理を実行し、その結果をクロージャーに渡しクロージャーを実行する
                COLLECTION_USERS.document(uid).setData(data,completion: completion)
            }
        }
    }
    
    static func resetPassword(withEmail email: String,completion: SendPasswordResetCallback?) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
}
