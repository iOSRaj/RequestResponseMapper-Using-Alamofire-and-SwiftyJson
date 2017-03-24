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
    var reachability: Reachability?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Users"
        self.reachability = Reachability()
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }

        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
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
            userInfoCell.name.text = appData.name!+" (\(appData.role!))"
            userInfoCell.email.text = appData.email
            userInfoCell.avatar.image(fromUrl: appData.photo)

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.imagePressed(_:)))

            userInfoCell.avatar.isUserInteractionEnabled = true
            userInfoCell.avatar.tag = indexPath.row
            userInfoCell.avatar.addGestureRecognizer(tapGestureRecognizer)
        }

        return userInfoCell
    }

    func imagePressed(_ sender: UITapGestureRecognizer) {

        let overlay: UIView = UIView(frame: CGRect(x: 0, y: 50, width: self.view.frame.size.width, height: self.view.frame.size.height))

        overlay.backgroundColor = UIColor.black

        let imageView: UIImageView = UIImageView(image: (sender.view as! UIImageView).image) // This includes your image in table view cell
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 70, width: self.view.frame.size.width, height: 500)
        let doneBtn: UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 70, y: 18, width: 75, height: 75))
        doneBtn.setTitle("Close", for: .normal)
        doneBtn.setTitleColor(.red, for: .normal)
        doneBtn.addTarget(self, action: #selector(ViewController.removeView(sender:)), for: .touchUpInside)

        overlay.addSubview(imageView)
        overlay.addSubview(doneBtn)
        self.view.addSubview(overlay)
    }

    func removeView(sender: UIButton!) {
        sender.superview?.removeFromSuperview()
    }
}


extension ViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return APIController.sharedInstance.appInfo?[section].name
    }
}

extension ViewController {
    func loadUserInformation() {
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

}


extension ViewController {
    /**
 Check for Reachability
 
 - parameter note: post notification object to check for mode of reachability
 */
    func reachabilityChanged(_ note: Notification) {

        let reachability = note.object as! Reachability

        if reachability.isReachable {
            self.loadUserInformation()
            self.showNoInternetViewController()
        } else {
            // Not Reachable
            if (self.visbileViewController().isKind(of: ViewController.self)) {
                let next = self.storyboard?.instantiateViewController(withIdentifier: "NoInternet") as! NoInternetConnectionController
                self.present(next, animated: true, completion: nil)
            }
        }
    }

    /**
     Show No Internet View
     */
    func showNoInternetViewController() {
        if (self.visbileViewController().isKind(of: NoInternetConnectionController.self)) {
            dismiss(animated: true, completion: nil)
        }
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

// MARK: - View helpers
extension ViewController {
    func visbileViewController() -> UIViewController {
        return (self.navigationController?.visibleViewController)!
    }
}



