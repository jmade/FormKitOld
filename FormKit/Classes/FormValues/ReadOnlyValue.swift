import UIKit

//: MARK: - ReadOnlyValue -
public struct ReadOnlyValue: FormValue, Equatable, Hashable {
    
    public var formItem: FormItem {
        get {
            return FormItem.readOnly(self)
        }
    }
    
    let title:String
    let value:String
    init(title: String, value:String) {
        self.title = title
        self.value = value
    }
}

extension ReadOnlyValue: FormValueDisplayable {

    
    public typealias Cell = ReadOnlyCell
    
    public func configureCell(_ formController: FormTableViewController, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
    }
    
    public typealias Controller = FormTableViewController
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        //
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}


extension ReadOnlyValue {
    public static func Random() -> ReadOnlyValue {
        let randomString = UUID().uuidString
        let randomTitle = randomString.split(separator: "-")[1]
        let randomValue = randomString.split(separator: "-")[2]
        return ReadOnlyValue(title: String(randomTitle), value: String(randomValue))
    }
}


//: MARK: - ReadOnlyCell -
public final class ReadOnlyCell: UITableViewCell {
    static let identifier = "readOnlyCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    
    var indexPath: IndexPath?
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        return label
    }()
    
    var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        label.textAlignment = .right
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var formValue : ReadOnlyValue? {
        didSet {
            if let readOnlyValue = formValue {
                titleLabel.text = readOnlyValue.title
                valueLabel.text = readOnlyValue.value
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let heightAnchorConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        heightAnchorConstraint.priority = UILayoutPriority(rawValue: 499)
        heightAnchorConstraint.isActive = true
        
        [titleLabel,valueLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })
        
        let margin = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 2.0),
            contentView.bottomAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2.0),
            
            ])
    }
    
    override public func prepareForReuse() {
        valueLabel.text = nil
        titleLabel.text = nil
        super.prepareForReuse()
    }
}
