
import UIKit

@objc class ActivityViewController: DemoViewController {
    
    let activityView = ActivityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Share"
        note = "Take amazing pictures to share"
                
        contentView.addSubview(activityView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = min(view.bounds.width, view.bounds.height) * 0.8
        activityView.bounds.size = CGSize(width: size, height: size)
        activityView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }

}
