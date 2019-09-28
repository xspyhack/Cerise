//
//  Cloud.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/7/21.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

/// Ubiquitous service for manager iCloud files. Copy, remove, move...
final class Cloud {
    /// iCloud directory
    enum UbiquitousScope: Equatable {
        case documents
        case data
    }

    /// Error
    enum Error: Swift.Error {
        case couldNotAccessUbiquity
        case containerNotExists
    }

    static let shared = Cloud()

    private static let identifier = "iCloud.com.xspyhack.Cerise"
    private let queue = DispatchQueue(label: "com.xspyhack.cloud")
    private let fileManager: FileManager
    private var containerURL: URL?

    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
        start()
    }

    private func start() {
        guard let url = fileManager.url(forUbiquityContainerIdentifier: Cloud.identifier) else {
            return
        }
        self.containerURL = url
    }

    /// Cloud is available
    func isAvailable() -> Bool {
        return containerURL != nil
    }

    /// Cloud URL with path in the ubiquitous scope of container
    /// - Parameter path: File path
    /// - Parameter scope: Ubiquitous scope
    func url(atPath path: String, in scope: UbiquitousScope) throws -> URL {
        guard let containerURL = containerURL else {
            throw Error.containerNotExists
        }

        return containerURL.appendingPathComponent(scope.pathComponent, isDirectory: true)
            .appendingPathComponent(path)
    }

    /// Performs a shallow search of the specified directory asynchronously.
    /// - Parameter url: The URL for the directory whose contents you want to enumerate.
    /// - Parameter scope: The search ubiquitous scope
    /// - Parameter completionHandler: The handler to call when the search is completion.
    @discardableResult
    func contents(atPath path: String, in scope: UbiquitousScope, completionHandler: @escaping ([URL]) -> Void) throws -> Bool {
        let url = try self.url(atPath: path, in: scope)
        let query = NSMetadataQuery()
        query.predicate = NSPredicate(format: "(%K BEGINSWITH[CD] %@)", NSMetadataItemPathKey, url.path)
        query.valueListAttributes = [NSMetadataItemURLKey]
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]

        var observer: NSObjectProtocol?
        observer = NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidFinishGathering,
            object: query,
            queue: nil) { _ in
                query.disableUpdates()
                query.stop()
                observer.flatMap(NotificationCenter.default.removeObserver)
                observer = nil
                guard let items = query.results as? [NSMetadataItem] else {
                    return
                }

                let urls = items.compactMap { $0.value(forAttribute: NSMetadataItemURLKey) as? URL }
                    .filter { $0 != url }
                    .map { $0.standardized }
                completionHandler(urls)
        }

        return query.start()
    }

    /// Coping a file into iCloud
    /// - Parameter localURL: The URL of the item (file or directory) that you want to store in iCloud.
    func copyItem(at localURL: URL) throws {
        // make a copy first
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(localURL.lastPathComponent)
        if fileManager.fileExists(atPath: tempURL.path) {
            try fileManager.removeItem(at: tempURL)
        }
        try fileManager.copyItem(at: localURL, to: tempURL)
        // move into iCloud
        try moveItem(from: tempURL)
    }

    /// Removing a file out of iCloud
    /// - Parameter localURL: The URL of the item (file or directory) that you want to remove out of iCloud.
    func removeItem(at localURL: URL) throws {
        let ubiquityURL = try url(atPath: localURL.lastPathComponent, in: .documents)
        try fileManager.removeItem(at: ubiquityURL)
    }

    /// Moving a file into iCloud
    /// - Parameter localURL: The URL of the item (file or directory) that you want to store in iCloud.
    func moveItem(from localURL: URL) throws {
        let ubiquityURL = try url(atPath: localURL.lastPathComponent, in: .documents)
        try setUbiquitous(true, itemAt: localURL, to: ubiquityURL)
    }

    /// Moving a file out of iCloud
    /// - Parameter localURL: The location on the local device.
    func moveItem(to localURL: URL) throws {
        let ubiquityURL = try url(atPath: localURL.lastPathComponent, in: .documents)
        try setUbiquitous(false, itemAt: ubiquityURL, to: localURL)
    }

    /// Indicates whether the item at the specified URL should be stored in iCloud.
    /// - Parameter flag: YES to move the item to iCloud or NO to remove it from iCloud (if it is there currently).
    /// - Parameter sourceURL: The URL of the item (file or directory) that you want to store in iCloud.
    /// - Parameter destinationURL: The location on the local device or in  iCloud.
    func setUbiquitous(_ flag: Bool, itemAt sourceURL: URL, to destinationURL: URL) throws {
        try fileManager.setUbiquitous(flag, itemAt: sourceURL, destinationURL: destinationURL)
    }
}

extension Cloud.UbiquitousScope {
    var searchScope: String {
        switch self {
        case .documents:
            return NSMetadataQueryUbiquitousDocumentsScope
        case .data:
            return NSMetadataQueryUbiquitousDataScope
        }
    }

    var pathComponent: String {
        switch self {
        case .documents:
            return "Documents"
        case .data:
            return ""
        }
    }
}
