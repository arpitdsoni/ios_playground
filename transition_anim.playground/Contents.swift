//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class FirstViewController : UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "First"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "First"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
    }
}

class SecondViewController : UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Second"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Second"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
    }
}

class TabBarController: UITabBarController, UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning {
    
    var anim: UIViewImplicitlyAnimating?
    let animDuration: TimeInterval = 0.4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    // MARK: UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let anim = interruptibleAnimator(using: transitionContext)
        anim.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let anim = anim {
            return anim
        }
        let vc1 = transitionContext.viewController(forKey: .from)!
        let vc2 = transitionContext.viewController(forKey: .to)!
        let container = transitionContext.containerView
        let r1Start = transitionContext.initialFrame(for: vc1)
        let r2End = transitionContext.finalFrame(for: vc2)
        let v1 = transitionContext.view(forKey: .from)!
        let v2 = transitionContext.view(forKey: .to)!
        
        let ix1 = viewControllers!.firstIndex(of: vc1)!
        let ix2 = viewControllers!.firstIndex(of: vc2)!
        let dir: CGFloat = ix1 < ix2 ? 1 : -1
        
        var r1End = r1Start
        r1End.origin.x -= r1End.size.width * dir
        
        var r2Start = r2End
        r2Start.origin.x += r2Start.size.width * dir
        
        v2.frame = r2Start
        container.addSubview(v2)
        let anim = UIViewPropertyAnimator(duration: animDuration, curve: .linear) {
            v1.frame = r1End
            v2.frame = r2End
        }
        
        anim.addCompletion { (_) in
            transitionContext.completeTransition(true)
        }
        self.anim = anim
        return anim
        
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        anim = nil
    }
    
}

let first = FirstViewController()
let second = SecondViewController()
let tabBarController = TabBarController()
tabBarController.viewControllers = [first, second]
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = tabBarController
