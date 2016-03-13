
import UIKit

@objc class ActivityViewController4: DemoViewController {
    
    let activityView = ActivityView4()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Community"
        note = "Explore, curate, make new friends!"
                
        contentView.addSubview(activityView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = min(view.bounds.width, view.bounds.height) * 0.8
        activityView.bounds.size = CGSize(width: size, height: size)
        activityView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }

}
