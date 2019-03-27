// Markup
//
// Copyright (c) 2017 Guille Gonzalez
// See LICENSE file for license
//

import Foundation

public enum MarkupNode {
    case text(String)
    case bold([MarkupNode])
    case italic([MarkupNode])
    case underline([MarkupNode])
    case strike([MarkupNode])
    case code([MarkupNode])
}

extension MarkupNode {
    init?(delimiter: UnicodeScalar, children: [MarkupNode]) {
        switch delimiter {
        case "*":
            self = .bold(children)
        case "/":
            self = .italic(children)
        case "_":
            self = .underline(children)
        case "~":
            self = .strike(children)
        case "`":
            self = .code(children)
        default:
            return nil
        }
    }
}
