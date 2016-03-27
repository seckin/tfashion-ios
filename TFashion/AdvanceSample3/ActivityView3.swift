
import UIKit
import Advance



public final class ActivityView3: UIView {
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        layer.allowsGroupOpacity = false
        
        let image1 = UIImage(named: "comment-like") //750 × 1067
        let imageview = UIImageView(frame: CGRectMake(0, 25, 75 * 3.5, 106.7 * 3.5))
        imageview.image = image1
        self.addSubview(imageview)

        self.addSubview(imageview)

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: 40.0, height: 40.0)
    }
    
}