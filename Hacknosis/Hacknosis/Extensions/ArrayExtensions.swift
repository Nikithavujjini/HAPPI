

import Foundation

extension Array where Element: Equatable, Element: Identifiable {
    func removeDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.map({$0.id}).contains(element.id) {
                result.append(element)
            }
        }
    }
}



public extension String {
    ///Used to easily localize a string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

