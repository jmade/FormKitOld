import UIKit

//: MARK: - NumericalValue -
public struct NumericalValue: FormValue, Equatable, Hashable {
    
    public var formItem: FormItem {
        get {
            return FormItem.numerical(self)
        }
    }
    
    public enum Style {
        case horizontal,vertical
    }
    
    let style:Style
    let useDirectionButtons:Bool
    let title:String
    let value:String
    
   public init(title: String, value:String,_ style:Style = .horizontal,_ useDirectionButton:Bool = true) {
        self.title = title
        self.value = value
        self.style = style
        self.useDirectionButtons = useDirectionButton
    }
}



extension NumericalValue: FormValueDisplayable {
    
    public typealias Cell = NumericalCell
    public typealias Controller = FormTableViewController
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        if let numericalCell = formController.tableView.cellForRow(at: path) as? NumericalCell {
            numericalCell.activate()
        }
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}

extension NumericalValue {
    public static func Random() -> NumericalValue {
        let title = [
            "Books","Jars","Pounds","Ounces","Trucks","Containers","Beers","Drinks","Roads","Items","Elements"
        ].randomElement()!
        return NumericalValue(title: title, value: "\(Int(Double.random(in: 0...99)))", .horizontal, true)
    }
}



//: MARK: NumericalCell
public final class NumericalCell: UITableViewCell {
    static let identifier = "numericalCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()
    
    var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.returnKeyType = .done
        textField.tintColor = FormConstant.tintColor()
        textField.textAlignment = .left
        textField.font = UIFont.preferredFont(forTextStyle: .headline)
        return textField
    }()
    
    var formValue : NumericalValue? {
        didSet {
            if let numericalValue = formValue {
                titleLabel.text = numericalValue.title
                textField.text = numericalValue.value
                layout()
            }
           
        }
    }
    
    private var didLayout:Bool = false
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [titleLabel,textField].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
        titleLabel.text = nil
        indexPath = nil
    }
    
    func layout(){
        guard let numericalValue = formValue, didLayout == false else { return }
        
        evaluateButtonBar()
        let margin = contentView.layoutMarginsGuide
        
        switch numericalValue.style {
        case .horizontal:
            
            let heightAnchorConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
            heightAnchorConstraint.priority = UILayoutPriority(rawValue: 499)
            
            NSLayoutConstraint.activate([
                heightAnchorConstraint,
                titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.5),
                ])
        case .vertical:
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                titleLabel.topAnchor.constraint(equalTo: margin.topAnchor),
                
                textField.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0),
                margin.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4.0)
                ])
        }
        
        didLayout = true
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            FormConstant.makeSelectionFeedback()
            textField.becomeFirstResponder()
        }
    }
    
    func evaluateButtonBar(){
        guard let numericalValue = formValue else { return }
        if numericalValue.useDirectionButtons {
            // Toolbar
            let bar = UIToolbar()
            let previous = UIBarButtonItem(image: Image.Chevron.previousChevron, style: .plain, target: self, action: #selector(previousAction))
            let next = UIBarButtonItem(image: Image.Chevron.nextChevron, style: .plain, target: self, action: #selector(nextAction))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
            bar.items = [previous,next,spacer,done]
            
            bar.sizeToFit()
            textField.inputAccessoryView = bar
        }
    }
    
    
    @objc
    func doneAction(){
        endTextEditing()
    }
    
    @objc
    func previousAction(){
        if let path = indexPath {
            updateFormValueDelegate?.toggleTo(.previous, path)
        }
    }
    
    @objc
    func nextAction(){
        if let path = indexPath {
            updateFormValueDelegate?.toggleTo(.next, path)
        }
    }
    
    public func activate(){
        FormConstant.makeSelectionFeedback()
        textField.becomeFirstResponder()
    }
    
    @objc
    func textFieldTextChanged() {
        if let text = textField.text {
            guard let textValue = formValue else { return }
            updateFormValueDelegate?.updatedFormValue(NumericalValue(title: textValue.title, value: text), indexPath)
        }
    }
    
    private func endTextEditing(){
        textField.resignFirstResponder()
    }
    
}

extension NumericalCell: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endTextEditing()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // mask for digits only
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
       endTextEditing()
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.textField.backgroundColor = .white
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textField.backgroundColor = #colorLiteral(red: 0.2404008512, green: 0.7015445539, blue: 1, alpha: 1)
        return true
    }
    
}

