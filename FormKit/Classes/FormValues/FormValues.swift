import UIKit

public protocol FormValue {
    var formItem:FormItem {get}
}

public protocol TextNumericalInput {}

//: MARK: - Direction -
public enum Direction {
    case previous, next
}

//: MARK: - UpdateFormValueDelegate -
public protocol UpdateFormValueDelegate: class {
    func updatedFormValue(_ formValue:FormValue,_ indexPath:IndexPath?)
    func toggleTo(_ direction:Direction,_ from:IndexPath)
}


//: MARK: - UpdatedTextDelegate
public protocol UpdatedTextDelegate: class {
    func updatedTextForIndexPath(_ newText:String,_ indexPath:IndexPath)
    func toggleTo(_ direction:Direction,_ from:IndexPath)
    func textEditingFinished(_ text:String,_ from:IndexPath)
}
