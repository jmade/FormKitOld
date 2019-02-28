import UIKit


//: MARK: - CustomTransitionable -
protocol CustomTransitionable: class {
    var customTransitioningDelegate: PresentationTransitioningDelegate { get }
    /* var customTransitioningDelegate = PresentationTransitioningDelegate() */
}


//: MARK: - BottomBarActionItem -å
public struct BottomBarActionItem {
    
    public enum Position {
        case leading, center, trailing
    }
    
    public typealias ActionClosure = (FormTableViewController) -> Void
    
    let position:Position
    let title:String
    let actionClosure:ActionClosure
    var spacer:Bool
    public init(title:String,position:Position,closure: @escaping ActionClosure) {
        self.title = title
        self.position = position
        self.actionClosure = closure
        self.spacer = false
    }
}

extension BottomBarActionItem {
    static func Spacer() -> BottomBarActionItem {
        var spacerItem = BottomBarActionItem(title: "", position: .center, closure: { _ in })
        spacerItem.spacer = true
        return spacerItem
    }
}


//: MARK: - FormTableViewController -
open class FormTableViewController: UITableViewController, CustomTransitionable {
    
    var customTransitioningDelegate = PresentationTransitioningDelegate()
    
    var bottomBarItems:[BottomBarActionItem] = []
    var leadingToolBarButtonTitle:String?
    var trailingToolBarButtonTitle:String?

    var selectedIndexPath: IndexPath?
    var reuseIdentifiers: Set<String> = []
    
    public var dataSource = FormDataSource(sections: []) {
        didSet {
            
            guard !dataSource.isEmpty else {
                (tableView.tableFooterView as! ItemsLoadingView).displayMessage("No Data")
                return
            }
            
            tableView.tableFooterView = nil
            
            if oldValue.isEmpty {
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let self = self else { return }
                    if self.tableView.numberOfSections == 0 {
                        self.tableView.insertSections(
                            IndexSet(integersIn: 0...(self.dataSource.sections.count-1)),
                            with: .top
                        )
                    } else {
                        self.tableView.reloadSections(
                            IndexSet(integersIn: 0...(self.dataSource.sections.count-1)),
                            with: .automatic
                        )
                    }
                })
            } else {
                
                let old = oldValue
                let new = dataSource
                
                struct SectionChange {
                    enum Operation {
                        case adding,deleting,reloading
                    }
                    let operation:Operation
                    let section: Int
                    var changes:[Change<FormItem>]?
                    var indexSet:IndexSet?
                }
                
                var sectionChanges:[SectionChange] = []
                
                for i in 0..<max(old.sections.count, new.sections.count) {
                    let isOldSectionEmpty = old.rowsForSection(i).isEmpty
                    let isNewSectionEmpty = new.rowsForSection(i).isEmpty
                    let changingSection = (isOldSectionEmpty == false) && (isNewSectionEmpty == false)
                    let addingSection = (isOldSectionEmpty == true) && (isNewSectionEmpty == false)
                    let removingSection = (isOldSectionEmpty == false) && (isNewSectionEmpty == true)
                    if changingSection {
                        let changes = diff(old: old.rowsForSection(i), new: new.rowsForSection(i))
                        sectionChanges.append(SectionChange(operation: .reloading, section: i, changes: changes, indexSet: nil))
                    }
                    if addingSection {
                        sectionChanges.append(SectionChange(operation: .adding, section: i, changes: nil, indexSet: IndexSet(arrayLiteral: i)))
                    }
                    if removingSection {
                        sectionChanges.append(SectionChange(operation: .deleting, section: i, changes: nil, indexSet: IndexSet(arrayLiteral: i)))
                    }
                }
                
                let inserts = sectionChanges.filter({ $0.operation == .adding }).map({$0.section})
                let deletes = sectionChanges.filter({ $0.operation == .deleting }).map({$0.section})
                let reloads = sectionChanges.filter({ $0.operation == .reloading })
                
                var sectionReloads:[Int] = []
                var actualInserts:[Int] = []
                for i in inserts {
                    if Array(0..<old.sections.count).contains(i) {
                        sectionReloads.append(i)
                    } else {
                        actualInserts.append(i)
                    }
                }
                
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let self = self else { return }
                    self.tableView.beginUpdates()
                    self.tableView.insertSections(IndexSet(actualInserts), with: .automatic)
                    self.tableView.deleteSections(IndexSet(deletes), with: .automatic)
                    self.tableView.reloadSections(IndexSet(sectionReloads), with: .automatic)
                    reloads.forEach({
                        if let sectionHeader = self.tableView.headerView(forSection: $0.section) as? FormHeaderCell {
                            sectionHeader.titleLabel.text = self.dataSource.sections[$0.section].title
                        }
                        if let changes = $0.changes {
                            self.tableView.reload(
                                changes: changes,
                                section: $0.section,
                                insertionAnimation: .automatic,
                                deletionAnimation:  .automatic,
                                replacementAnimation:  .automatic,
                                completion: nil
                            )
                        }
                    })
                    self.tableView.endUpdates()
                })
            }
            

            
            
        }
    }
    
    
    //: MARK: - init -
    deinit {}
    required public init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableView.Style) {
        super.init(style: style)
        // Header Cell
        tableView.register(FormHeaderCell.self, forHeaderFooterViewReuseIdentifier: FormHeaderCell.identifier)
        tableView.keyboardDismissMode = .interactive
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = ItemsLoadingView()
        
        /*
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(cancelPressed))
        */
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        setupToolBar()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if toolbarItems != nil {
            self.navigationController?.setToolbarHidden(false, animated: false)
        } else {
            self.navigationController?.setToolbarHidden(true, animated: false)
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
}


// Toolbar Section
extension FormTableViewController {
    
    func setupToolBar(){
        if bottomBarItems.isEmpty { return }
        var barItems:[UIBarButtonItem] = []
        for item in bottomBarItems {
            if item.spacer {
                barItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
            } else {
                switch item.position {
                case .leading:
                    barItems.append(
                        UIBarButtonItem(customView:
                            RoundButton(
                                titleText: item.title,
                                target: self,
                                action: #selector(leadingButtonBarPressed),
                                color: .lightGray,
                                style: .bar
                            )
                    ))
                case .center:
                    barItems.append(UIBarButtonItem(title: item.title, style: .plain, target: self, action: #selector(centerBarButtonPressed)))
                case .trailing:
                    barItems.append(
                        UIBarButtonItem(customView:
                            RoundButton(
                                titleText: item.title,
                                target: self,
                                action: #selector(trailingBarButtonPressed),
                                color: .lightGray,
                                style: .bar
                            )
                    ))
                }
            }
        }
        toolbarItems = barItems
    }
    
    // ToolBar Presses
    @objc
    func leadingButtonBarPressed(){
        (toolbarItems!.first!.customView! as! RoundButton).animateTitleAndColor("Copied", #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
        for item in bottomBarItems where item.position == .leading {
            item.actionClosure(self)
        }
    }
    
    @objc
    func trailingBarButtonPressed(){
        (toolbarItems!.last!.customView! as! RoundButton).animateTitleAndColor("Pasted", #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
        for item in bottomBarItems where item.position == .trailing {
            item.actionClosure(self)
        }
    }
    
    @objc
    func centerBarButtonPressed(){
        for item in bottomBarItems where item.position == .center {
            item.actionClosure(self)
        }
    }
    
    
    // Navigation Bar Buttons
    @objc
    func cancelPressed(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func donePressed(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  [weak self] in
            guard let self = self else { return }
            self.dataSource = FormDataSource.Random()
            self.refreshControl?.endRefreshing()
        }
    }
    
}



// MARK: - TableView -
extension FormTableViewController {
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sections.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.sections[section].rows.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let formItem = dataSource.itemAt(indexPath) {
            let descriptor = formItem.cellDescriptor
            if !reuseIdentifiers.contains(descriptor.reuseIdentifier) {
                tableView.register(descriptor.cellClass, forCellReuseIdentifier: descriptor.reuseIdentifier)
                reuseIdentifiers.insert(descriptor.reuseIdentifier)
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: descriptor.reuseIdentifier, for: indexPath)
            descriptor.configure(self, cell, indexPath)
            return cell
        }
        return .init()
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        if let item = dataSource.itemAt(indexPath) {
            item.cellDescriptor.didSelect(self,indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !dataSource.sections[section].title.isEmpty {
            if let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: FormHeaderCell.identifier) as? FormHeaderCell {
                headerCell.titleLabel.text = dataSource.sections[section].title
                return headerCell
            }
        }
        return nil
    }
    
    override open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource.sections[section].title.isEmpty ? 0 : UITableView.automaticDimension
    }
    
    override open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}




//: MARK: - UpdateFormValueDelegate -
extension FormTableViewController: UpdateFormValueDelegate {
    
    public func updatedFormValue(_ formValue: FormValue, _ indexPath: IndexPath?) {
        if let path = indexPath {
            if let formItem = dataSource.itemAt(path) {
                switch formItem {
                case .stepper(let stepper):
                    if let stepperValue = formValue as? StepperValue {
                        if stepperValue != stepper {
                            dataSource.updateWith(formValue: stepperValue, at: path)
                        }
                    }
                case .text(let text):
                    if let textValue = formValue as? TextValue {
                        if textValue != text {
                            dataSource.updateWith(formValue: textValue, at: path)
                        }
                    }
                case .time(let time):
                    if let timeValue = formValue as? TimeValue {
                        if timeValue != time {
                            dataSource.updateWith(formValue: timeValue, at: path)
                            tableView.reloadRows(at: [path], with: .none)
                        }
                    }
                case .button(_):
                    break
                case .note(let note):
                    if let noteValue = formValue as? NoteValue {
                        if noteValue != note {
                            dataSource.updateWith(formValue: noteValue, at: path)
                        }
                    }
                case .segment(let segment):
                    if let segmentValue = formValue as? SegmentValue {
                        if segmentValue != segment {
                            dataSource.updateWith(formValue: segmentValue, at: path)
                        }
                    }
                case .numerical(let numerical):
                    if let numericalValue = formValue as? NumericalValue {
                        if numericalValue != numerical {
                            dataSource.updateWith(formValue: numericalValue, at: path)
                        }
                    }
                case .readOnly(let readOnly):
                    if let readOnlyValue = formValue as? ReadOnlyValue {
                        if readOnlyValue != readOnly {
                            dataSource.updateWith(formValue: readOnlyValue, at: path)
                        }
                    }
                case .picker(let picker):
                    if let pickerValue = formValue as? PickerValue {
                        if pickerValue != picker {
                            dataSource.updateWith(formValue: pickerValue, at: path)
                        }
                    }
                case .pickerSelection(let pickerSelection):
                    if let pickerSelectionValue = formValue as? PickerSelectionValue {
                        if pickerSelectionValue != pickerSelection {
                            dataSource.updateWith(formValue: pickerSelectionValue, at: path)
                            tableView.reloadRows(at: [path], with: .automatic)
                        }
                    }
                }
            }
        }
    }
    

    public func toggleTo(_ direction: Direction, _ from: IndexPath) {
        if let currentCell = tableView.cellForRow(at: from) {
            currentCell.resignFirstResponder()
        }
        switch direction {
        case .previous:
            if let previousIndexPath = dataSource.previousIndexPath(from) {
                tableView.scrollToRow(at: previousIndexPath, at: .none, animated: false)
                if let previousCell = tableView.cellForRow(at: previousIndexPath) {
                    if previousCell is TextCell {(previousCell as! TextCell).activate()}
                    if previousCell is NoteCell {(previousCell as! NoteCell).activate()}
                    if previousCell is NumericalCell {(previousCell as! NumericalCell).activate()}
                }
            }
        case .next:
            if let nextIndexPath = dataSource.nextIndexPath(from) {
                tableView.scrollToRow(at: nextIndexPath, at: .none, animated: false)
                if let nextCell = tableView.cellForRow(at: nextIndexPath) {
                    if nextCell is TextCell {(nextCell as! TextCell).activate()}
                    if nextCell is NoteCell {(nextCell as! NoteCell).activate()}
                    if nextCell is NumericalCell {(nextCell as! NumericalCell).activate()}
                }
            }
        }
        FormConstant.makeSelectionFeedback()
    }
}

extension FormTableViewController: ButtonActionDelegate {
    
    public func performAction(_ action: String) {
        print("Button Was Tapped: \(action)")
        pushNewRandomForm()
    }
    
    func pushNewRandomForm(){
        let newFormController = FormTableViewController(style: .grouped)
        newFormController.dataSource = FormDataSource.Random()
        navigationController?.pushViewController(newFormController, animated: true)
    }
    
}



//: MARK: - DispatchHeaderCell -
public final class FormHeaderCell: UITableViewHeaderFooterView {
    static let identifier = "formHeaderCell"
    let titleLabel: UILabel = .init()
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .title2).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true
        
        let trailingConstraint = contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        trailingConstraint.priority = UILayoutPriority(rawValue: 999)
        trailingConstraint.isActive = true
        
        let bottomConstraint = contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        bottomConstraint.priority = UILayoutPriority(rawValue: 999)
        bottomConstraint.isActive = true
        
        let heightAnchorConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        heightAnchorConstraint.priority = UILayoutPriority(rawValue: 499)
        heightAnchorConstraint.isActive = true
    }
}
