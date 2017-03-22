//
//  ViewController.swift
//  RequestResponseMapper
//
//  Created by tcs on 3/21/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
         APIController.sharedInstance.listUser("") { (error) in
            if error == nil {
                 DispatchQueue.main.async { [unowned self] in
                    self.tableView.reloadData()
                }
            } else {
                
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
        let appInfoCell = tableView.dequeueReusableCell(withIdentifier: "APPINFO", for: indexPath) as! AppInfoCell
        appInfoCell.selectionStyle = .none
      
        if let appData = APIController.sharedInstance.appInfo?[indexPath.section].userItem?[indexPath.row] {
            appInfoCell.textLabel?.text = appData.name
            appInfoCell.detailTextLabel?.text = appData.email
        }
        return appInfoCell
    }
}


extension ViewController: UITableViewDelegate {
    // MARK: TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         return APIController.sharedInstance.appInfo?[section].name
    }
}
