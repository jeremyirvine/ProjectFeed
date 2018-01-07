//
//  PreAddMediaViewController.swift
//  ProjectFeed
//
//  Created by Jeremy Irvine on 1/6/18.
//  Copyright © 2018 Bamboo Technologies. All rights reserved.
//

import UIKit

class ViewMediaViewController: UIViewController {
    var selectedId: String = ""
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedId)
        let url = URL(string: "https://graph.facebook.com/v2.11/\(selectedId)/picture?access_token=1885818195082007%7Cml3-08MDaLy3ZfUqUh4THDg99Wo")
        let data = try? Data(contentsOf: url!)
        print(data)
        userImage.image = UIImage(data: data!)
    }
    @IBAction func dismissBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
