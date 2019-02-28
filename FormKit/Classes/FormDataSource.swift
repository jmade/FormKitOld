import Foundation


//: MARK: - FormSection -
public class FormSection {
    var title:String
    var rows:[FormItem]
    
    public init(_ title:String,_ rows:[FormItem]) {
        self.title = title
        self.rows = rows
    }
    
    var inputRows:[Int] {
        var indicies:[Int] = []
        for (i,v) in rows.enumerated() {
            switch v {
            case .text(_),.note(_) ,.numerical(_):
                indicies.append(i)
            default:
                break
            }
        }
        return indicies
    }
    
    
    func itemForRowAt(_ row:Int) -> FormItem? {
        if rows.count-1 >= row {
            return rows[row]
        } else {
            return nil
        }
    }
    
    
    public class func Random() -> FormSection {
        var randomItems = Array( (0...Int.random(in: 2...6)) ).map({ _ in FormItem.Random() })
        randomItems.append(ButtonValue.Random().formItem)
        let randomTitle = [
    "Sunrise","Planning","Additional","Northern","Southern","Dynamic","Properties","Information","Status","Results"
        ].randomElement()!
        return FormSection(randomTitle, randomItems)
    }
    
}

extension FormSection: Hashable {
    
    public var hashValue: Int {
        return  "\(rows)".hashValue
    }
    
    public static func == (lhs: FormSection, rhs: FormSection) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

}




//: MARK: - FormDataSource -
public class FormDataSource {
    var sections:[FormSection]
    public init(sections:[FormSection]) {
        self.sections = sections
    }
    
    func rowsForSection(_ section:Int) -> [FormItem] {
        if sections.count-1 >= section {
            return sections[section].rows
        } else {
           return []
        }
    }
    
    public class func Random() -> FormDataSource {
        return FormDataSource(
            sections: Array(0...Int.random(in: 0...4)).map({ _ in FormSection.Random()})
        )
    }
    
}


extension FormDataSource {
    
    var isEmpty:Bool {
        return sections.isEmpty
    }
    
    func updateFirstSection(_ section:FormSection) {
        let existingSections = self.sections.dropFirst()
        self.sections = [[section],existingSections].reduce([],+)
    }
    
    
    func updateWith(formValue:FormValue,at path:IndexPath) {
        sections[path.section].rows[path.row] = formValue.formItem
    }
    
    
    func itemAt(_ path:IndexPath) -> FormItem? {
        if sections.count-1 >= path.section {
            return sections[path.section].itemForRowAt(path.row)
        } else {
            return nil
        }
    }
    
}


extension FormDataSource {
    
    var inputIndexPaths:[IndexPath] {
        var values:[IndexPath] = []
        Array(0..<sections.count).forEach({
            let sectionIndex = $0
            sections[$0].inputRows.forEach({
                values.append(IndexPath(row: $0, section: sectionIndex))
            })
        })
        return values
    }
    
    func nextIndexPath(_ from: IndexPath) -> IndexPath? {
        if let currentIndex = inputIndexPaths.indexOf(from) {
            let nextIndex = currentIndex + 1
            if nextIndex > inputIndexPaths.count - 1 {
                return inputIndexPaths.first
            } else {
                return inputIndexPaths[nextIndex]
            }
        } else {
            return nil
        }
    }
    
    func previousIndexPath(_ from: IndexPath) -> IndexPath? {
        if let currentIndex = inputIndexPaths.indexOf(from) {
            var nextIndex = currentIndex - 1
            if nextIndex < 0 {
                nextIndex = inputIndexPaths.count - 1
            }
            return inputIndexPaths[nextIndex]
        } else {
            return nil
        }
    }
    
}




