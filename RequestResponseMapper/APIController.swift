//
//  APIController.swift
//  RequestResponseMapper
//
//  Created by tcs on 3/22/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let baseURL = "http://nielsmouthaan.nl/backbase/"

class APIController {

    var appInfo: [UserDepartment]?

    static let sharedInstance: APIController = APIController()
    var arrRes = [[String: AnyObject]]()


    func listUser(_ requestPath: String, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(baseURL + requestPath).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                self.appInfo = []

                if let resData = swiftyJsonVar["Launchpad"].arrayObject {
                    self.arrRes = resData as! [[String: AnyObject]]
                    let appList: UserDepartment = UserDepartment(userJson: self.arrRes, title: "Launchpad")
                    self.appInfo?.append(appList)
                }

                if let resData = swiftyJsonVar["CXP"].arrayObject {
                    self.arrRes = resData as! [[String: AnyObject]]
                    let appList: UserDepartment = UserDepartment(userJson: self.arrRes, title: "CXP")
                    self.appInfo?.append(appList)
                }

                if let resData = swiftyJsonVar["Mobile"].arrayObject {
                    self.arrRes = resData as! [[String: AnyObject]]
                    let appList: UserDepartment = UserDepartment(userJson: self.arrRes, title: "Mobile")
                    self.appInfo?.append(appList)
                }

                 completionHandler(nil)
            } else {
                 completionHandler(responseData.result.error as NSError?)
            }
        }
    }
}
