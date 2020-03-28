//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class PresentingViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let button = UIButton()
        button.setTitle("Present", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(tappedPresent), for: .touchUpInside)
        
        view.addSubview(button)
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view = view
    }
    
    @objc
    func tappedPresent() {
        let vc = PresentedViewController()
        present(vc, animated: true, completion: nil)
    }
}

class PresentedViewController : UIViewController {
    let animDuration = 0.4
    var anim: UIViewImplicitlyAnimating?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

         let button = UIButton()
               button.setTitle("Cancel", for: .normal)
               button.setTitleColor(.black, for: .normal)
               button.addTarget(self, action: #selector(tappedDismissed), for: .touchUpInside)
               
               view.addSubview(button)
               button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
               self.view = view
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = PresentationController(presentedViewController: presented, presenting: presenting)
        return pc
    }
    
    @objc
       func tappedDismissed() {
           dismiss(animated: true, completion: nil)
       }
}

extension PresentedViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }
    
}

extension PresentedViewController: UIViewControllerAnimatedTransitioning {
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
        
        let vc2 = transitionContext.viewController(forKey: .to)!
        let container = transitionContext.containerView
        let r2end = transitionContext.finalFrame(for: vc2)
        let v1 = transitionContext.view(forKey: .from)
        let v2 = transitionContext.view(forKey: .to)
        if let v2 = v2 { // presenting
            v2.frame = r2end
            v2.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            v2.alpha = 0
            container.addSubview(v2)
            anim = UIViewPropertyAnimator(duration: animDuration, curve: .linear) {
                v2.alpha = 1
                v2.transform = .identity
            }
        } else if let v1 = v1 { // dismissing
            anim  = UIViewPropertyAnimator(duration: animDuration, curve: .linear) {
                v1.alpha = 0
            }
        }

        anim!.addCompletion? { (_) in
            transitionContext.completeTransition(true)
        }
        return anim!
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        anim = nil
    }
}

class PresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        super.frameOfPresentedViewInContainerView.insetBy(dx: 40, dy: 40)
    }
    
    override func presentationTransitionWillBegin() {
        let container = containerView!
        let shadow = UIView(frame: container.bounds)
        shadow.backgroundColor = UIColor(white: 0, alpha: 0.4)
        container.insertSubview(shadow, at: 0)
        shadow.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func dismissalTransitionWillBegin() {
        let container = containerView!
        let shadow = container.subviews[0]
        let tc = presentedViewController.transitionCoordinator
        tc?.animate(alongsideTransition: { (ctx) in
            shadow.alpha = 0
        }, completion: nil)
    }
    
    override var presentedView: UIView? {
        let v = super.presentedView!
        v.layer.cornerRadius = 6
        v.layer.masksToBounds = true
        return v
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        let vc = self.presentingViewController
        let v = vc.view
        v?.tintAdjustmentMode = .dimmed
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        let vc = self.presentingViewController
        let v = vc.view
        v?.tintAdjustmentMode = .automatic
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = PresentingViewController()
