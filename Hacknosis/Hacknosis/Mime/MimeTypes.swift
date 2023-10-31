//
//  MimeTypes.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//


import Foundation

class MimeType {
    let mimeType: String
    let extensions: [String]

    init(mimeType: String, extensions: [String]) {
        precondition(extensions.count > 0, "MIME type must have one or more extensions")

        self.mimeType = mimeType
        self.extensions = extensions
    }
}

/// Simple interface to the MIME type database
public class MimeTypes {

    /// Returns an appropriate filename extension for the given MIME type
    public class func filenameExtension(forType type: String) -> String? {
        return MimeTypes.shared.filenameExtension(forType: type)
    }

    /// Returns all known filename extension for the given MIME type
    public class func filenameExtensions(forType type: String) -> [String] {
        return MimeTypes.shared.filenameExtensions(forType: type)
    }

    /// Returns the MIME type for the given filename extension
    public class func mimeType(forExtension ext: String) -> String? {
        return MimeTypes.shared.mimeType(forExtension: ext)
    }

    private static let shared = MimeTypes()

    private var byType = [String: MimeType]()
    private var byExtension = [String: MimeType]()

    private init() {
        let dbText = MimeTypes.readDBFromBundle()
        dbText.enumerateLines { line, _ in
            let fields = line.components(separatedBy: " ")
            if fields.count < 2 { return }
            let type = MimeType(mimeType: fields[0], extensions: Array(fields.suffix(from: 1)))

            self.byType[type.mimeType] = type
            for ext in type.extensions {
                self.byExtension[ext] = type
            }
        }
    }

    func filenameExtension(forType type: String) -> String? {
        return byType[type]?.extensions.first
    }

    func filenameExtensions(forType type: String) -> [String] {
        return byType[type]?.extensions ?? []
    }

    func mimeType(forExtension ext: String) -> String? {
        return byExtension[ext]?.mimeType
    }

    private static func readDBFromBundle() -> String {
        let toplevelBundle = Bundle(for: MimeType.self)

        guard let dbUrl = toplevelBundle.url(forResource: "mime", withExtension: "types") else {
            preconditionFailure("mime.types could not be found")
        }

        do {
            return try String(contentsOf: dbUrl, encoding: String.Encoding.utf8)
        } catch _ {
            preconditionFailure("mime.types could not be loaded")
        }
    }
}
