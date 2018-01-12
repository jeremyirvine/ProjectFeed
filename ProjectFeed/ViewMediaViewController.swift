//
//  PreAddMediaViewController.swift
//  ProjectFeed
//
//  Created by Jeremy Irvine on 1/6/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit
import Alamofire

class ViewMediaViewController: UIViewController {
    var selectedId: String = ""
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var pageName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedId)
        let url = URL(string: "https://graph.facebook.com/v2.11/\(selectedId)/picture?access_token=1885818195082007%7Cml3-08MDaLy3ZfUqUh4THDg99Wo")
        let data = try? Data(contentsOf: url!)
        print(data)
        userImage.image = UIImage(data: data!)
        Alamofire.request("https://graph.facebook.com/v2.11/\(selectedId)?access_token=1885818195082007%7Cml3-08MDaLy3ZfUqUh4THDg99Wo&fields=id,name").responseJSON { response in
            if let data = response.result.value {
                let json = data as! NSDictionary
                self.pageName.text = json["name"] as! String
                
            }
        }
    }
    @IBAction func addBtnPressed(_ sender: Any) {
        // Get Array from UserDefaults
        var data = UserDefaults.standard.array(forKey: "socials")
        
        // Push object
        data?.append(selectedId)
        
        UserDefaults.standard.set(data, forKey: "socials")
        
        print(UserDefaults.standard.array(forKey: "socials"))
    }
    @IBAction func dismissBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
