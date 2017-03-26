//
//  ContactCell.swift
//  Secret Contacts
//
//  Created by mac on 16/12/3.
//  Copyright © 2016年 pluto. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    let colorArray: [UIColor] = [
        UIColor.blue, UIColor.green, UIColor.yellow, UIColor.gray, UIColor.purple, UIColor.brown, UIColor.darkGray, UIColor.lightGray, UIColor.magenta, UIColor.orange, UIColor.red
    ]

    @IBOutlet weak var headPic: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.headPic.layer.cornerRadius = 16
        self.headPic.layer.masksToBounds = true
        self.firstLabel.font = UIFont(name: "AmericanTypewriter", size: 25) ?? UIFont.systemFont(ofSize: 25)
        self.headPic.backgroundColor = colorArray[Int(arc4random_uniform(11))]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
