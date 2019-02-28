
import UIKit


public struct FormConstant {
    
    static public func makeSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    static public func tintColor() -> UIColor {
        return .blue
    }
    
    static public func selectedTextBackground() -> UIColor {
        return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    }
    
}
