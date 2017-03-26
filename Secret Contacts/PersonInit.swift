//
//  PersonInit.swift
//  Secret Contacts
//
//  Created by mac on 16/12/11.
//  Copyright © 2016年 pluto. All rights reserved.
//

import Foundation
import UIKit

var Persons: [String: [Person]] = [
    "#": [],
    "A": [
        Person(name: "Abraham Lincoln", headPic: nil, phoneNum: "18090212000", details: "美国总统", favorite: false),
        Person(name: "Alubar", headPic: nil, phoneNum: "18090212666", details: "阿鲁巴", favorite: false)
    ],
    "B": [],
    "C": [],
    "D": [],
    "E": [],
    "F": [],
    "G": [],
    "H": [
        Person(name: "Helen Keller", headPic: nil, phoneNum: "13358806910", details: "著名女作家", favorite: false)
    ],
    "I": [],
    "J": [],
    "K": [],
    "L": [],
    "M": [],
    "N": [],
    "O": [],
    "P": [],
    "Q": [],
    "R": [],
    "S": [],
    "T": [],
    "U": [],
    "V": [],
    "W": [
        Person(name: "William Shakespeare", headPic: nil, phoneNum: "15640423111", details: "著名作家", favorite: false)
    ],
    "X": [],
    "Y": [],
    "Z": []
]

var searchPerson: [Person] = [
    Person(name: "Abraham Lincoln", headPic: nil, phoneNum: "18090212000", details: "美国总统", favorite: false),
    Person(name: "Alubar", headPic: nil, phoneNum: "18090212666", details: "阿鲁巴", favorite: false),
    Person(name: "Helen Keller", headPic: nil, phoneNum: "13358806910", details: "著名女作家", favorite: false),
    Person(name: "William Shakespeare", headPic: nil, phoneNum: "15640423111", details: "著名作家", favorite: false)
]

let headers: [String] = [
    "#", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y" ,"Z"
]
