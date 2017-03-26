//
//  VPImageCropperViewController.swift
//  headPic
//
//  Created by mac on 16/12/4.
//  Copyright © 2016年 pluto. All rights reserved.
//

import UIKit


let SCALE_FRAME_Y = 100.0
let BOUNDCE_DURATION = 0.3

protocol VPImageCropperDelegate {
    func imageCropper(_ cropperViewController: VPImageCropperViewController, didFinished editedImage: UIImage)
    func imageCropperDidCancel(_ cropperViewController: VPImageCropperViewController)
}

class VPImageCropperViewController: UIViewController {
    var tag: NSInteger!
    var cropFrame: CGRect! // 剪裁界面的中心框Frame
    var delegate: VPImageCropperDelegate?
    
    var originalImage: UIImage! // 原图片，选择后传进来的图片
    var editedImage: UIImage! // 修改后的图片
    
    var showImgView: UIImageView! // 放图片的VIew
    var overlayView: UIView! // 超出范围的阴影遮罩
    var ratioView: UIView! // 剪裁界面的中心框
    
    var oldFrame: CGRect! // 原始的Frame
    var largeFrame: CGRect! // 最大允许的Frame
    var limitRatio: CGFloat! // 限制的比例
    
    var latestFrame: CGRect! // 调节后的Frame
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.initControlBtn()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    init(_ selImage: UIImage, cropFrame: CGRect, limitScaleRatio limitRatio: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        
        self.cropFrame = cropFrame
        self.limitRatio = limitRatio
        self.originalImage = selImage
        view.backgroundColor = UIColor(red: 0xE6/255, green: 0xE2/255, blue: 0xD4/255, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        // 创建并设置操作界面的View可触控
        self.showImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        self.showImgView.image = self.originalImage
        self.showImgView.isUserInteractionEnabled = true
        self.showImgView.isMultipleTouchEnabled = true
        
        // 设置中心框并设置图片原始Frame等元素
        let oriWidth: CGFloat = self.cropFrame.size.width
        let oriHeight: CGFloat = self.originalImage.size.height * (oriWidth / self.originalImage.size.width)
        let oriX: CGFloat = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2
        let oriY: CGFloat = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2
        self.oldFrame = CGRect(x: oriX, y: oriY, width: oriWidth, height: oriHeight)
        self.latestFrame = self.oldFrame
        self.showImgView.frame = self.oldFrame
        
        self.largeFrame = CGRect(x: 0, y: 0, width: self.limitRatio * self.oldFrame.size.width, height: self.limitRatio * self.oldFrame.size.height)
        
        // 添加相关的触屏响应
        self.addGestureRecognizers()
        self.view.addSubview(self.showImgView)
        
        // 添加遮罩阴影和相关属性：禁止触屏，自动布局适应
        self.overlayView = UIView(frame: self.view.bounds)
        self.overlayView.alpha = 0.5
        self.overlayView.backgroundColor = .black
        self.overlayView.isUserInteractionEnabled = false
        self.overlayView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.addSubview(self.overlayView)
        
        self.ratioView = UIView(frame: self.cropFrame)
        self.ratioView.layer.cornerRadius = self.cropFrame.width / 2
        self.ratioView.layer.borderColor = UIColor.yellow.cgColor
        self.ratioView.layer.borderWidth = 2.0
        self.ratioView.autoresizingMask = UIViewAutoresizing()
        self.view.addSubview(self.ratioView)
        
        self.overlayClipping()
    }
    
    func initControlBtn() {
        let cancelBtn:UIButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 50, width: 100, height: 50))
        cancelBtn.backgroundColor = .black
        cancelBtn.titleLabel?.textColor = .white
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        cancelBtn.titleLabel?.textAlignment = .center
        cancelBtn.titleLabel?.lineBreakMode = .byWordWrapping
        cancelBtn.titleLabel?.numberOfLines = 0
        cancelBtn.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        cancelBtn.addTarget(self, action: #selector(VPImageCropperViewController.cancel(_:)), for: .touchUpInside)
        self.view.addSubview(cancelBtn)
        
        let confirmBtn:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 100, y: self.view.frame.size.height - 50, width: 100, height: 50))
        confirmBtn.backgroundColor = .black
        confirmBtn.titleLabel?.textColor = .white
        confirmBtn.setTitle("OK", for: .normal)
        confirmBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        confirmBtn.titleLabel?.textAlignment = .center
        confirmBtn.titleLabel?.lineBreakMode = .byWordWrapping
        confirmBtn.titleLabel?.numberOfLines = 0
        confirmBtn.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        confirmBtn.addTarget(self, action: #selector(VPImageCropperViewController.confirm(_:)), for: .touchUpInside)
        self.view.addSubview(confirmBtn)
    }
    
    func cancel(_ sender: Any) {
        if let d = self.delegate {
            print("[Log] Cancel")
            d.imageCropperDidCancel(self)
        }
    }
    
    func confirm(_ sender: Any) {
        if let d = self.delegate {
            print("[Log] Confirm")
            d.imageCropper(self, didFinished: self.getSubImage())
        }
    }
    
    // 遮罩（多余）部分剪裁
    func overlayClipping() {
        let maskLayer: CAShapeLayer = CAShapeLayer()
        let path: CGMutablePath = CGMutablePath()
//        path.addRects([
//            CGRect(
//                x: 0,
//                y: 0,
//                width: self.ratioView.frame.origin.x,
//                height: self.overlayView.frame.size.height
//            ),
//            CGRect(
//                x: self.ratioView.frame.maxX,
//                y: 0,
//                width: self.overlayView.frame.size.width - self.ratioView.frame.maxX,
//                height: self.overlayView.frame.size.height
//            ),
//            CGRect(
//                x: 0,
//                y: 0,
//                width: self.overlayView.frame.size.width,
//                height: self.ratioView.frame.origin.y
//            ),
//            CGRect(
//                x: 0,
//                y: self.ratioView.frame.maxY,
//                width: self.overlayView.frame.size.width,
//                height: self.overlayView.frame.size.height - self.ratioView.frame.maxY
//            )
        
//        path.addArc(
//            center: CGPoint(x: self.cropFrame.origin.x + self.cropFrame.size.width / 2, y: self.cropFrame.origin.y + self.cropFrame.size.height / 2),
//            radius: self.cropFrame.size.width / 2,
//            startAngle: 0,
//            endAngle: CGFloat.pi * 2,
//            clockwise: true,
//            transform: .identity
//        )
        
//        let anotherPath:UIBezierPath = UIBezierPath(
//            arcCenter: CGPoint(x: self.cropFrame.origin.x + self.cropFrame.size.width / 2, y: self.cropFrame.origin.y + self.cropFrame.size.height / 2),
//            radius: self.cropFrame.size.width / 2,
//            startAngle: 0,
//            endAngle: CGFloat.pi * 2,
//            clockwise: false
//        )
        
        // 不能完美的在黑色背景里扣出一块透明
//        maskLayer.path = path
//        maskLayer.fillRule = kCAFillRuleEvenOdd
//        maskLayer.fillColor = UIColor.white.cgColor
//        maskLayer.opacity = 0.5
//        self.overlayView.layer.addSublayer(maskLayer)
//        path.closeSubpath()
        
        let onePath:UIBezierPath = UIBezierPath()
        onePath.move(to: CGPoint(x: 0, y: self.cropFrame.origin.y + self.cropFrame.size.height / 2))
        onePath.addLine(to: CGPoint(x: 0, y: 0))
        onePath.addLine(to: CGPoint(x: self.overlayView.frame.size.width, y: 0))
        onePath.addLine(to: CGPoint(x: self.overlayView.frame.size.width, y: self.cropFrame.origin.y + self.cropFrame.size.height / 2))
        onePath.addArc(withCenter: CGPoint(x: self.cropFrame.origin.x + self.cropFrame.size.width / 2, y: self.cropFrame.origin.y + self.cropFrame.size.height / 2), radius:  self.cropFrame.size.width / 2, startAngle: 0, endAngle: CGFloat.pi * 1, clockwise: false)
        onePath.close()
        
        let anotherPath:UIBezierPath = UIBezierPath()
        anotherPath.move(to: CGPoint(x: 0, y: self.cropFrame.origin.y + self.cropFrame.size.height / 2))
        anotherPath.addLine(to: CGPoint(x: 0, y: self.overlayView.frame.size.height))
        anotherPath.addLine(to: CGPoint(x: self.overlayView.frame.size.width, y: self.overlayView.frame.size.height))
        anotherPath.addLine(to: CGPoint(x: self.overlayView.frame.size.width, y: self.cropFrame.origin.y + self.cropFrame.size.height / 2))
        anotherPath.addArc(withCenter: CGPoint(x: self.cropFrame.origin.x + self.cropFrame.size.width / 2, y: self.cropFrame.origin.y + self.cropFrame.size.height / 2), radius:  self.cropFrame.size.width / 2, startAngle: 0, endAngle: CGFloat.pi * 1, clockwise: true)
        anotherPath.close()
       
        path.addPath(onePath.cgPath)
        path.addPath(anotherPath.cgPath)
        
        maskLayer.path = path
        self.overlayView.layer.mask = maskLayer
    }
    
    func addGestureRecognizers() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(VPImageCropperViewController.pinchView(_:)))
        self.view.addGestureRecognizer(pinchGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(VPImageCropperViewController.panView(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func pinchView(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        let view:UIView = self.showImgView
        if pinchGestureRecognizer.state == .began || pinchGestureRecognizer.state == .changed {
            view.transform = view.transform.scaledBy(x: pinchGestureRecognizer.scale, y: pinchGestureRecognizer.scale)
            pinchGestureRecognizer.scale = 1
        } else if pinchGestureRecognizer.state == .ended {
            var newFrame:CGRect = self.showImgView.frame
            newFrame = self.handleScaleOverflow(newFrame)
            newFrame = self.handleBorderOverflow(newFrame)
            UIView.animate(withDuration: BOUNDCE_DURATION, animations: {
                self.showImgView.frame = newFrame
                self.latestFrame = newFrame
            })
        }
    }
    
    func panView(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let view:UIView = self.showImgView
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            let translation:CGPoint = panGestureRecognizer.translation(in: view.superview)
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
        } else if panGestureRecognizer.state == .ended {
            var newFrame:CGRect = self.showImgView.frame
            newFrame = self.handleBorderOverflow(newFrame)
            UIView.animate(withDuration: BOUNDCE_DURATION, animations: {
                self.showImgView.frame = newFrame
                self.latestFrame = newFrame
            })
        }
    }
    
    func handleScaleOverflow(_ newFrame: CGRect) -> CGRect {
        var tempFrame:CGRect = newFrame
        let oriCenter:CGPoint = CGPoint(x: tempFrame.origin.x + tempFrame.size.width / 2, y: tempFrame.origin.y + tempFrame.size.height / 2)
        if tempFrame.size.width < self.oldFrame.size.width {
            tempFrame = self.oldFrame
        } else if tempFrame.size.width > self.largeFrame.size.width {
            tempFrame = self.largeFrame
        }
        tempFrame.origin.x = oriCenter.x - tempFrame.size.width / 2
        tempFrame.origin.y = oriCenter.y - tempFrame.size.height / 2
        return tempFrame
    }
    
    func handleBorderOverflow(_ newFrame: CGRect) -> CGRect {
        var tempFrame:CGRect = newFrame
        
        if tempFrame.origin.x > self.cropFrame.origin.x {
            tempFrame.origin.x = self.cropFrame.origin.x
        }
        if tempFrame.maxX < self.cropFrame.maxX {
            tempFrame.origin.x = self.cropFrame.maxX - tempFrame.size.width
        }
        
        if tempFrame.origin.y > self.cropFrame.origin.y {
            tempFrame.origin.y = self.cropFrame.origin.y
        }
        if tempFrame.maxY < self.cropFrame.maxY {
            tempFrame.origin.y = self.cropFrame.maxY - tempFrame.size.height
        }
        
        if self.showImgView.frame.size.width > self.showImgView.frame.size.height && tempFrame.size.height <= self.cropFrame.size.height {
            tempFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - tempFrame.size.height) / 2
        }
        return tempFrame
    }
    
    func getSubImage() -> UIImage {
        let squareFrame:CGRect = self.cropFrame
        let scaleRatio:CGFloat = self.latestFrame.size.width / self.originalImage.size.width
        
        // 获取cropFrame在originalImage上的CGRect范围
        var x:CGFloat = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio
        var y:CGFloat = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio
        var w:CGFloat = squareFrame.size.width / scaleRatio
        var h:CGFloat = squareFrame.size.width / scaleRatio
        
        if self.latestFrame.size.width < self.cropFrame.size.width {
            // 如果宽过少，则以宽为基准取所显示图片的中心
            let newW:CGFloat = self.originalImage.size.width
            let newH:CGFloat = newW * (self.cropFrame.size.height / self.cropFrame.size.width)
            x = 0
            y = y + (h - newH) / 2
            w = newH
            h = newH
        }
        
        if self.latestFrame.size.height < self.cropFrame.size.height {
            // 如果高过少，则以高为基准取所显示图片的中心
            let newH:CGFloat = self.originalImage.size.height
            let newW:CGFloat = newH * (self.cropFrame.size.width / self.cropFrame.size.height)
            x = x + (w - newW) / 2
            y = 0
            w = newH
            h = newH
        }
        
        let myImageRect:CGRect = CGRect(x: x, y: y, width: w, height: h)
        let imageRef:CGImage = self.originalImage.cgImage!
        let subImageRef: CGImage = imageRef.cropping(to: myImageRect)! // 图片根据CGRect剪裁
        let smallImage:UIImage = UIImage(cgImage: subImageRef)
        
        
//        下面的方法不正确，倒数第二句起作用
//        /UIGraphicsGetImageFromCurrentImageContext() 使用没弄清楚
//        let size:CGSize = CGSize(width: myImageRect.size.width, height: myImageRect.size.height)
//        UIGraphicsBeginImageContext(size)
//        let context:CGContext = UIGraphicsGetCurrentContext()!
//        context.draw(imageRef, in: myImageRect) // 重新绘制
//        let smallImage:UIImage = UIImage(cgImage: subImageRef)
//        UIGraphicsEndImageContext()
        
        return smallImage
    }

}
