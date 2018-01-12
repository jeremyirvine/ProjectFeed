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
    var shouldLoadImages = false
    var selectedId: String?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pageCell")!
        let data = fData[indexPath.row] as! NSDictionary
        let text = data["name"] as! String
        cell.textLabel?.text = text
        print(data)
        if(shouldLoadImages) {
            
        } else {
            print("Not loading images")
        }
//        let url = URL(string: "https://graph.facebook.com/v2.11/\(data["id"]!)/picture?access_token=1885818195082007%7Cml3-08MDaLy3ZfUqUh4THDg99Wo")
//        print(url!)
//        let pdata = try? Data(contentsOf: url!)
//        cell.imageView?.image = UIImage(data: pdata!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = fData[indexPath.row] as! NSDictionary
        selectedId = data["id"] as! String
        performSegue(withIdentifier: "searchToView", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var newId = selectedId
        let vc = segue.destination as! ViewMediaViewController
        vc.selectedId = newId!
    }
    
    
    
    @IBAction func facebookSearchBtnPressed(_ sender: Any) {
        print("Attempting Request...")
        var search = facebookSearchField.text!
        search = search.replacingOccurrences(of: " ", with: "%20")
        print("Request URL: https://graph.facebook.com/v2.11/search?q=\(search)&type=page&access_token=1885818195082007%7Cml3-08MDaLy3ZfUqUh4THDg99Wo")
        Alamofire.request("https://graph.facebook.com/v2.11/search?q=\(search)&type=page&access_token=1885818195082007%7Cml3-08MDaLy3ZfUqUh4THDg99Wo").validate().responseJSON { response in
            switch(response.result) {
                case .failure(let err) :
                    print("Facebook Connection Error:", err)
                    break
                case .success:
                    if let data = response.result.value {
                        self.shouldLoadImages = false
                        let json = data as! NSDictionary
                        print("Got Data: ")
                        let search = json["data"]! as! NSArray
                        self.fData = search
                        
                        print("Reloading Table (For Text)...")
                        self.facebookTableView.reloadData()
                        
                        DispatchQueue.global(qos: .background).sync {
                            self.fData.forEach { dat_unserialized in
                                var dat = dat_unserialized as! NSDictionary
                                let url = URL(string: "https://graph.facebook.com/v2.11/\(dat["id"]!)/picture?access_token=1885818195082007%7Cml3-08MDaLy3ZfUqUh4THDg99Wo")
                                let data = try? Data(contentsOf: url!)
                                print("Got Picture:", data)
                            }
                        }
                    }
                    break
            }
        }
    }
    
    func writeImage(imgId: String, img: UIImage) {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(imgId).png")
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let pngImageData = UIImagePNGRepresentation(img) {
                    try pngImageData.write(to: fileURL, options: .atomic)
                }
            }else {
                print("File Cached, Skipping")
            }
            
        } catch { }
    }
    
    func readImage(imgId: String) -> UIImage {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(imgId).png").path
        if FileManager.default.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)!
        }
        return UIImage()
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
        
        Alamofire.request("https://graph.facebook.com/v2.11/Official.Jailbreak?access_token=1885818195082007%7Cml3-08MDaLy3ZfUqUh4THDg99Wo").validate().responseJSON { response in
            switch(response.result) {
                case .success:
                    break
                case .failure(let err):
                    print("Facebook Connection Failure:", err)
                    var alert = UIAlertController(title: "Error", message: "Failed to create a connection to social media", preferredStyle: UIAlertControllerStyle.alert)
                    self.present(alert, animated: true, completion: nil)
                    break
            }
        }
        
    }
}
