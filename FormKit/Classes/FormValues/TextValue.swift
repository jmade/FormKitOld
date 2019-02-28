import UIKit


//: MARK: - TextValue -
public struct TextValue: FormValue, Equatable, Hashable {
    public var formItem: FormItem {
        return FormItem.text(self)
    }
    
    public enum Style {
        case horizontal,vertical
    }
    
    let title:String
    let value:String
    let style:Style
    let useDirectionButtons:Bool
    
    public init(title: String, value:String,_ style:Style = .horizontal,_ useDirectionButton:Bool = true) {
        self.title = title
        self.value = value
        self.style = style
        self.useDirectionButtons = useDirectionButton
    }
}


extension TextValue: FormValueDisplayable {
    
    public typealias Controller = FormTableViewController
    public typealias Cell = TextCell
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        if let textCell = formController.tableView.cellForRow(at: path) as? TextCell {
            textCell.activate()
        }
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}




extension TextValue {
    public static func Random() -> TextValue {
        let title = [
            "Entries","Team Name","Hometown","Favorite Food","Frist Name","Last Name","Email","Address"
            ].randomElement()!
        let style: TextValue.Style = Bool.random() ? .horizontal : .vertical
        return TextValue(title: title, value: "", style, true)
    }
}




//: MARK: TextCell
public final class TextCell: UITableViewCell {
    static let identifier = "textCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        return label
    }()
    
    var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.clearButtonMode = .always
        textField.returnKeyType = .done
        textField.keyboardType = .alphabet
        textField.tintColor = FormConstant.tintColor()
        textField.textAlignment = .left
        textField.font = UIFont.preferredFont(forTextStyle: .headline)
        return textField
    }()
    
    var formValue:TextValue? {
        didSet {
            if let textValue = formValue {
                titleLabel.text = textValue.title
                textField.text = textValue.value
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
        guard let textValue = formValue, didLayout == false else { return }
        
        evaluateButtonBar()
        let margin = contentView.layoutMarginsGuide
        
        switch textValue.style {
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
    
    func evaluateButtonBar(){
        guard let textValue = formValue else { return }
        if textValue.useDirectionButtons {
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

    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
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
        textField.backgroundColor = FormConstant.selectedTextBackground()
    }
    
    @objc
    func textFieldTextChanged() {
        print("TextField Changed")
        if let text = textField.text {
            guard let textValue = formValue else { return }
            updateFormValueDelegate?.updatedFormValue(TextValue(title: textValue.title, value: text), indexPath)
        }
    }
    
    private func endTextEditing(){
        textField.resignFirstResponder()
    }
    
    
}

extension TextCell: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endTextEditing()
        return true
    }
    
    // used to mask input
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
        self.textField.backgroundColor = FormConstant.selectedTextBackground()
        return true
    }
    
}
