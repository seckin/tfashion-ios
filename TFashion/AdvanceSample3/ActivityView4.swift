
import UIKit
import Advance

public final class ActivityView4: UIView {
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        layer.allowsGroupOpacity = false
        
        self.userInteractionEnabled = true
        
        let button = UIButton();
        button.setTitle("Double Tap to Continue", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        // *** TODO: if you make this button work instead of the double tap in the parent, you need to change -25 to 0
        button.frame = CGRectMake(0, -10, 250, 25) // X, Y, width, height
        button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(button)

        let image1 = UIImage(named: "make-friends") //750 × 1067
        let imageview = UIImageView(frame: CGRectMake(0, 25, 75 * 3.5, 106.7 * 3.5))
        imageview.image = image1
        self.addSubview(imageview)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: 40.0, height: 40.0)
    }
    
    func buttonPressed(sender: UIButton!) {
    }
    
}