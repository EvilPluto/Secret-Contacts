//
//  ContactsViewController.swift
//  Secret Contacts
//
//  Created by mac on 16/11/29.
//  Copyright © 2016年 pluto. All rights reserved.
//

import UIKit

// 扩展获取首字母
extension String {
    var first: String {
        get {
            return (self.capitalized.trimmingCharacters(in: .whitespaces) as NSString).substring(to: 1)
        }
    }
}

///    聊天主页面
///
///    -  selectedIndex           :用于保存当前选择的cell
///    -  searchOrNot             :用于确定当前tableView


class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    let defaultPic: UIImage = UIImage()
    var selectedIndex: IndexPath? // 用于保存当前选择的cell
    var searchOrNot: Bool = false // 用于确定当前tableView
    
    var sectionHeaders: [String] = headers
    
    var array: [String: [Person]]!
    
    // search展示界面全部元素
    var arrayForSearch: [Person]!
    
    // search展示界面搜到的元素
    var arrayForSearched: [Person]!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var contactSearchBar: UISearchBar!
    
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var contactTable: UITableView!
    
    
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactNum: UILabel!
    @IBOutlet weak var contactHeadPic: UIImageView!
    @IBOutlet weak var contactDetails: UILabel!
    @IBOutlet weak var contactFavorite: UIImageView!
    
    func loadContacts() -> [String: [Person]] {
        if let file = NSKeyedUnarchiver.unarchiveObject(withFile: Person.path) {
            return file as! [String: [Person]]
        } else {
            print("file load failed!")
            let file: [String: [Person]] = Persons
            return file
        }
    }
    
    func updateSearchContacts() -> [Person] {
        var searchArray: [Person] = []
        for (_, value) in self.array {
            searchArray.append(contentsOf: value)
        }
        return searchArray
    }
    
    func saveContacts() {
        let queue = DispatchQueue(label: "信息操作")
        queue.async {
            let success = NSKeyedArchiver.archiveRootObject(self.array, toFile: Person.path)
            if !success {
                print("file save failed!")
            } else {
                print("file save successful!")
            }
            DispatchQueue.main.sync {
                let alert = UIAlertController(title: "状态", message: "数据化成功", preferredStyle: .alert)
                let action = UIAlertAction(title: "知道了", style: .default, handler: nil)
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
            }
        }

    }
    
    // MARK: - 下拉更新列表
    func update() {
        if let _ = self.tableView.refreshControl {
            self.array = self.loadContacts()
            for (key, arrayForSort) in self.array {
                self.array[key] = arrayForSort.sorted(by: {
                    return $0.Name < $1.Name
                })
            }
            self.arrayForSearch = self.updateSearchContacts()
            self.arrayForSearch = self.arrayForSearch.sorted(by: { (person1: Person, person2: Person) -> Bool in
                return person1.Name < person2.Name
            })
            self.arrayForSearched = self.arrayForSearch
            self.tableView.reloadData()
            self.perform(#selector(self.updateEnd), with: self.self, afterDelay: 2.0)
        }
    }
    
    // TODO: 更新结束回调
    func updateEnd() {
        let format: DateFormatter = DateFormatter()
        format.dateFormat = "MMM d, h:mm a"
        let title: String = "Last update: \(format.string(from: Date()))"
        let attrsDic: NSDictionary = NSDictionary(object: UIColor.white, forKey: NSForegroundColorAttributeName as NSCopying)
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDic as? [String : Any])
        self.tableView.refreshControl?.attributedTitle = attributedTitle
        
        self.tableView.refreshControl?.endRefreshing()
    }
    
    override func viewDidLoad() {
        self.array = self.loadContacts()
        self.arrayForSearch = self.updateSearchContacts()
        self.arrayForSearched = self.arrayForSearch // 此处为值传递而非引用
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "ContactCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "contactCell")

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.sectionIndexColor = .blue
        self.tableView.sectionIndexTrackingBackgroundColor = .lightGray
        self.tableView.sectionIndexBackgroundColor = .clear
        
        self.contactHeadPic.layer.cornerRadius = 64
        self.contactHeadPic.layer.masksToBounds = true
        self.contactHeadPic.layer.borderColor = UIColor.gray.cgColor
        self.contactHeadPic.layer.borderWidth = 2
        
        self.contactSearchBar.delegate = self
        
        self.searchTable.dataSource = self
        self.searchTable.delegate = self
        
        // 添加刷新
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.backgroundColor = .black
        self.tableView.refreshControl?.tintColor = .white
        self.tableView.refreshControl?.addTarget(self, action: #selector(self.update), for: .valueChanged)
        
        let format: DateFormatter = DateFormatter()
        format.dateFormat = "MMM d, h:mm a"
        let title: String = "Last update: \(format.string(from: Date()))"
        let attrsDic: NSDictionary = NSDictionary(object: UIColor.white, forKey: NSForegroundColorAttributeName as NSCopying)
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDic as? [String : Any])
        self.tableView.refreshControl?.attributedTitle = attributedTitle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - 点击阴影部分，缩回页面
    @IBAction func tapShadow(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.shadowView.alpha = 0
            self.contactView.layer.setAffineTransform(CGAffineTransform(translationX: 0, y: 380));
        })
        if self.searchOrNot {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.title = "Contacts"
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.title = "Contacts"
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        }
    }
    
    // MARK: - 点击收藏
    @IBAction func tapFavorite(_ sender: Any) {
        self.contactFavorite.isHighlighted =  self.contactFavorite.isHighlighted ? false : true
        if self.searchOrNot {
            self.arrayForSearched[self.selectedIndex!.row].Favorite = self.contactFavorite.isHighlighted
            self.searchTable.reloadData()
        } else {
            self.array[sectionHeaders[self.selectedIndex!.section]]![self.selectedIndex!.row].Favorite = self.contactFavorite.isHighlighted
        }
        self.saveContacts() // 保存数据
    }
    
    // MARK: - UITableViewDataSource | UITableViewDelegate 重载方法
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if tableView.isEqual(self.searchTable) {
            return 1
        } else {
            return self.sectionHeaders.count
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView.isEqual(self.searchTable) {
            return nil
        } else {
            return self.sectionHeaders
        }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var tapIndex: Int = 0
        for char in self.sectionHeaders {
            if char == title {
                return tapIndex
            }
            tapIndex += 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.isEqual(self.searchTable) {
            return nil
        } else {
            return self.sectionHeaders[section]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableView.isEqual(self.searchTable) {
            return self.arrayForSearched.count
        } else {
            return self.array[sectionHeaders[section]]!.count
        }
    }

    // TODO: 绘制Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEqual(self.searchTable) {
            let searchCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            searchCell.textLabel?.text = self.arrayForSearched[indexPath.row].Name
            searchCell.accessoryType = .detailButton
            
            if self.arrayForSearched[indexPath.row].Favorite {
                searchCell.textLabel?.textColor = .orange
                searchCell.textLabel?.text = self.arrayForSearched[indexPath.row].Name + " ⭐️"
            } else {
                searchCell.textLabel?.textColor = .black
                searchCell.textLabel?.text = self.arrayForSearched[indexPath.row].Name
            }
            
            return searchCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell
            cell.firstLabel.text = self.sectionHeaders[indexPath.section]
            cell.name.text = array[sectionHeaders[indexPath.section]]?[indexPath.row].Name
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath // 保存最新的选择的IndexPath
        
        if tableView.isEqual(self.searchTable) {
            let selectedPerson: Person = self.arrayForSearched[indexPath.row]
            if let pic = selectedPerson.HeadPic {
                self.contactHeadPic.image = pic
            } else {
                self.contactHeadPic.image = self.defaultPic
            }
            if selectedPerson.Favorite {
                self.contactFavorite.isHighlighted = true
            } else {
                self.contactFavorite.isHighlighted = false
            }
            self.contactNum.text = selectedPerson.PhoneNum
            self.contactName.text = selectedPerson.Name
            self.contactDetails.text = selectedPerson.Details
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    self.shadowView.alpha = 0.5
                    self.contactView.layer.setAffineTransform(CGAffineTransform(translationX: 0, y: -380));
            },
                completion: { (finished: Bool) -> Void in
                    self.navigationItem.title = self.arrayForSearched[indexPath.row].Name
                    self.navigationItem.leftBarButtonItem?.isEnabled = true
            })
        } else {
            let selectedPerson: Person = array[self.sectionHeaders[indexPath.section]]![indexPath.row]
            if let pic = selectedPerson.HeadPic {
                self.contactHeadPic.image = pic
            } else {
                self.contactHeadPic.image = self.defaultPic
            }
            if selectedPerson.Favorite {
                self.contactFavorite.isHighlighted = true
            } else {
                self.contactFavorite.isHighlighted = false
            }
            self.contactNum.text = selectedPerson.PhoneNum
            self.contactName.text = selectedPerson.Name
            self.contactDetails.text = selectedPerson.Details
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    self.shadowView.alpha = 0.5
                    self.contactView.layer.setAffineTransform(CGAffineTransform(translationX: 0, y: -380));
            },
                completion: { (finished: Bool) -> Void in
                    self.navigationItem.title = self.array[self.sectionHeaders[indexPath.section]]![indexPath.row].Name
                    self.navigationItem.leftBarButtonItem?.isEnabled = true
            })
        }
    }
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if tableView.isEqual(self.searchTable) {
            return false
        } else {
            return true
        }
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let name = self.array[sectionHeaders[indexPath.section]]![indexPath.row].Name
            self.array[sectionHeaders[indexPath.section]]!.remove(at: indexPath.row)
            var count: Int = 0
            for person in self.arrayForSearch {
                if person.Name == name {
                    self.arrayForSearch.remove(at: count)
                    self.arrayForSearched.remove(at: count)
                }
                count += 1
            }
            self.saveContacts() // 保存
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.isEqual(self.searchTable) {
            return 0
        } else {
            if self.array[self.sectionHeaders[section]]!.count == 0 {
                return 0
            } else {
                return 50
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.searchTable.alpha = 1
        })
        self.searchTable.reloadData()
        self.searchOrNot = true // 当前在搜索页面
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        UIView.animate(withDuration: 0.5, animations: {
            self.searchTable.alpha = 0
        })
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.arrayForSearched = self.arrayForSearch
        self.searchOrNot = false // 当前不在搜索页面
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arrayForSearched = []
        if searchText == "" {
            self.arrayForSearched = self.arrayForSearch
            self.searchTable.reloadData()
        } else {
            for item in self.arrayForSearch {
                if (item.Name.lowercased().range(of: searchText.lowercased()) != nil) {
                    self.arrayForSearched.append(item)
                }
            }
            self.searchTable.reloadData()
        }
    }

    @IBAction func saveToContactsList(segue: UIStoryboardSegue) {
        if let addContact = segue.source as? AddViewController {
            if let contactForAdd = addContact.contactForAdd {
                if addContact.changeOrAdd == 0 {
                    // for Add
                    let name = contactForAdd.Name
                    var headerIn: Bool = false // 用于判断名字头是否存在
                    for header in self.sectionHeaders {
                        if header == name.first.uppercased() {
                            headerIn = true
                            self.array[header]?.append(contactForAdd)
                            break
                        }
                    }
                    if !headerIn {
                        self.array["#"]?.append(contactForAdd)
                    }
                    
                    self.arrayForSearch.append(contactForAdd)
                    self.arrayForSearched.append(contactForAdd)
            
                    self.tableView.reloadData()
                } else {
                    // for change
                    if self.searchOrNot {
                        let contactLast: Person = self.arrayForSearched[self.selectedIndex!.row] // 保存被修改之前的Person信息
                        self.arrayForSearched[self.selectedIndex!.row] = contactForAdd
                        
                        // 更新search库
                        var count = 0
                        for item in self.arrayForSearch {
                            if item.Name == contactLast.Name {
                                self.arrayForSearch[count] = contactForAdd
                            }
                            count += 1
                        }
                        
                        // 更新contact界面库
                        var hasHeader: Bool = false
                        var head: String = "" // 用于保存名头
                        var arrayHeader: [Person] = [] // 用于保存当前名字头的那个Dic中的数组
                        for header in self.sectionHeaders {
                            if header == contactLast.Name.first.uppercased() {
                                hasHeader = true
                                head = header
                                arrayHeader = self.array[header]!
                                break
                            }
                        }
                        if !hasHeader {
                            arrayHeader = self.array["#"]!
                            head = "#"
                        }
                        
                        // 在contact库中删除原contact建立新的contact达到change效果
                        var index: Int = 0
                        for item in arrayHeader {
                            if item.Name == contactLast.Name {
                                self.array[head]!.remove(at: index)
                            }
                            index += 1
                        }
                        
                        for header in self.sectionHeaders {
                            if header == contactForAdd.Name.first.uppercased() {
                                head = header
                                hasHeader = true
                                break
                            }
                        }
                        if !hasHeader {
                            head = "#"
                        }
                        self.array[head]!.append(contactForAdd)
                    } else {
                        let contactLast: Person = self.array[sectionHeaders[self.selectedIndex!.section]]![self.selectedIndex!.row] // 记录之前的信息
                        self.array[sectionHeaders[self.selectedIndex!.section]]!.remove(at: self.selectedIndex!.row)
                        
                        var head: String = "" // 保存新的名字头
                        var hasHeader: Bool = false
                        for header in self.sectionHeaders {
                            if header == contactForAdd.Name.first.uppercased() {
                                head = header
                                hasHeader = true
                                break
                            }
                        }
                        if !hasHeader {
                            head = "#"
                        }
                        self.array[head]!.append(contactForAdd)
                        
                        var count: Int = 0
                        for item in self.arrayForSearch {
                            if item.Name == contactLast.Name {
                                self.arrayForSearch.remove(at: count)
                                self.arrayForSearched.remove(at: count)
                                break
                            }
                            count += 1
                        }
                        
                        self.arrayForSearch.append(contactForAdd)
                        self.arrayForSearched.append(contactForAdd)
                    }
                    
                    self.contactNum.text = contactForAdd.PhoneNum
                    self.contactName.text = contactForAdd.Name
                    self.contactHeadPic.image = contactForAdd.HeadPic
                    self.contactDetails.text = contactForAdd.Details
                    if contactForAdd.Favorite {
                        self.contactFavorite.isHighlighted = true
                    } else {
                        self.contactFavorite.isHighlighted = false
                    }
                }
                
                self.saveContacts() // 数据本地化
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func cancelToContactsList(segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeContact" {
            // 改变信息
            print("Change")
            let changeContact: AddViewController = segue.destination as! AddViewController
            
            let contact: Person
            if self.searchOrNot {
                contact = self.arrayForSearched[self.selectedIndex!.row]
            } else {
                contact = self.array[sectionHeaders[self.selectedIndex!.section]]![self.selectedIndex!.row]
            }
            changeContact.contactForAdd = Person(
                name: contact.Name,
                headPic: contact.HeadPic,
                phoneNum: contact.PhoneNum,
                details: contact.Details,
                favorite: contact.Favorite
            )
        }
    }
}
