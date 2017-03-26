//
//  RootTabBarController.swift
//  Secret Contacts
//
//  Created by mac on 16/11/29.
//  Copyright © 2016年 pluto. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {
    var viewsArray: [UIViewController]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewsArray = self.viewControllers
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(RootTabBarController.lastPage(_:)))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(RootTabBarController.nextPage(_:)))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)
        
        // Do any additional setup after loading the view.
    }
    
    func nextPage(_ r: UIGestureRecognizer) {
        let selectedIndex = self.selectedIndex // 当前所在标签页
        
        if selectedIndex == 0 {
            let fromView = self.viewsArray[selectedIndex].view!
            let toView = self.viewsArray[selectedIndex + 1].view!
            UIView.transition(from: fromView, to: toView, duration: 0.5, options: .transitionFlipFromRight, completion: { (finished: Bool) -> Void in
                self.selectedIndex += 1
            })
        }
    }
    
    func lastPage(_ r: UIGestureRecognizer) {
        let selectedIndex = self.selectedIndex // 当前所在标签页
        
        if selectedIndex == 1 {
            let fromView = self.viewsArray[selectedIndex].view!
            let toView = self.viewsArray[selectedIndex - 1].view!
            UIView.transition(from: fromView, to: toView, duration: 0.5, options: .transitionFlipFromLeft, completion: { (finished: Bool) -> Void in
                self.selectedIndex -= 1
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
