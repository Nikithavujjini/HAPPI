
import Foundation

public extension UserDefaults {

    class var appGroup: UserDefaults? {
        return UserDefaults(suiteName: AppGroup)
    }
}
