
import UIKit
import Advance



public final class ActivityView: UIView {
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        layer.allowsGroupOpacity = false
        
        let image1 = UIImage(named: "intro1")
        let imageview = UIImageView(image: image1)
        self.addSubview(imageview)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: 40.0, height: 40.0)
    }
    
}