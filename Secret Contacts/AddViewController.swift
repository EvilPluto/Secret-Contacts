//
//  AddViewController.swift
//  Secret Contacts
//
//  Created by mac on 16/12/1.
//  Copyright © 2016年 pluto. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate {
    var contactForAdd: Person?
    var changeOrAdd: Int = 0 // 0 for add 1 for change

    @IBOutlet weak var headPic: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var detail: UITextView!
    @IBOutlet weak var favorite: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 圆形头像
        self.headPic.layer.cornerRadius = 50
        self.headPic.layer.masksToBounds = true
        self.headPic.layer.borderWidth = 3
        self.headPic.layer.borderColor = UIColor.lightGray.cgColor
        
        if let contact = self.contactForAdd {
            self.changeOrAdd = 1 // change
            self.navigationItem.title = contact.Name
            self.headPic.image = contact.HeadPic
            self.name.text = contact.Name
            self.phoneNum.text = contact.PhoneNum
            self.detail.text = contact.Details
            self.favorite.isHighlighted = contact.Favorite
        } else {
            self.changeOrAdd = 0 // add
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeHeadPic(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func changeFavorite(_ sender: Any) {
        self.favorite.isHighlighted = self.favorite.isHighlighted ? false : true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: false, completion: {
            let selectedImg = info[UIImagePickerControllerOriginalImage] as! UIImage
            let cropImage:VPImageCropperViewController =
                VPImageCropperViewController(
                    selectedImg,
                    cropFrame: CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: self.view.frame.size.width),
                    limitScaleRatio: 3.0
            )
            cropImage.delegate = self
            self.present(cropImage, animated: true, completion: nil)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imageCropper(_ cropperViewController: VPImageCropperViewController, didFinished editedImage: UIImage) {
        self.headPic.image = editedImage
        cropperViewController.dismiss(animated: true, completion: nil)
    }
    
    func imageCropperDidCancel(_ cropperViewController: VPImageCropperViewController) {
        cropperViewController.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveContact" {
            // 保存新联系人
            print("save!!!")
            
            self.contactForAdd = Person(
                name: self.name.text! == "" ? "# Unknown #" : self.name.text!,
                headPic: self.headPic.image,
                phoneNum: self.phoneNum.text! == "" ? "..." : self.phoneNum.text!,
                details: self.detail.text,
                favorite: self.favorite.isHighlighted
            )
        } else if segue.identifier == "cancelContact" {
            print("cancel!!!")
        }
    }
}
