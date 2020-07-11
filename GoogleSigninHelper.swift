//
//  GoogleSigninHelper.swift
//  SocialLogins
//
//  Created by Ongraph on 21/11/19.
//  Copyright © 2019 Ongraph. All rights reserved.
//

import Foundation
import GoogleSignIn



final class GoogleSignInHelper : NSObject {
    
    static var shared = GoogleSignInHelper()
    typealias GoogleCompletion = ((_ user: GoogleUser) -> Void)
    private var completion : GoogleCompletion?
    let rootVC = UIApplication.shared.windows.first?.rootViewController
    
    private override init() {
        super.init()
        GIDSignIn.sharedInstance().delegate = self
    }
    
    // MARK:- call this function to login eg. GoogleSignInHelper.shared.loginWith(client...  ....)
    public func loginWith(clientID : String ,completion aCompletion: GoogleCompletion?) {
        GIDSignIn.sharedInstance()?.presentingViewController = rootVC
        GIDSignIn.sharedInstance()?.clientID = clientID
        self.completion = aCompletion
        GIDSignIn.sharedInstance()?.signIn()

    }
    
    
//
    public struct GoogleUser {
        public var userId: String?
        public var idToken : String?
        public var fullName : String?
        public var givenName : String?
        public var familyName : String?
        public var email : String?
        public var imageUrl : URL?

        init(with user : GIDGoogleUser) {
            self.userId = user.userID                  // For client-side use only!
            self.idToken = user.authentication.idToken // Safe to send to the server
            self.fullName = user.profile.name
            self.givenName = user.profile.givenName
            self.familyName = user.profile.familyName
            self.email = user.profile.email
            self.imageUrl = user.profile.imageURL(withDimension: 200)
        }
    }
}


extension GoogleSignInHelper : GIDSignInDelegate  {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        let user = GoogleUser.init(with: user)
        self.completion?(user)
        DispatchQueue.main.async {
            GIDSignIn.sharedInstance().signOut()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        let alert = UIAlertController.init(title: "Google SignIn Error!", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.rootVC?.present(alert, animated: true, completion: nil)
    }
}
