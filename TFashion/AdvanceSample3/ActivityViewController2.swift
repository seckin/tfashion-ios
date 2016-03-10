
import UIKit

@objc class ActivityViewController2: DemoViewController {
    
    let activityView = ActivityView2()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Step #2"
        note = "Our system figures out where the clothes are"
                
        contentView.addSubview(activityView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = 200.0//min(view.bounds.width, view.bounds.height) * 0.8
        activityView.bounds.size = CGSize(width: size, height: size)
        activityView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }

}
