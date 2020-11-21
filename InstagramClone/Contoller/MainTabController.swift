//
//  MainTabController.swift
//  InstagramClone
//
//  Created by 久保田陽人 on 2020/11/10.
//

import UIKit
import Firebase
import YPImagePicker

class MainTabController: UITabBarController {
    
    // MARK: -- Lifecycle

    var user: User? {
        didSet {
            guard let user = user else { return }
            // user に変更があればここで呼ぶ
            configureViewController(withUser: user)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        // 初めはUserがnullなので、ここで呼ぶ
        fetchUser()
    }
    
    // MARK: -- API
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.fetchUser(withUid: uid) { (user) in
            self.user = user
        }
    }
    
    
    // ここでユーザーがログインしているかどうかを確認する
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            // DispathQueueはマルチスレッドで並列処理を行う。mainの場合はglobalより優先順位が上
            DispatchQueue.main.async {
                // コントローラーを指定して、移動している
                let controller = LoginController()
                // ここでデリゲートの委譲先を自分に設定して、LoginController側で実装されたメソッドを呼ぶ
                // AuthenticationDelegateを継承しているので[self]と記述できる
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: -- Helpers
    // 上の user の設定で呼ばれる
    func configureViewController(withUser user: User) {
        view.backgroundColor = .white
        self.delegate = self
        let layout = UICollectionViewFlowLayout() // CollectionViewを利用する際に必要
        let feed = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedController(collectionViewLayout: layout))
        let search = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchController())
        let imageSelector = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: ImageSelectController())
        let notifications = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationController())
        
        let profileController = ProfileController(user: user)
        let profile = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: profileController)
        
        viewControllers = [feed,search,imageSelector,notifications,profile]
        
        tabBar.tintColor = .black
    }
    
    func templateNavigationController(unselectedImage: UIImage,selectedImage: UIImage,rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        return nav
    }
    
    func didFinishPickingMedia(_ picker: YPImagePicker) {
        picker.didFinishPicking { (items, _) in
            picker.dismiss(animated: true) {
                guard let selectedImage = items.singlePhoto?.image else { return }
                let controller = UploadPostController()
                // ここで選択したイメージを渡す
                controller.selectedImage = selectedImage
                controller.currentUser = self.user
                // ここでdelegateを委譲する(share後の処理をこちらでうける)
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
            }
        }
    }
    
}

// MARK: -- AuthenticationDelegate
// MainTab側でLoginControllerで実装されたデリゲートメソッドを実行している
extension MainTabController: AuthenticationDelegate {
    func authenticateComplete() {
        // LoginControllerのボタンが押された時にFetchUserでuserを取得し、mainTabに移動する
        // ここでログアウト→ログイン時に再度、Userが更新されるようにしている
        // ViewDidLoadは最初にしか呼ばれないので。
        fetchUser()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: -- UITabBarControllerDelegate
extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            var config = YPImagePickerConfiguration()
            config.library.mediaType = .photo
            config.shouldSaveNewPicturesToAlbum = false
            config.startOnScreen = .library
            config.screens = [.library]
            config.hidesStatusBar = false
            config.hidesBottomBar = false
            config.library.maxNumberOfItems = 1
            
            let picker = YPImagePicker(configuration: config)
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
            
            didFinishPickingMedia(picker)
        }
        return true
    }
}

// MARK: -- UploadPostControllerDelegate

extension MainTabController: UploadPostControllerDelegate {
    func controllerDidFinishUploadingPost(_ controller: UploadPostController) {
        selectedIndex = 0
        controller.dismiss(animated: true, completion: nil)
        
        guard let feedNav = viewControllers?.first as? UINavigationController else { return }
        guard let feed = feedNav.viewControllers.first as? FeedController else { return }
        feed.handleRefresh()
    }
}
