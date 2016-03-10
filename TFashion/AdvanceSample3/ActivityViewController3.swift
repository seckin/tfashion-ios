
import UIKit

@objc class ActivityViewController3: DemoViewController {
    
    let activityView = ActivityView3()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Step #3"
        note = "Your friends and like-minded people start commenting on and liking your clothes right away!"
                
        contentView.addSubview(activityView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = min(view.bounds.width, view.bounds.height) * 0.8
        activityView.bounds.size = CGSize(width: size, height: size)
        activityView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }

}
