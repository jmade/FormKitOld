//
//  StepperValue.swift
//  FW Device
//
//  Created by Justin Madewell on 12/15/18.
//  Copyright © 2018 Jmade Technologies. All rights reserved.
//

import UIKit

//: MARK: - StepperValue -
public struct StepperValue: FormValue, Equatable, Hashable {
    var title:String
    var value:Double
    
    public init(title: String,value:Double) {
        self.title = title
        self.value = value
    }
    
    public var formItem: FormItem {
        return FormItem.stepper(self)
    }
}


//: MARK: - FormValueDisplayable -
extension StepperValue: FormValueDisplayable {
    
    public typealias Cell = StepperCell
    public typealias Controller = FormTableViewController
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        /*  */
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    
}

extension StepperValue {
    public static func Random() -> StepperValue {
        return StepperValue(title: "Stepper \(UUID().uuidString.split(separator: "-")[1])", value: Double.random(in: 0...99) )
    }
}





//: MARK: StepperCell
public final class StepperCell: UITableViewCell {
    static let identifier = "stepperCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    
    let stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.maximumValue = 99
        stepper.minimumValue = 0
        stepper.wraps = false
        stepper.tintColor = FormConstant.tintColor()
        return stepper
    }()
    
    let stepperLabel: BadgeSwift = {
        let badge = BadgeSwift()
        badge.textColor = .white
        badge.badgeColor = FormConstant.tintColor()
        badge.borderColor = .black
        return badge
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()
    
    var indexPath:IndexPath?
    
    var formValue:StepperValue? {
        didSet {
            if let stepperValue = formValue {
                stepper.value = stepperValue.value
                stepperLabel.text = String(Int(stepperValue.value))
                titleLabel.text = stepperValue.title
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [stepper,stepperLabel,titleLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })
        
        stepper.addTarget(self, action: #selector(stepperStepped(_:)), for: .valueChanged)
        let margin = contentView.layoutMarginsGuide
        let heightAnchorConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        heightAnchorConstraint.priority = UILayoutPriority(rawValue: 499)
        heightAnchorConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
            stepperLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.0),
            stepperLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
            stepper.trailingAnchor.constraint(equalTo: margin.trailingAnchor, constant: -4.0),
            stepper.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
            margin.bottomAnchor.constraint(equalTo: stepper.bottomAnchor, constant: 2.0)
            ])
    }
    
    @objc
    func stepperStepped(_ sender:UIStepper) {
        FormConstant.makeSelectionFeedback()
        stepperLabel.text = String(Int(sender.value))
        if let stepperValue = formValue {
            updateFormValueDelegate?.updatedFormValue(StepperValue(title: stepperValue.title, value: sender.value), indexPath)
        }
    }
}

