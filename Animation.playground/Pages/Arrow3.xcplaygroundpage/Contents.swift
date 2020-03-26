//
//  ArrowAnimation.swift
//  mirrorar-ios-demoapp
//
//  Created by Arpit Soni on 12/1/18.
//  Copyright © 2018 Arpit Soni. All rights reserved.
//

// Better version of arrow animations

import UIKit
import PlaygroundSupport

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension CGPoint {
    
    func distance(to b: CGPoint) -> CGFloat {
        let x = (self.x - b.x)
        let y = (self.y - b.y)
        let d2 = x*x + y*y
        let d = sqrt(d2)
        return d
    }
}

class ArrowAnimation: UIView {
    
    private let numberOfArrows: Int
    private let centerPoint: CGPoint
    private let startPoint: CGPoint
    private let clockwise: Bool
    
    private var groupAnimation: CAAnimationGroup
    private var arrows: [UIImageView] = []
    private var radius: CGFloat!
    private var endAngle: CGFloat!
    private var startAngle: CGFloat!
    private var endPoint: CGPoint?
    private var angle: CGFloat?
    
    private let imageName = "right-chevron"
    private let radiusOffset: CGFloat = 24
    
    var arrowTintColor = UIColor.blue
    var duration: CFTimeInterval = 1.6
    var imageSize: Int = 40
    
    init(centerPoint: CGPoint, startPoint: CGPoint, angleInDegrees angle: CGFloat, clockwise: Bool, numberOfArrows: Int = 3) {
        self.numberOfArrows = numberOfArrows
        self.centerPoint = centerPoint
        self.startPoint = startPoint
        self.angle = angle.degreesToRadians
        self.clockwise = clockwise
        groupAnimation = CAAnimationGroup()
        
        super.init(frame: .zero)
        initAfterSuper()
    }
    
    init(centerPoint: CGPoint, startPoint: CGPoint, endPoint: CGPoint, clockwise: Bool, numberOfArrows: Int = 3) {
        self.numberOfArrows = numberOfArrows
        self.centerPoint = centerPoint
        self.startPoint = startPoint
        self.clockwise = clockwise
        self.endPoint = endPoint
        groupAnimation = CAAnimationGroup()
        
        super.init(frame: .zero)
        initAfterSuper()
    }
    
    func initAfterSuper() {
        
        // calculate radius so that it is within screen bounds
        let tmpRadius = startPoint.distance(to: centerPoint)
        let screenMaxXHalf = UIScreen.main.bounds.maxX/2
        let screenMaxYHalf = UIScreen.main.bounds.maxY/2
        let x = centerPoint.x
        let y = centerPoint.y
        let minPoint: CGFloat
        if x > screenMaxXHalf && y <= screenMaxYHalf {
            minPoint = min(screenMaxXHalf*2 - centerPoint.x, centerPoint.y)
        } else if x <= screenMaxXHalf && y > screenMaxYHalf {
            minPoint = min(centerPoint.x, screenMaxYHalf*2 - centerPoint.y)
        } else if x > screenMaxXHalf && y > screenMaxYHalf {
            minPoint = min(screenMaxXHalf*2 - centerPoint.x, screenMaxYHalf*2 - centerPoint.y)
        } else {
            // x <= screenMaxXHalf && y <= screenMaxYHalf
            minPoint = min(centerPoint.x,centerPoint.y)
        }
        radius = min(tmpRadius, minPoint) - radiusOffset
        
        // calcualte startAngle and endAngle
        let zeroDegreePoint = CGPoint(x: centerPoint.x + radius, y: centerPoint.y)
        startAngle = calculateAngleOfPoint(startPoint, fromPointAtZeroDegree: zeroDegreePoint, withCenterPointAt: centerPoint)
        if let endPoint = endPoint {
            endAngle = calculateAngleOfPoint(endPoint, fromPointAtZeroDegree: zeroDegreePoint, withCenterPointAt: centerPoint)
        } else {
            endAngle = startAngle + (angle ?? 0)
        }
        
        // path animation
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.rotationMode = CAAnimationRotationMode.rotateAuto
        pathAnimation.calculationMode = CAAnimationCalculationMode.paced
        pathAnimation.path = self.arrowPath(frame: self.bounds)
        
        // alpha animation
        let alphaAnimation = CAKeyframeAnimation(keyPath: "opacity")
        alphaAnimation.values = [0.0, 1.0, 0.0]
        
        groupAnimation.animations = [pathAnimation, alphaAnimation]
        groupAnimation.duration = duration
        groupAnimation.repeatCount = .infinity
        
        for _ in 0..<numberOfArrows {
            let arrow = UIImageView(image: UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate))
            arrow.contentMode = .scaleAspectFit
            arrow.tintColor = arrowTintColor
            arrow.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
            arrow.alpha = 0
            arrows.append(arrow)
            self.addSubview(arrow)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        DispatchQueue.global(qos: .background).async {
            var delay = 0.0
            for arrow in self.arrows {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
                    arrow.layer.add(self.groupAnimation, forKey: "arrow-\(delay)")
                }
                delay += 0.2
            }
        }
    }
    
    func stop() {
        self.arrows.forEach { (imageView) in
            DispatchQueue.main.async {
                imageView.layer.removeAllAnimations()
            }
        }
    }
}

private extension ArrowAnimation {
    
    func arrowPath(frame: CGRect) -> CGPath {
        let bpath = UIBezierPath(arcCenter: centerPoint,
                                 radius: radius,
                                 startAngle: startAngle,
                                 endAngle: endAngle,
                                 clockwise: clockwise)
        return bpath.cgPath
    }
    
    func calculateAngleOfPoint(_ point: CGPoint, fromPointAtZeroDegree zeroDegreePoint: CGPoint, withCenterPointAt centerPoint: CGPoint) -> CGFloat {
        return atan2(zeroDegreePoint.y - centerPoint.y, zeroDegreePoint.x - centerPoint.x) + atan2(point.y - centerPoint.y, point.x - centerPoint.x)
    }
}


class MyViewController : UIViewController {
    
    var arrowView: ArrowAnimation!
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        let startBtn = UIButton.init(type: .system)
        startBtn.setTitle("Start", for: .normal)
        startBtn.setTitleColor(UIColor.red, for: .normal)
        startBtn.sizeToFit()
        startBtn.addTarget(self, action: #selector(start), for: .touchUpInside)
        view.addSubview(startBtn)
        
        let stopBtn = UIButton.init(type: .system)
        stopBtn.setTitle("Stop", for: .normal)
        stopBtn.setTitleColor(UIColor.red, for: .normal)
        stopBtn.sizeToFit()
        stopBtn.center.x = 80
        stopBtn.addTarget(self, action: #selector(stop), for: .touchUpInside)
        view.addSubview(stopBtn)
        
        let centerPoint = CGPoint(x: 200, y: 200)
        let outerPoint = CGPoint(x: 200, y: 100)
        
        let centerPointView = UIView(frame: CGRect(origin: centerPoint, size: CGSize(width: 10, height: 10)))
        centerPointView.backgroundColor = UIColor.red
        view.addSubview(centerPointView)
        
        let outerPointView = UIView(frame: CGRect(origin: outerPoint, size: CGSize(width: 10, height: 10)))
        outerPointView.backgroundColor = UIColor.green
        view.addSubview(outerPointView)
        
        arrowView = ArrowAnimation(centerPoint: centerPoint, startPoint: outerPoint, angleInDegrees: 90, clockwise: true)
        view.addSubview(arrowView)
        
        self.view = view
    }
    
    @objc func start() {
        arrowView.start()
    }
    
    @objc func stop() {
        arrowView.stop()
    }
    
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
