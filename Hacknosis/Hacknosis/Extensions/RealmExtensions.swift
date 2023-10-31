
import Foundation
import RealmSwift

extension Realm {

    /**
        Current schema version.
        - Note:
            If a Realm database migration is needed you'll need to imcrement this variable by 1 and optionally add a version to the `coreMigrationBlock`.
    */
    static var coreSchemaVersion: UInt64 = 12

    /**
        Core migration block is run when the app initially sets up the Realm database.
        - Note: This is used to migrate exisitng schema to the new schema.
            Example:
     ```
     if oldSchemaVersion < 2 {
         migration.renameProperty(onType: Environment.className(), from: "url", to: "urlString")
     }
     ```
     */
    static var coreMigrationBlock: RealmSwift.MigrationBlock = { migration, oldSchemaVersion in
        
    }
    
    /**
    This is used to avoid "Realm already in a write transaction" crashes that occur when a Realm in a given thread is already in a write transaction when this function is called.
     - Note:
        This first checks if Realm is already in a write transaction if so simply perform the block, otherwise surround the block in a write transaction.
        
        This should be used with caution if using cancelWriteTransaction as that cancel may be stopping more than what was intended. With OpenText Core we currently do not use cancelWriteTransaction so this should be the way to handle most writes to Realm.
        
        Please see [here](https://github.com/realm/realm-cocoa/issues/4511#issuecomment-270962198) for more information.
     */
    func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

//protocol RealmPersistableEnum: RawRepresentable, _PersistableInsideOptional { }
//
//extension RealmPersistableEnum where RawValue: _PersistableInsideOptional {
//    static func _rlmGetProperty(_ obj: ObjectBase, _ key: PropertyKey) -> Self? {
//        Self(rawValue: RawValue._rlmGetProperty(obj, key))
//    }
//
//    static func _rlmGetPropertyOptional(_ obj: ObjectBase, _ key: PropertyKey) -> Self? {
//        guard let value = RawValue._rlmGetPropertyOptional(obj, key) else { return nil }
//        return Self(rawValue: value)
//    }
//    
//    static func _rlmSetProperty(_ obj: ObjectBase, _ key: PropertyKey, _ value: Self) {
//        RawValue._rlmSetProperty(obj, key, value.rawValue)
//    }
//}
