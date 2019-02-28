import UIKit

extension Date {
    public func addingMins(_ mins:Int) -> Date {
        if let additiveDate = Calendar.current.date(byAdding: Calendar.Component.minute, value: mins, to: self, wrappingComponents: false) {
            return additiveDate
        } else {
            return self
        }
        
    }
}



//: MARK: - TimeValue -
public struct TimeValue: FormValue, Equatable, Hashable {
    let title:String
    let time:String
    
    public init(title: String,time:String) {
        self.title = title
        self.time = time
    }
    
    public var formItem:FormItem {
        get {
            return FormItem.time(self)
        }
    }
    
    func timeIncrementBy(mins:Int) -> String {
        var hour = 0
        var minute = 0
        
        if let hourString = time.split(separator: ":").first {
            if let hourInt = Int(hourString) {
                hour = hourInt
            }
        }
        
        if let afterHourString = time.split(separator: ":").last {
            if let minsString = afterHourString.split(separator: " ").first {
                if let minInt = Int(minsString) {
                    minute = minInt
                }
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
        let incrementedDate = date.addingMins(mins)
        let newtimeString = formatter.string(from: incrementedDate)
        
        return newtimeString
    }
}


extension TimeValue: FormValueDisplayable {
    
    public typealias Cell = TimeCell
    public typealias Controller = FormTableViewController
    
    
    public var cellDescriptor: FormCellDescriptor {
        return .init(Cell.identifier, configureCell, didSelect)
    }

    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
    }

    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        
        formController.customTransitioningDelegate.descriptor = PresentationDescriptors.lowerThird()
        
        let controller = TimeSelectionController(self)
        controller.updateFormValueDelegate = formController
        //controller.timeValue = self
        controller.indexPath = path
        controller.minIncrement = 1
        
        let navController = UINavigationController(rootViewController: controller)
        if #available(iOS 11.0, *) {
            navController.navigationBar.prefersLargeTitles = false
            navController.navigationItem.largeTitleDisplayMode = .never
        }
        
        navController.transitioningDelegate = formController.customTransitioningDelegate
        navController.modalPresentationStyle = .custom
        formController.present(navController, animated: true, completion: nil)
    }
    
}


extension TimeValue {
    
    public static func Random() -> TimeValue {
        let randomHr = ["1","2","3","4","5","6","7","8","9","10","11","12"].randomElement()!
        let randomMin = Array(stride(from: 0, to: 60, by: 1)).map({String(format: "%02d", $0)}).randomElement()!
        let randomPeriod = ["AM","PM"].randomElement()!
        let randomTime = "\(randomHr):\(randomMin) \(randomPeriod)"
        return TimeValue(title: "Time", time: randomTime)
    }
    
}



//: MARK: TimeCell
public final class TimeCell: UITableViewCell {
    static let identifier = "timeCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    var indexPath:IndexPath?
    
    var formValue:TimeValue? {
        didSet {
            if let timeValue = formValue {
                titleLabel.text = timeValue.title
                timeLabel.text = timeValue.time
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [titleLabel,timeLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })
        
        let heightAnchorConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        heightAnchorConstraint.priority = UILayoutPriority(rawValue: 499)
        heightAnchorConstraint.isActive = true
        
        let margin = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            ])
        
        accessoryType = .disclosureIndicator
    }
    
}

