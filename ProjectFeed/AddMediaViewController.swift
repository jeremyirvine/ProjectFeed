//
//  AddMediaViewController.swift
//  ProjectFeed
//
//  Created by Jeremy Irvine on 1/5/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit
import Alamofire

class AddMediaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var fData: NSArray = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pageCell")!
        let data = fData[indexPath.row] as! NSDictionary
        let text = data["name"] as! String
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = fData[indexPath.row] as! NSDictionary
        
        print("Selected: ", data["name"] as! String, "[", data["id"] as! String, "]")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBOutlet weak var FacebookView: UIView!
    
    @IBOutlet weak var facebookTableView: UITableView!
    @IBOutlet weak var facebookSearchField: UITextField!
    @IBOutlet weak var instagramBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
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
    
    
    
    @IBAction func facebookSearchBtnPressed(_ sender: Any) {
        print("Attempting Request...")
        var search = facebookSearchField.text!
        search = search.replacingOccurrences(of: " ", with: "%20")
        print("Request URL: https://graph.facebook.com/v2.11/search?q=\(search)&type=page&access_token=1885818195082007%7Cml3-08MDaLy3ZfUqUh4THDg99Wo")
        Alamofire.request("https://graph.facebook.com/v2.11/search?q=\(search)&type=page&access_token=1885818195082007%7Cml3-08MDaLy3ZfUqUh4THDg99Wo").responseJSON { response in
            if let data = response.result.value {
                let json = data as! NSDictionary
                print("Got Data: ")
                let search = json["data"]! as! NSArray
                self.fData = search
                self.facebookTableView.reloadData()
            }
        }
    }
    
    @IBAction func instagramBtnPressed(_ sender: Any) {
        FacebookView.isHidden = true
    }
    @IBAction func facebookBtnPressed(_ sender: Any) {
        FacebookView.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        facebookTableView.delegate = self
        facebookTableView.dataSource = self
        
    }
}
