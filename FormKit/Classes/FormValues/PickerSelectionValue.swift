import UIKit

//: MARK: - PickerValue -
public struct PickerSelectionValue: FormValue, Equatable, Hashable {
    
    public var formItem: FormItem {
        get {
            return FormItem.pickerSelection(self)
        }
    }
    
    public enum Mode {
        case display,selection
    }
    
    var values:[String]
    var selectedIndex: Int
    var title:String
    var mode:Mode
    var selectionMessage:String
    
    var cellId:String {
        return "picSel_\(selectedIndex)"
    }
    
    public init(title:String,values:[String],_ selectedIndex:Int = 0,_ selectionMessage:String = "Select a Value"){
        self.values = values
        self.selectedIndex = selectedIndex
        self.title = title
        self.mode = .display
        self.selectionMessage = selectionMessage
    }
    
    mutating func switchToSelection(){
        self.mode = .selection
    }
    
    mutating func toggleMode(){
        switch self.mode {
        case .display:
            self.mode = .selection
        case .selection:
            self.mode = .display
        }
    }
    
    func selectedValue() -> String? {
        var result:String? = nil
        result = values[selectedIndex]
        return result
    }
}

extension PickerSelectionValue: FormValueDisplayable {
    
    public typealias Cell = PickerSelectionCell
    public typealias Controller = FormTableViewController
    
    public func configureCell(_ formController: FormTableViewController, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        var newPickerSelection = PickerSelectionValue(title: self.title, values: self.values, self.selectedIndex, self.selectionMessage)
        newPickerSelection.mode = (self.mode == .selection) ? .display : .selection
        formController.dataSource.sections[path.section].rows[path.row] = newPickerSelection.formItem
        formController.tableView.reloadRows(at: [path], with: .automatic)
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}

extension PickerSelectionValue {
    public static func Random() -> PickerSelectionValue {
        let values = ["Orange","Tree","Rock","Saturday","Rocket","Guitar","Tacos","Video Games","Water Slides","Green","Christmas"].shuffled()
        let selected =  Int.random(in: 0...values.count-1)
        return PickerSelectionValue(title: "Picker", values: values, selected, "Pick Something")
    }
}



public final class PickerSelectionCell: UITableViewCell {
    static let identifier = "pickerSelectionCell"
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    var pickerView: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        if #available(iOS 10.0, *) { label.adjustsFontForContentSizeCategory = true }
        return label
    }()
    
    let selectedValue: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "-"
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .right
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .subheadline).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        if #available(iOS 10.0, *) { label.adjustsFontForContentSizeCategory = true }
        return label
    }()
    
    let selectionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .lightGray
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.text = "Make a Selection"
        if #available(iOS 10.0, *) { label.adjustsFontForContentSizeCategory = true }
        return label
    }()
    
    var standardHeightConstraint = NSLayoutConstraint()
    var pickerBottomConstriant = NSLayoutConstraint()
    var selectedBottomConstraint = NSLayoutConstraint()
    
    var pickerDataSource:[String] = [] {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    var formValue : PickerSelectionValue! {
        didSet {
            
            title.text = formValue.title
            selectionLabel.text = formValue.selectionMessage
            
            if formValue.selectedIndex >= formValue.values.count {
                print("SOMETHNG IS WRONG!!!!!")
            }
            
            if formValue.values.isEmpty {
                selectedValue.text = "-"
            } else {
                selectedValue.text = formValue.values[formValue.selectedIndex]
            }
            
            pickerDataSource = formValue.values
            
            switch formValue.mode {
            case .display:
                renderForDisplay()
            case .selection:
                renderForSelection()
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [title,selectedValue,selectionLabel,pickerView].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
        
        standardHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 44.0)
        standardHeightConstraint.priority = UILayoutPriority(499.0)
        standardHeightConstraint.isActive = true
        
        title.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        title.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
        
        selectedValue.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        selectedValue.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        selectedValue.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 2.0).isActive = true
        selectedBottomConstraint = selectedValue.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        
        selectionLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        selectionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        selectionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        
        pickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        pickerView.topAnchor.constraint(equalTo: selectionLabel.bottomAnchor).isActive = true
        pickerBottomConstriant = pickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        
    }
    
    func renderForDisplay() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.selectionLabel.isHidden = true
            self.title.isHidden = false
            self.selectedValue.isHidden = false
            self.selectedBottomConstraint.isActive = true
            self.pickerView.isHidden = true
            self.standardHeightConstraint.isActive = true
            self.pickerBottomConstriant.isActive = false
        }
    }
    
    func renderForSelection(){
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.title.isHidden = true
            self.selectedValue.isHidden = true
            self.selectedBottomConstraint.isActive = false
            self.selectionLabel.isHidden = false
            self.pickerView.isHidden = false
            self.standardHeightConstraint.isActive = false
            self.pickerBottomConstriant.isActive = true
            self.pickerView.selectRow(self.formValue.selectedIndex, inComponent: 0, animated: true)
        }
    }
    
}


extension PickerSelectionCell: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
}

extension PickerSelectionCell: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerDataSource.isEmpty {
            return nil
        }
        
        if row > pickerDataSource.count-1 {
            return nil
        } else {
            return pickerDataSource[row]
        }
        
    }
    
    
     
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // here is where we will collapse the view as well
        if let path = indexPath {
            let newFormValue = PickerSelectionValue(title: formValue.title, values: pickerDataSource, row)
            updateFormValueDelegate?.updatedFormValue(newFormValue, path)
        }
        
        
    }
    
    
}
