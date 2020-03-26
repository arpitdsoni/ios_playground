//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

extension CGFloat {
    var radians: CGFloat {
        return (self * .pi) / 180
    }
}

enum ArrowPath {
    case bottomLeftToTopRight
    case bottomLeftToTopLeft
    case bottmRightToTopLeft
    case bottomRightToTopRight
    case topLeftToBottomRight
    case topLeftToBottomLeft
    case topRightToBottomLeft
    case topRightToBottomRight
}

class ArrowAnimation: UIView {
    
    private let path: ArrowPath
    private let numberOfArrows: Int
    private var pathAnimation: CAKeyframeAnimation!
    private var alphaAnimation: CAKeyframeAnimation!
    private var groupAnimation: CAAnimationGroup!
    private var arrows: [UIImageView] = []
    private let imageName = "up-chevron"
    
    var arrowTintColor = UIColor.blue
    
    init(frame: CGRect, path: ArrowPath, numberOfArrows: Int = 3) {
        self.path = path
        self.numberOfArrows = numberOfArrows
        
        pathAnimation = CAKeyframeAnimation(keyPath: "position")
        alphaAnimation = CAKeyframeAnimation(keyPath: "opacity")
        groupAnimation = CAAnimationGroup()
        
        super.init(frame: frame)
//        self.backgroundColor = UIColor.yellow
        
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
        let bpath = UIBezierPath()
        
        switch path {
        case .bottomLeftToTopRight:
            bpath.move(to: CGPoint(x: 0, y: frame.maxY))
            bpath.addQuadCurve(to: CGPoint(x: frame.maxX, y: 0), controlPoint: CGPoint(x: frame.maxX*0.75, y: frame.maxY*0.75))
            
        case .bottomLeftToTopLeft:
            bpath.move(to: CGPoint(x: 0, y: frame.maxY))
            bpath.addQuadCurve(to: CGPoint(x: 0, y: 0), controlPoint: CGPoint(x: frame.maxX, y: frame.maxY*0.5))
            
        case .bottmRightToTopLeft:
            bpath.move(to: CGPoint(x: frame.maxX, y: frame.maxY))
            bpath.addQuadCurve(to: CGPoint(x: 0, y: 0), controlPoint: CGPoint(x: frame.minX*0.25, y: frame.maxY*0.75))
            
        case .bottomRightToTopRight:
            bpath.move(to: CGPoint(x: frame.maxX, y: frame.maxY))
            bpath.addQuadCurve(to: CGPoint(x: frame.maxX, y: 0), controlPoint: CGPoint(x: frame.minX, y: frame.maxY*0.5))
            
        case .topLeftToBottomRight:
            bpath.move(to: CGPoint(x: 0, y: 0))
            bpath.addQuadCurve(to: CGPoint(x: frame.maxX, y: frame.maxY), controlPoint: CGPoint(x: frame.maxX*0.25, y: frame.maxY*0.75))
            
        case .topLeftToBottomLeft:
            bpath.move(to: CGPoint(x: 0, y: 0))
            bpath.addQuadCurve(to: CGPoint(x: 0, y: frame.maxY), controlPoint: CGPoint(x: frame.maxX, y: frame.maxY*0.5))
            
        case .topRightToBottomLeft:
            bpath.move(to: CGPoint(x: frame.maxX, y: 0))
            bpath.addQuadCurve(to: CGPoint(x: 0, y: frame.maxY), controlPoint: CGPoint(x: frame.maxX*0.75, y: frame.maxY*0.75))
            
        case .topRightToBottomRight:
            bpath.move(to: CGPoint(x: frame.maxX, y: 0))
            bpath.addQuadCurve(to: CGPoint(x: frame.maxX, y: frame.maxY), controlPoint: CGPoint(x: frame.minX, y: frame.maxY*0.5))
            
        }
        
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
        
        let arrowFrame = CGRect(x: 50, y: 300, width: 200, height: 200)
        //        case bottomLeftToTopRight
        //        case bottomLeftToTopLeft
        //        case bottmRightToTopLeft
        //        case bottomRightToTopRight
        //        case topLeftToBottomRight
        //        case topLeftToBottomLeft
        //        case topRightToBottomLeft
        //        case topRightToBottomRight
        arrowView = ArrowAnimation(frame: arrowFrame, path: .topRightToBottomRight)
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
