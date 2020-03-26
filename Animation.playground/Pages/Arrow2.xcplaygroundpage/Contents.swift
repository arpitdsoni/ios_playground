//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

typealias Degree = CGFloat

extension CGFloat {
    var radians: CGFloat {
        return (self * .pi) / 180
    }
}

class ArrowAnimation: UIView {
    
    private let numberOfArrows: Int
    private var pathAnimation: CAKeyframeAnimation!
    private var alphaAnimation: CAKeyframeAnimation!
    private var groupAnimation: CAAnimationGroup!
    private var arrows: [UIImageView] = []
    private let imageName = "up-chevron"
    private let centerPoint: CGPoint
    private let outerPoint: CGPoint
    private let radius: CGFloat
    private let endAngle: Degree
    private let clockwise: Bool
    
    private let radiusOffset: CGFloat = 24
    
    var arrowTintColor = UIColor.blue
    
    init(centerPoint: CGPoint, outerPoint: CGPoint, angle: Degree, clockwise: Bool, numberOfArrows: Int = 3) {
        self.numberOfArrows = numberOfArrows
        self.centerPoint = centerPoint
        self.outerPoint = outerPoint
        self.endAngle = angle.radians
        self.clockwise = clockwise
        
        let radius = sqrt(pow(outerPoint.x - centerPoint.x, 2) + pow(outerPoint.y - centerPoint.y, 2))
        let minPoint = min(centerPoint.x, centerPoint.y)
        if radius > minPoint {
            self.radius = minPoint - radiusOffset
        } else {
            self.radius = radius - radiusOffset
        }
        print("radius: \(radius)")
        
        pathAnimation = CAKeyframeAnimation(keyPath: "position")
        alphaAnimation = CAKeyframeAnimation(keyPath: "opacity")
        groupAnimation = CAAnimationGroup()
        
        super.init(frame: .zero)
        self.backgroundColor = UIColor.yellow
        
        pathAnimation.rotationMode = CAAnimationRotationMode.rotateAuto
        pathAnimation.calculationMode = CAAnimationCalculationMode.paced
        pathAnimation.path = self.arrowPath(frame: self.bounds)
        
        alphaAnimation.values = [0.0, 1.0, 0.0]
        
        groupAnimation.animations = [pathAnimation, alphaAnimation]
        groupAnimation.duration = 1.6
        groupAnimation.repeatCount = .infinity
        
        for _ in 0..<numberOfArrows {
            let arrow = UIImageView(image: UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate))
            arrow.contentMode = .scaleAspectFit
            arrow.tintColor = arrowTintColor
            arrow.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
            arrow.transform = CGAffineTransform(rotationAngle: CGFloat(90).radians)
            arrow.alpha = 0
            arrows.append(arrow)
            self.addSubview(arrow)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ArrowAnimation {
    
    func arrowPath(frame: CGRect) -> CGPath {
        
        let zeroDegreePoint = CGPoint(x: centerPoint.x + radius, y: centerPoint.y)
        let startAngle = atan2(zeroDegreePoint.y - centerPoint.y, zeroDegreePoint.x - centerPoint.x) + atan2(outerPoint.y - centerPoint.y, outerPoint.x - centerPoint.x)
        let angle = startAngle * 180 / CGFloat.pi
        print(angle)
        
        let bpath = UIBezierPath(arcCenter: centerPoint,
                                    radius: radius,
                                    startAngle: startAngle,
                                    endAngle: startAngle + endAngle,
                                    clockwise: clockwise)
        return bpath.cgPath
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
        
        let centerPoint = CGPoint(x: 300, y: 200)
        let outerPoint = CGPoint(x: 300, y: 100)
        
        let centerPointView = UIView(frame: CGRect(origin: centerPoint, size: CGSize(width: 10, height: 10)))
        centerPointView.backgroundColor = UIColor.red
        view.addSubview(centerPointView)
        
        let outerPointView = UIView(frame: CGRect(origin: outerPoint, size: CGSize(width: 10, height: 10)))
        outerPointView.backgroundColor = UIColor.green
        view.addSubview(outerPointView)
        
        arrowView = ArrowAnimation(centerPoint: centerPoint, outerPoint: outerPoint, angle: 90, clockwise: true)
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
