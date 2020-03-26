import CoreGraphics
import QuartzCore
import UIKit

public enum AnimationType: String {
    case Rotation = "transform.rotation.z"
    case Opacity = "opacity"
    case TranslationX = "transform.translation.x"
    case TranslationY = "transform.translation.y"
}

public extension CAKeyframeAnimation {
    class func animationWith(
        _ type: AnimationType,
        values:[Double],
        keyTimes:[Double],
        duration: Double,
        beginTime: Double) -> CAKeyframeAnimation {
        
        let animation = CAKeyframeAnimation(keyPath: type.rawValue)
        animation.values = values
        animation.keyTimes = keyTimes as [NSNumber]?
        animation.duration = duration
        animation.beginTime = beginTime
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        return animation
    }
    
    class func animationPosition(_ path: CGPath, duration: Double, timingFunction: CAMediaTimingFunctionName, beginTime: Double) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path
        animation.duration = duration
        animation.beginTime = beginTime
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        return animation
    }
}

public extension UIView {
    func addAnimation(_ animation: CAKeyframeAnimation) {
        layer.add(animation, forKey: description + animation.keyPath!)
        layer.speed = 0
    }
    
    func removeAllAnimations() {
        layer.removeAllAnimations()
    }
}

