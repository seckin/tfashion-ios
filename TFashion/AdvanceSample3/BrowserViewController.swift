
import UIKit
import Advance

private final class DemoItem: BrowserItem {
    let viewController: DemoViewController
    init(viewController: DemoViewController) {
        self.viewController = viewController
        super.init()
    }
}

final class BrowserViewController: UIViewController {
    
    let viewControllers: [DemoViewController]
    
    let backgroundImageView = UIImageView(frame: CGRect.zero)
    let blurredBackgroundImageView = UIImageView(frame: CGRect.zero)
    let backgroundDimmingView = UIView(frame: CGRect.zero)
    
    let blurSpring = Spring(value: CGFloat.zero)
    
    let browserView = BrowserView(frame: CGRect.zero)
    
    let tapRecognizer = UITapGestureRecognizer()
    
    required init(viewControllers: [DemoViewController]) {
        self.viewControllers = viewControllers
        super.init(nibName: nil, bundle: nil)
        
        var cfg = SpringConfiguration()
        cfg.threshold = 0.001
        cfg.tension = 60.0
        cfg.damping = 26.0
        blurSpring.configuration = cfg
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.image = UIImage(named: "background")
        view.addSubview(backgroundImageView)
        
        blurredBackgroundImageView.contentMode = .ScaleAspectFill
        blurredBackgroundImageView.image = UIImage(named: "background-blurred")
        blurredBackgroundImageView.alpha = 0.0
        view.addSubview(blurredBackgroundImageView)
        
        backgroundDimmingView.backgroundColor = UIColor.blackColor()
        backgroundDimmingView.alpha = 0.3
        view.addSubview(backgroundDimmingView)
        
        let cv = CoverView(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))
        browserView.coverView = cv

        
        view.addSubview(browserView)
        browserView.delegate = self
        
        browserView.items = viewControllers.map({ (vc) -> DemoItem in
            return DemoItem(viewController: vc)
        })
        
        blurSpring.changed.observe { [unowned self] (b) in
            self.blurredBackgroundImageView.alpha = b
        }

        tapRecognizer.addTarget(self, action: "tap")
        tapRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.frame = view.bounds
        blurredBackgroundImageView.frame = view.bounds
        backgroundDimmingView.frame = view.bounds
        browserView.frame = view.bounds
    }

    private dynamic func tap() {
        self.dismissViewControllerAnimated(true, completion: nil);
        
        //        if browserView?.fullScreenItem != self {
        //            browserView?.enterFullScreen(self)
        //        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

extension BrowserViewController: BrowserViewDelegate {
    func browserView(browserView: BrowserView, didShowItem item: BrowserItem) {
        guard let item = item as? DemoItem else { fatalError() }
        assert(item.viewController.parentViewController != self)
        addChildViewController(item.viewController)
        item.viewController.view.frame = item.view.bounds
        item.view.addSubview(item.viewController.view)
        item.viewController.didMoveToParentViewController(self)
    }
    
    func browserView(browserView: BrowserView, didHideItem item: BrowserItem) {
        guard let item = item as? DemoItem else { fatalError() }
        assert(item.viewController.parentViewController == self)
        item.viewController.willMoveToParentViewController(nil)
        item.viewController.view.removeFromSuperview()
        item.viewController.removeFromParentViewController()
    }
    
    func browserView(browserView: BrowserView, didEnterFullScreenForItem item: BrowserItem) {
        guard let item = item as? DemoItem else { fatalError() }
//        item.viewController.fullScreen = true

    }
    
    func browserView(browserView: BrowserView, didLeaveFullScreenForItem item: BrowserItem) {
        guard let item = item as? DemoItem else { fatalError() }
//        item.viewController.fullScreen = false
    }
    
    func browserViewDidScroll(browserView: BrowserView) {
        var blurAmount = browserView.currentIndex
        blurAmount = min(blurAmount, 1.0)
        blurAmount = max(blurAmount, 0.0)
        blurSpring.target = blurAmount
    }
}