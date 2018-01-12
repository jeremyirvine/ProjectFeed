//
//  ViewController.swift
//  ProjectFeed
//
//  Created by Jeremy Irvine on 1/4/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit
import Alamofire


class ViewController: UIViewController {
    var canLogin = false
    
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var loginBtn: UIButton!
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        loginSpinner.isHidden = true
        loginSpinner.startAnimating()
        print("username: \(UserDefaults.standard.object(forKey: "username")), key: \(UserDefaults.standard.object(forKey: "key"))")
        var shouldCont = true
        var errFacebook = false
        var errInstagram = false
        doLoginInit()
//        Alamofire.request("https://graph.facebook.com/v2.11/57559012857?access_token=1885818195082007%7Cml3-08MDaLy3ZfUqUh4THDg99Wo&fields=id,name").validate().responseJSON { response in
//            switch response.result {
//                case .failure(let error):
//                    let alert = UIAlertController(title: "Error", message: "Could not connect to social media, please try again later", preferredStyle: .alert)
//                    self.present(alert, animated: true, completion: nil)
//                    print("Facebook encountered an error:", error)
//                    shouldCont = false
//                    errFacebook = true
//                case .success:
//                    print("Connection to facebook verified")
//                    self.doLoginInit()
//            }
//        }
        
    }
    
    func doLoginInit() {
        if(UserDefaults.standard.object(forKey: "username") == nil || UserDefaults.standard.object(forKey: "key") == nil) {
            // Not logged in...
            canLogin = true
        } else if (UserDefaults.standard.object(forKey: "username") != nil && UserDefaults.standard.object(forKey: "key") != nil) {
            // Logged in...
            
            loginSpinner.isHidden = false
            usernameField.isHidden = true
            passwordField.isHidden = true
            loginBtn.isEnabled = false
            
            
            let username = UserDefaults.standard.object(forKey: "username")!
            let key = UserDefaults.standard.object(forKey: "key")!
            Alamofire.request("https://bamboo-us.com/ProjectFeed/login.php?u=\(username)&k=\(key)").responseJSON { response in
                if let data = response.result.value {
                    let json = data as! NSDictionary
                    print(json["status"] as! String)
                    if (json["status"] as! String == "success") {
                        self.performSegue(withIdentifier: "landingToMenu", sender: self)
                    } else {
                        UserDefaults.standard.removeObject(forKey: "username")
                        UserDefaults.standard.removeObject(forKey: "key")
                        UserDefaults.standard.synchronize()
                        self.loginSpinner.isHidden = true
                        self.usernameField.isHidden = false
                        self.passwordField.isHidden = false
                        self.loginBtn.isEnabled = true
                        self.loginSpinner.stopAnimating()
                    }
                }
            }
        }
    }

    @IBAction func loginBtnPressed(_ sender: Any) {
        if(canLogin) {
            self.view.endEditing(true)
            loginSpinner.isHidden = false
            usernameField.isHidden = true
            passwordField.isHidden = true
            loginBtn.isEnabled = false
            print("Attempting to create a request...")
            if let username = usernameField.text, let password = passwordField.text {
                print("Request URL: https://bamboo-us.com/ProjectFeed/login.php?u=\(username)&p=\(password)")
                Alamofire.request("https://bamboo-us.com/ProjectFeed/login.php?u=\(username)&p=\(password)").responseJSON { response in
                    if let data = response.result.value {
                        let JSON = data as! NSDictionary
                        let status = JSON["status"] as! String
                        if(status == "err_data_mismatch") {
                            
                        } else if (status == "success") {
                            let key = JSON["key"] as! String
                            UserDefaults.standard.set(key, forKey: "key")
                            UserDefaults.standard.set(username, forKey: "username")
                            UserDefaults.standard.synchronize()
                            
                            let username = UserDefaults.standard.object(forKey: "username")!
                            Alamofire.request("https://bamboo-us.com/ProjectFeed/login.php?u=\(username)&k=\(key)").responseJSON { response in
                                if let data = response.result.value {
                                    let json = data as! NSDictionary
                                    print(json["status"] as! String)
                                    if (json["status"] as! String == "success") {
                                        UserDefaults.standard.set(json["instaKey"] as! String, forKey: "insta-token")
                                        UserDefaults.standard.synchronize()
                                        self.performSegue(withIdentifier: "landingToMenu", sender: self)
                                    } else {
                                        UserDefaults.standard.removeObject(forKey: "username")
                                        UserDefaults.standard.removeObject(forKey: "key")
                                        UserDefaults.standard.synchronize()
                                        self.loginSpinner.isHidden = true
                                        self.usernameField.isHidden = false
                                        self.passwordField.isHidden = false
                                        self.loginBtn.isEnabled = true
                                        self.loginSpinner.stopAnimating()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            print("Cannot login, verifying credentials...")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

