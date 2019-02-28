import UIKit

//: MARK: - NoteValue -
public struct NoteValue: FormValue, TextNumericalInput, Equatable, Hashable {
    
    public var formItem: FormItem {
        get {
            return FormItem.note(self)
        }
    }
    
    var value:String
    var useDirectionButtons:Bool
    
    public init(value: String,_ useDirectionButtons:Bool = true) {
        self.value = value
        self.useDirectionButtons = useDirectionButtons
    }
}


extension NoteValue: FormValueDisplayable {
    
    public typealias Cell = NoteCell
    public typealias Controller = FormTableViewController
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        if let noteCell = formController.tableView.cellForRow(at: path) as? NoteCell {
            noteCell.activate()
        }
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}


extension NoteValue {
    public static func Random() -> NoteValue {
        return NoteValue(value: "", true)
    }
}


//: MARK: - NoteCell -
public final class NoteCell: UITableViewCell {
    static let identifier = "noteCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.keyboardType = .alphabet
        textView.returnKeyType = .default
        textView.tintColor = FormConstant.tintColor()
        textView.textAlignment = .left
        textView.font = UIFont.preferredFont(forTextStyle: .headline)
        return textView
    }()
    
    var formValue : NoteValue! {
        didSet {
            evaluateButtonsBar()
            textView.text = formValue.value
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.masksToBounds = true
        
        if #available(iOS 11.0, *) {
            textView.layer.maskedCorners = [
                CACornerMask.layerMaxXMaxYCorner,
                CACornerMask.layerMaxXMinYCorner,
                CACornerMask.layerMinXMaxYCorner,
                CACornerMask.layerMinXMinYCorner,
            ]
        }
        textView.layer.cornerRadius = 8.0
        textView.layer.masksToBounds = true
        textView.delegate = self
        contentView.addSubview(textView)
        
        let heightAnchorConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 88.0)
        heightAnchorConstraint.priority = UILayoutPriority(rawValue: 499)
        heightAnchorConstraint.isActive = true
        
        let margin = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            textView.topAnchor.constraint(equalTo: margin.topAnchor),
            margin.bottomAnchor.constraint(equalTo: textView.bottomAnchor)
            ])
    }
    
    func evaluateButtonsBar() {
        let bar = UIToolbar()
        if formValue.useDirectionButtons {
            bar.items = [UIBarButtonItem(image: Image.Chevron.previousChevron, style: .plain, target: self, action: #selector(previousAction)),UIBarButtonItem(image: Image.Chevron.nextChevron, style: .plain, target: self, action: #selector(nextAction)), UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))]
        } else {
            bar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))]
        }
        bar.sizeToFit()
        textView.inputAccessoryView = bar
    }
    
    @objc
    func doneAction(){
        textView.resignFirstResponder()
        sendTextToDelegate()
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
    
    private func sendTextToDelegate() {
        if let newText = textView.text {
            if let existingNoteValue = formValue {
                updateFormValueDelegate?.updatedFormValue(NoteValue(value: newText, existingNoteValue.useDirectionButtons), indexPath)
            }
        }
    }
    
    public func activate(){
        textView.becomeFirstResponder()
        FormConstant.makeSelectionFeedback()
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
}

extension NoteCell: UITextViewDelegate {
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.backgroundColor = FormConstant.selectedTextBackground()
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        textView.backgroundColor = .white
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        sendTextToDelegate()
    }
    
}
