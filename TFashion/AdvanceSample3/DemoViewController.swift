
import UIKit

class DemoViewController: UIViewController {
    
    var note: String {
        get { return noteLabel.text ?? "" }
        set {
            noteLabel.text = newValue
            view.setNeedsLayout()
        }
    }
    
    override var title: String? {
        didSet {
            titleLabel.text = title
            view.setNeedsLayout()
        }
    }
    
    let contentView = UIView()
    
    private let titleLabel = UILabel()
    
    private let noteLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        contentView.alpha = 1.0
        contentView.layer.allowsGroupOpacity = false
//        contentView.userInteractionEnabled = false
        contentView.frame = view.bounds
        view.addSubview(contentView)
        
        titleLabel.font = UIFont.systemFontOfSize(32.0, weight: UIFontWeightMedium)
        titleLabel.textColor = UIColor.darkGrayColor()
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        noteLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightThin)
        noteLabel.textColor = UIColor.darkGrayColor()
        noteLabel.textAlignment = .Center
        noteLabel.numberOfLines = 0
        noteLabel.alpha = 1.0
        view.addSubview(noteLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.frame = view.bounds
        
        //let labelHeight = noteLabel.sizeThatFits(CGSize(width: view.bounds.width-64.0, height: CGFloat.max)).height
        var labelFrame = CGRect.zero
        labelFrame.origin.x = 32.0
        labelFrame.origin.y = 96.0
        labelFrame.size.width = view.bounds.width - 64.0
        labelFrame.size.height = 64.0
        noteLabel.frame = labelFrame
        
        let titleHeight = titleLabel.sizeThatFits(CGSize(width: view.bounds.width-64.0, height: CGFloat.max)).height
        var titleFrame = CGRect.zero
        titleFrame.origin.x = 32.0
        titleFrame.origin.y = 32.0
        titleFrame.size.width = view.bounds.width - 64.0
        titleFrame.size.height = titleHeight
        titleLabel.frame = titleFrame
    }
    
}
