//
//  WelcomeViewController.swift
//  Secret Contacts
//
//  Created by mac on 16/12/18.
//  Copyright © 2016年 pluto. All rights reserved.
//

import UIKit

/**
    欢迎界面，首次开启应用时加载
    ---
    **Parameters**
    *   scrollView: 界面里用来滑动的View
    *   pageControl: 界面的选择按钮，分别对应每个分页
    *   btn: 用来点击开始的按钮
 */


class WelcomeViewController: UIViewController, UIScrollViewDelegate {
    private var scrollView: UIScrollView = UIScrollView()
    private var pageControl: UIPageControl = UIPageControl()
    private let colorArray: [UIColor] = [.green, .yellow, .black, .red]
    private let btn: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: 初始化scrollView
        scrollView.frame = self.view.bounds
        scrollView.contentSize = CGSize(width: self.view.frame.width * 4, height: self.view.frame.height)
        scrollView.isPagingEnabled = true // 保证页式滑动
        scrollView.bounces = false // 禁止弹性
        scrollView.showsHorizontalScrollIndicator = false // 禁止出现滑动条
        scrollView.delegate = self
        
        self.view.addSubview(self.scrollView)
        
        for index in 0 ..< 4 {
            let imageView = UIImageView(frame:
                CGRect(
                    x: CGFloat(index) * self.view.frame.width,
                    y: 0,
                    width: self.view.frame.width,
                    height: self.view.frame.height
            ))
            imageView.backgroundColor = self.colorArray[index]
            scrollView.addSubview(imageView)
        }
        
        // TODO: 初始化PageControl
        pageControl.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - 30)
        pageControl.currentPageIndicatorTintColor = .blue
        pageControl.pageIndicatorTintColor = .white
        pageControl.numberOfPages = 4
        pageControl.addTarget(self, action: #selector(self.scrollViewDidEndDecelerating(_:)), for: .valueChanged)
        
        self.view.addSubview(self.pageControl)
        
        // TODO: 初始化btn
        self.btn.frame =
            CGRect(
                x: self.view.frame.width * 3,
                y: self.view.frame.height,
                width: self.view.frame.width,
                height: 50
        )
        self.btn.setTitle("进入通讯录", for: .normal)
        self.btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.btn.setTitleColor(UIColor.gray, for: .highlighted)
        self.btn.backgroundColor = .orange
        self.btn.alpha = 0
        self.btn.addTarget(self, action: #selector(self.toMainView(_:)), for: .touchUpInside)
        
        self.scrollView.addSubview(self.btn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex: Int = Int(scrollView.contentOffset.x / self.view.frame.width)
        pageControl.currentPage = currentIndex
        if currentIndex == 3 {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                options: .curveEaseInOut,
                animations: {
                    self.btn.alpha = 1.0
                    self.btn.layer.setAffineTransform(CGAffineTransform(translationX: 0, y: -100))
            },
                completion: { (_) -> Void in
            }
            )
        } else {
            UIView.animate(withDuration: 0, animations: {
                self.btn.layer.setAffineTransform(CGAffineTransform.identity)
                self.btn.alpha = 0
            })
        }
    }
    
    func toMainView(_ sender: Any?) {
        let welcomeView = UIStoryboard(name: "Main", bundle: nil)
        let rootView = welcomeView.instantiateViewController(withIdentifier: "Root")
        self.present(rootView, animated: true, completion: nil)
    }

}
