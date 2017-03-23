//
//  ViewController.swift
//  RequestResponseMapper
//
//  Created by tcs on 3/21/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        APIController.sharedInstance.listUser("members.php") { (error) in
            if error == nil {
                DispatchQueue.main.async { [unowned self] in
                    self.tableView.reloadData()
                }
            } else {
                print(error.debugDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource {
    // MARK: TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APIController.sharedInstance.appInfo?[section].userItem?.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return APIController.sharedInstance.appInfo?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userInfoCell = tableView.dequeueReusableCell(withIdentifier: "USERINFO", for: indexPath) as! UserInfoCell
        userInfoCell.selectionStyle = .none

        if let appData = APIController.sharedInstance.appInfo?[indexPath.section].userItem?[indexPath.row] {
            userInfoCell.name.text = appData.name
            userInfoCell.email.text = appData.email
            userInfoCell.avatar.image(fromUrl: appData.photo)
        }

        return userInfoCell
    }
}


extension ViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return APIController.sharedInstance.appInfo?[section].name
    }
}

extension UIImageView {
    public func image(fromUrl urlString: String?) {
        guard let url = URL(string: urlString!) else {
            print("Couldn't create URL from \(urlString)")
            return
        }
        let theTask = URLSession.shared.dataTask(with: url) {
            data, response, error in
            if let response = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: response)
                }
            }
        }
        theTask.resume()
    }
}
