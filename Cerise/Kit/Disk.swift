//
//  Disk.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/7/14.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

struct Disk {
    enum Directory: Equatable {
        case documents
        case caches
        case temporary
    }

    enum Error: Swift.Error {
        case couldNotAccessUserDomainMask
    }

    private let fileManager: FileManager

    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }

    func url(atPath path: String, in directory: Directory) throws -> URL {
        guard let url = fileManager.urls(for: directory.searchPathDirectory, in: .userDomainMask).first else {
            throw Error.couldNotAccessUserDomainMask
        }

        return url.appendingPathComponent(path, isDirectory: false)
    }

    func urls(at url: URL) throws -> [URL] {
        return try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
    }

    func write(_ data: Data, to url: URL) throws {
        try data.write(to: url)
    }

    func read(from url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }
}

extension Disk {
    func remove(at url: URL) throws {
        try fileManager.removeItem(at: url)
    }

    func clear(_ directory: Directory) throws {
        let url = try self.url(atPath: "", in: directory)
        let urls = try self.urls(at: url)
        try urls.forEach(remove)
    }

    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>? = nil) -> Bool {
        return fileManager.fileExists(atPath: path, isDirectory: isDirectory)
    }

    func createDirecory(atPath path: String) throws {
        try? fileManager.createDirectory(atPath: path,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
    }

    func createDirectoryIfNecessary(at url: URL) throws {
        let directory = url.deletingLastPathComponent()

        var isDirectory: ObjCBool = false
        if !fileExists(atPath: directory.path, isDirectory: &isDirectory) {
            try createDirecory(atPath: directory.path)
        }

        if !isDirectory.boolValue {
            try createDirecory(atPath: directory.path)
        }
    }
}

extension Disk.Directory {
    var searchPathDirectory: FileManager.SearchPathDirectory {
        switch self {
        case .documents:
            return .documentDirectory
        case .caches:
            return .cachesDirectory
        case .temporary:
            return .trashDirectory
        }
    }
}
