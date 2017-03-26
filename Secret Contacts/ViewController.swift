//
//  ViewController.swift
//  Secret Contacts
//
//  Created by mac on 16/11/21.
//  Copyright © 2016年 pluto. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var array = [
    "HxH", "SD", "XHK", "SSY"
    ]

    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shadowView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapShadow(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.shadowView.alpha = 0
            self.contactView.layer.setAffineTransform(CGAffineTransform(translationX: 0, y: 280));
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.array.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = array[indexPath.row]
        cell.textLabel?.textColor = .blue
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Path: \(indexPath.row)")
        UIView.animate(withDuration: 0.5, animations: {
            self.shadowView.alpha = 0.5
            self.contactView.layer.setAffineTransform(CGAffineTransform(translationX: 0, y: -280));
        })
        self.navigationController?.navigationItem.title = "2333"
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.array.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
}

