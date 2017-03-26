//
//  Person.swift
//  Secret Contacts
//
//  Created by mac on 16/11/24.
//  Copyright © 2016年 pluto. All rights reserved.
//

import Foundation
import UIKit

class Person: NSObject, NSCoding {
    var Name: String
    var HeadPic: UIImage?
    var PhoneNum: String
    var Details: String
    var Favorite: Bool = false
    
    // 获取Document的url，最后为string格式
    static let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)).first! as String
    static let path = paths.appending("/ContactsData.plist")
    
    init(name: String, headPic: UIImage?, phoneNum: String, details: String, favorite: Bool) {
        self.Name = name
        self.HeadPic = headPic
        self.PhoneNum = phoneNum
        self.Details = details
        self.Favorite = favorite
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.Name = aDecoder.decodeObject(forKey: "Name") as! String
        self.HeadPic = aDecoder.decodeObject(forKey: "HeadPic") as! UIImage?
        self.PhoneNum = aDecoder.decodeObject(forKey: "PhoneNum") as! String
        self.Details = aDecoder.decodeObject(forKey: "Details") as! String
        self.Favorite = aDecoder.decodeBool(forKey: "Favorite")
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.Name, forKey: "Name")
        aCoder.encode(self.HeadPic, forKey: "HeadPic")
        aCoder.encode(self.PhoneNum, forKey: "PhoneNum")
        aCoder.encode(self.Details, forKey: "Details")
        aCoder.encode(self.Favorite, forKey: "Favorite")
    }
}
