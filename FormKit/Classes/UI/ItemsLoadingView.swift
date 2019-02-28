import UIKit

//: MARK: - ItemsLoadingView -
public class ItemsLoadingView : UIView {
    
    let loadingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "LOADING"
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let progress: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    required public init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        addSubview(progress)
        addSubview(loadingLabel)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: progress, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: progress, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 30.0),
            NSLayoutConstraint(item: loadingLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: loadingLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 52.0),
            ])
    }
    
    override public func willRemoveSubview(_ subview: UIView) {
        if subview == progress { progress.stopAnimating() }
        super.willRemoveSubview(subview)
    }
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        progress.startAnimating()
    }
    
    public func displayMessage(_ message:String) {
        DispatchQueue.main.async(execute: { [weak self] in
            UIView.animate(withDuration: 1/3, animations: {
                self?.loadingLabel.font = UIFont.preferredFont(forTextStyle: .headline)
                self?.loadingLabel.textColor = .black
                self?.loadingLabel.text = message
                self?.progress.stopAnimating()
                self?.progress.removeFromSuperview()
            }, completion: { _ in
                
            })
        })
    }
    
    public func end(){
        DispatchQueue.main.async(execute: { [weak self] in
            UIView.animate(withDuration: 1/3, animations: {
                self?.alpha = 0
            }, completion: { _ in
                self?.removeFromSuperview()
            })
        })
    }
}
