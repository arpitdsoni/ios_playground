import UIKit
import PlaygroundSupport

class CountAnimation: UIView {
    
    let maxValue: Int
    let increment: Bool

    var numberAnimationType: NumberAnimationType = .normal
    var textColor = UIColor(red:0.22, green:0.28, blue:0.31, alpha:1.0)
    var borderColor = UIColor(red:0.00, green:0.19, blue:0.79, alpha:1.0).cgColor
    var borderWidth: CGFloat = 1.0
    var font = UIFont.boldSystemFont(ofSize: 42.0)
    
    private var timer: Timer?
    private var label: UILabel
    private let zoomDuration = 0.5
    private let numberDuration = 0.8
    
    init(position: CGPoint, maxValue: Int, increment: Bool) {
        self.maxValue = maxValue
        self.increment = increment
        label = UILabel()
        
        let _frame = CGRect(x: position.x, y: position
            .y, width: 0, height: 0)
        super.init(frame: _frame)
        
        self.alpha = 0
        self.label.alpha = 0

        label.font = font
        label.textAlignment = .center
        label.textColor = textColor
        //        label.backgroundColor = UIColor.yellow
        
        backgroundColor = UIColor(red:0.24, green:0.35, blue:1.00, alpha:1.0)
        layer.borderColor = borderColor
        layer.borderWidth = borderWidth
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        let countStart = increment ? 1 : maxValue
        DispatchQueue.main.async {
            self.label.text = "\(countStart)"
            self.resize()
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            UIView.animate(withDuration: self.zoomDuration, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.alpha = 1
                self.label.alpha = 1
            }, completion: { (true) in
                self.startTimer(withValue: countStart)
            })
        }
    }
    
    func stop(emoji: String = "👍") {
        timer?.invalidate()
        DispatchQueue.main.async {
            self.label.text = emoji
            self.resize()
//            self.label.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: [], animations: {
//                self.label.transform = .identity
                self.transform = .identity
            }, completion: { (true) in
                UIView.animate(withDuration: self.zoomDuration, animations: {
                    self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                }, completion: { (true) in
                    self.alpha = 0
//                    self.label.alpha = 0
                    self.transform = .identity
                })
            })
        }
    }
}

private extension CountAnimation {
    func numberAnimation(completion: @escaping () -> Void) {
        UIView.animate(withDuration: numberDuration, animations: {
//            self.label.transform = self.numberAnimationTransform()
//            self.label.alpha = 0
            self.transform = self.numberAnimationTransform()
            self.alpha = 0
        }, completion: { (true) in
//            self.label.transform = .identity
            self.transform = .identity
            completion()
        })
    }
    
    func numberAnimationTransform() -> CGAffineTransform  {
        switch numberAnimationType {
        case .expand:
            let translate = CGAffineTransform(translationX: 0, y: 60)
            return translate.scaledBy(x: 1.5, y: 1.5)
            
        case .shrink:
            let translate = CGAffineTransform(translationX: 0, y: 60)
            return translate.scaledBy(x: 0.6, y: 0.6)
            
        case .normal:
            return CGAffineTransform(translationX: 0, y: 60)
        }
    }
    
    
    func startTimer(withValue value: Int) {
        var count = value
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            let shouldStop = self.increment ? count > self.maxValue : count == 0
            if shouldStop {
                self.stop()
            } else {
                let initAnimation = self.increment ? count == 1 : count == self.maxValue
                DispatchQueue.main.async {
                    if !initAnimation {
                        self.label.text = "\(count)"
                        self.resize()
                    }
                    self.numberAnimation {
                        count = self.increment ? count + 1 : count - 1
                    }
                }
            }
        }
    }
    
    func resize() {
        self.alpha = 1
//        self.label.alpha = 1
        self.label.sizeToFit()
        let length = max(self.label.frame.height, self.label.frame.width) + 16
        self.frame.size.width = length
        self.frame.size.height = length
        self.label.center = self.convert(self.center, from: self.superview)
        self.layer.cornerRadius = length/2
    }
}

extension CountAnimation {
    enum NumberAnimationType {
        case expand
        case shrink
        case normal
    }
}


class MyViewController : UIViewController {
    
    var label: CountAnimation!
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        let position = CGPoint(x: 100, y: 160)
        label = CountAnimation(position: position, maxValue: 2, increment: true)
        label.numberAnimationType = .expand
        view.addSubview(label)
        
        let btn = UIButton(type: .system)
        btn.setTitle("Animate", for: .normal)
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(animateCounter), for: .touchUpInside)
        view.addSubview(btn)
        
        self.view = view
    }
    
    @objc func animateCounter() {
        label.start()
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

