//
//  String+Uppercased.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import CommonCrypto

extension String: CeriseCompatible {
}

public extension Cerise where Base == String {
    enum TrimmingType {
        case whitespace
        case whitespaceAndNewline
    }

    func trimming(_ trimmingType: TrimmingType) -> String {
        switch trimmingType {
        case .whitespace:
            return base.trimmingCharacters(in: CharacterSet.whitespaces)
        case .whitespaceAndNewline:
            return base.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }

    var md5: String? {
        guard let str = base.cString(using: String.Encoding.utf8) else {
            return nil
        }

        let strLen = CC_LONG(base.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        defer {
            result.deallocate()
        }

        let hash = NSMutableString()
        CC_MD5(str, strLen, result)

        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }

        return String(format: hash as String)
    }

    var words: [String] {
        let range = Range<String.Index>(uncheckedBounds: (lower: base.startIndex, upper: base.endIndex))
        var words = [String]()

        base.enumerateSubstrings(in: range, options: .byWords) { substring, _, _, _ in
            if let substring = substring {
                words.append(substring)
            }
        }

        return words
    }

    func uppercased(_ maxLength: Int) -> String {
        let index = self.base.index(self.base.startIndex, offsetBy: maxLength)
        return self.uppercased(upTo: index)
    }

    func uppercased(upTo index: String.Index) -> String {
        let prefix = self.base.prefix(upTo: index)
        let suffix = self.base.suffix(from: index)
        return prefix.uppercased() + suffix
    }
}
