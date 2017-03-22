//
//  UserItem.swift
//  RequestResponseMapper
//
//  Created by tcs on 3/22/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import Foundation
import  SwiftyJSON

public class UserItem: NSObject {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    internal let knameKey: String = "name"
    internal let ksurnameKey: String = "surname"
    internal let kemailKey: String = "email"
    internal let kphotoKey: String = "photo"
    internal let kroleKey: String = "role"
    
    // MARK: Properties
    public var name: String?
    public var surname: String?
    public var email: String?
    public var photo: String?
    public var role: String?
       /**
     Initates the class based on the JSON that was passed.
     - parameter json: JSON object from SwiftyJSON.
     - returns: An initalized instance of the class.
     */
    public init(json: [String:AnyObject]) {
        self.name = json[knameKey] as? String
        self.surname = json[ksurnameKey] as? String
        self.email =  json[kemailKey] as? String
        self.role = json[kroleKey] as? String
        self.photo = json[kphotoKey]as? String
    }
    
    
}
