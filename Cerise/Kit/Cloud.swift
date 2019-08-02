//
//  Cloud.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/7/21.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

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

    init?(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
        start()
    }

    func isAvailable() -> Bool {
        return containerURL != nil
    }

    private func start() {
        guard let url = fileManager.url(forUbiquityContainerIdentifier: Cloud.identifier) else {
            return
        }
        self.containerURL = url
    }

    func url(atPath path: String, in scope: UbiquitousScope) throws -> URL {
        guard let containerURL = containerURL else {
            throw Error.containerNotExists
        }

        return containerURL.appendingPathComponent(scope.pathComponent, isDirectory: true)
            .appendingPathComponent(path)
    }

    func contents(at url: URL, in scope: UbiquitousScope, completionHandler: @escaping ([URL]) -> Void) -> Bool {
        let query = NSMetadataQuery()
        query.predicate = NSPredicate(format: "(%K BEGINSWITH[CD] %@)", NSMetadataItemPathKey, url.path)
        query.valueListAttributes = [NSMetadataItemURLKey]
        query.searchScopes = [scope]

        var observer: NSObjectProtocol?
        observer = NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidFinishGathering,
            object: nil,
            queue: nil) { _ in
                query.disableUpdates()
                query.stop()
                observer.flatMap(NotificationCenter.default.removeObserver)
                observer = nil
                guard let items = query.results as? [NSMetadataItem] else {
                    return
                }

                let urls = items.compactMap { $0.value(forAttribute: NSMetadataItemURLKey) as? URL }
                completionHandler(urls)
        }

        return query.start()
    }

    func sync(itemAt localURL: URL) throws {
        let ubiquityURL = try url(atPath: localURL.lastPathComponent, in: .documents)
        try setUbiquitous(true, itemAt: localURL, to: ubiquityURL)
    }

    func remove(itemAt localURL: URL) throws {
        let ubiquityURL = try url(atPath: localURL.lastPathComponent, in: .documents)
        try setUbiquitous(false, itemAt: localURL, to: ubiquityURL)
    }

    func setUbiquitous(_ flag: Bool, itemAt localURL: URL, to destinationURL: URL) throws {
        try fileManager.setUbiquitous(flag, itemAt: localURL, destinationURL: destinationURL)
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
