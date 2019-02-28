//
//  FormItem.swift
//  FW Device
//
//  Created by Justin Madewell on 12/18/18.
//  Copyright © 2018 Jmade Technologies. All rights reserved.
//

import UIKit

//: MARK: - FormConfigurable Protocol -
public protocol FormConfigurable {
    associatedtype Cell
    associatedtype Controller
    func didSelect(_ formController:Controller,_ path:IndexPath)
    func configureCell(_ formController:Controller,_ cell:Cell,_ path:IndexPath)
}


//: MARK: - FormCellDescriptor -
public struct FormCellDescriptor {
    let cellClass: UITableViewCell.Type
    let reuseIdentifier: String
    let configure: (UIViewController,UITableViewCell,IndexPath) -> ()
    let didSelect: (UIViewController,IndexPath) -> ()
    
    public init<Cell: UITableViewCell, Controller: UIViewController>(
        _ reuseIdentifier: String,
        _ configure: @escaping (Controller,Cell,IndexPath) -> (),
        _ didSelect: @escaping (Controller,IndexPath) -> ()
        ) {
        self.cellClass = Cell.self
        self.reuseIdentifier = reuseIdentifier
        self.configure = { controller,cell,path in configure( (controller as! Controller),(cell as! Cell),path) }
        self.didSelect = { controller,path in didSelect( (controller as! Controller), path) }
    }
}


//: MARK: - FormCellDescriptable Protocol -
public protocol FormCellDescriptable {
    var cellDescriptor:FormCellDescriptor { get }
}

public typealias FormValueDisplayable = FormConfigurable & FormCellDescriptable

//: MARK: - FormItem -
public enum FormItem {
    case stepper(StepperValue)
    case text(TextValue)
    case time(TimeValue)
    case button(ButtonValue)
    case note(NoteValue)
    case segment(SegmentValue)
    case numerical(NumericalValue)
    case readOnly(ReadOnlyValue)
    case picker(PickerValue)
    case pickerSelection(PickerSelectionValue)
}



//: MARK: - CellDescriptable -
extension FormItem: FormCellDescriptable {
    // extend the value type with a `CellDescriptor` var to add support for initialization of each cell type
    public var cellDescriptor: FormCellDescriptor {
        switch self {
        case .stepper(let stepper):
            return stepper.cellDescriptor
        case .text(let text):
            return text.cellDescriptor
        case .time(let time):
            return time.cellDescriptor
        case .button(let button):
            return button.cellDescriptor
        case .note(let note):
            return note.cellDescriptor
        case .segment(let segment):
            return segment.cellDescriptor
        case .numerical(let numerical):
            return numerical.cellDescriptor
        case .readOnly(let readOnly):
            return readOnly.cellDescriptor
        case .picker(let picker):
            return picker.cellDescriptor
        case .pickerSelection(let pickerSelection):
            return pickerSelection.cellDescriptor
        }
    }
}


extension FormItem: Hashable, Equatable {
    
    public static func == (lhs: FormItem, rhs: FormItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public var hashValue: Int {
        switch self {
        case .stepper(let stepper):
            return stepper.hashValue
        case .text(let text):
            return text.hashValue
        case .time(let time):
            return time.hashValue
        case .button(let button):
            return button.hashValue
        case .note(let note):
            return note.hashValue
        case .segment(let segment):
            return segment.hashValue
        case .numerical(let numerical):
            return numerical.hashValue
        case .readOnly(let readOnly):
            return readOnly.hashValue
        case .picker(let picker):
            return picker.hashValue
        case .pickerSelection(let pickerSelection):
            return pickerSelection.hashValue
        }
    }
    
   public  static func Random() -> FormItem {
        return [
            StepperValue.Random().formItem,
            TextValue.Random().formItem,
            TimeValue.Random().formItem,
            ButtonValue.Random().formItem,
            NoteValue.Random().formItem,
            SegmentValue.Random().formItem,
            NumericalValue.Random().formItem,
            ReadOnlyValue.Random().formItem,
            PickerSelectionValue.Random().formItem,
            ].randomElement()!
    }
    
}
