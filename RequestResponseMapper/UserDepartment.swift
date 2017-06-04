//
//  UserDepartment.swift
//  RequestResponseMapper
//
//  Created by tcs on 3/22/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import Foundation
import SwiftyJSON
public class UserDepartment: NSObject {

    // MARK: Properties
    public var name: String?
    public var userItem: [UserItem]?

    /*
    Initates the class based on the JSON that was passed.
    - parameter json: JSON object from SwiftyJSON.
    - returns: An initalized instance of the class.
    */

    public init(userJson: [[String: AnyObject]], title: String) {
        self.name = title
        self.userItem = []
        for userValue in userJson {
            self.userItem?.append(UserItem(json: userValue))
        }
    }
}

