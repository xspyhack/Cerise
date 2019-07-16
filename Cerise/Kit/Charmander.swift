//
//  Charmander.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/23.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

protocol StoreKey {
    var identifier: String { get }
}

extension String: StoreKey {
    var identifier: String {
        return self
    }
}

struct Charmander {
    let disk: Disk
    let directory: Disk.Directory
    let folder: String

    init(disk: Disk = Disk(),
         directory: Disk.Directory = .documents,
         folder: String = "com.blessingsoftware.cerise") {
        self.disk = disk
        self.directory = directory
        self.folder = folder
    }

    func store<Object: Encodable>(_ object: Object,
                                  forKey key: StoreKey,
                                  encoder: JSONEncoder = JSONEncoder()) throws {
        let url = try disk.url(atPath: path(forKey: key), in: directory)
        try disk.createDirectoryIfNecessary(at: url)
        let data = try encoder.encode(object)
        try disk.write(data, to: url)
    }

    func retrieve<Object: Decodable>(forKey key: StoreKey,
                                     type: Object.Type,
                                     decoder: JSONDecoder = JSONDecoder()) throws -> Object {
        let url = try disk.url(atPath: path(forKey: key), in: directory)
        let data = try disk.read(from: url)
        return try decoder.decode(type, from: data)
    }

    func retrieveAll<Object: Decodable>(type: Object.Type,
                                        decoder: JSONDecoder = JSONDecoder(),
                                        sortBy sorting: Disk.Sorting = .none) throws -> [Object] {
        let url = try disk.url(atPath: "\(folder)/", in: directory)
        let urls = try disk.urls(at: url, sortBy: sorting)
        return try urls.map { try disk.read(from: $0) }
            .map { try decoder.decode(type, from: $0) }
    }

    func remove(forKey key: StoreKey) throws {
        let url = try disk.url(atPath: path(forKey: key), in: directory)
        try disk.remove(at: url)
    }

    func clear() throws {
        let url = try disk.url(atPath: "\(folder)/", in: directory)
        let urls = try disk.urls(at: url)
        try urls.forEach(disk.remove)
    }

    private func path(forKey key: StoreKey) -> String {
        return "\(folder)/\(key.identifier)"
    }
}
