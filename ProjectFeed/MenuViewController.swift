//
//  LoginViewController.swift
//  ProjectFeed
//
//  Created by Jeremy Irvine on 1/5/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

extension MenuViewController: UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request:URLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        return checkRequestForCallbackURL(request: request)
    }
}
func checkRequestForCallbackURL(request: URLRequest) -> Bool {
    let requestURLString = (request.url?.absoluteString)! as String
    if requestURLString.hasPrefix(API.INSTAGRAM_REDIRECT_URI) {
        let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
        handleAuth(authToken: requestURLString.substring(from: range.upperBound))
        return false;
    }
    return true
}
func handleAuth(authToken: String) {
    print("Got Instagram Auth Token: ", authToken)
    UserDefaults.standard.set(authToken, forKey: "insta-token")
    UserDefaults.standard.synchronize()
}


class MenuViewController: UIViewController {
    
    @IBAction func instagramSkipButtonPressed(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "no-insta")
        InstagramLoginView.isHidden = true
    }
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var InstagramLoginView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        InstagramLoginView.isHidden = false
        if(UserDefaults.standard.object(forKey: "insta-token") != nil || UserDefaults.standard.bool(forKey: "no-insta")) {
            // Ask user to login to instagram...
            InstagramLoginView.isHidden = true
        }
    }
    
    
    func askInstaToken() {
        if(UserDefaults.standard.object(forKey: "insta-token") == nil) {
            let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [API.INSTAGRAM_AUTHURL,API.INSTAGRAM_CLIENT_ID,API.INSTAGRAM_REDIRECT_URI, API.INSTAGRAM_SCOPE])
            let urlRequest = URLRequest.init(url: URL.init(string: authURL)!)
            webView.delegate = self
            webView.loadRequest(urlRequest)
        } else {
            
        }
    }
}
