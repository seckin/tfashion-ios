
import UIKit
import Advance



public final class ActivityView2: UIView {
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        layer.allowsGroupOpacity = false
        
        let image1 = UIImage(named: "top-tag")// 1160 x 1000
        let imageview = UIImageView(frame: CGRectMake(0, 0, 116 * 2 * 0.9, 100 * 2 * 0.9))
        imageview.image = image1
        self.addSubview(imageview)
        
        let image2 = UIImage(named: "bottom-tag") // 1160 x 900
        let imageview2 = UIImageView(frame: CGRectMake(0, 2 * 100 + 10, 116 * 2 * 0.9, 90 * 2 * 0.9))
        imageview2.image = image2
        self.addSubview(imageview2)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: 40.0, height: 40.0)
    }
    
}