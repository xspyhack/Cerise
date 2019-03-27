// Markup
//
// Copyright (c) 2017 Guille Gonzalez
// See LICENSE file for license
//

import UIKit

public final class Renderer {
    public func render(text: String) -> NSAttributedString {
        let elements = MarkupParser.parse(text: text)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.cerise.text,
        ]

        return elements.map { $0.render(withAttributes: attributes) }.joined()
    }
}

private extension MarkupNode {
    func render(withAttributes attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        guard let currentFont = attributes[.font] as? UIFont else {
            fatalError("Missing font attribute in \(attributes)")
        }

        switch self {
        case .text(let text):
			return NSAttributedString(string: text, attributes: attributes)
        case .bold(let children):
			var newAttributes = attributes
			newAttributes[.font] = currentFont.boldFont()
            newAttributes[.foregroundColor] = UIColor.white
			return children.map { $0.render(withAttributes: newAttributes) }.joined()
        case .italic(let children):
            var newAttributes = attributes
            newAttributes[.font] = currentFont.italicFont()
            return children.map { $0.render(withAttributes: newAttributes) }.joined()
        case .underline(let children):
			var newAttributes = attributes
			newAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
			return children.map { $0.render(withAttributes: newAttributes) }.joined()
        case .strike(let children):
			var newAttributes = attributes
			newAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
			newAttributes[.baselineOffset] = 0
			return children.map { $0.render(withAttributes: newAttributes) }.joined()
        case .code(let children):
            var newAttributes = attributes
            newAttributes[.foregroundColor] = UIColor.cerise.code
            newAttributes[.font] = UIFont.systemFont(ofSize: 16, weight: .medium)
            return children.map { $0.render(withAttributes: newAttributes) }.joined()
        }
    }
}

extension Array where Element: NSAttributedString {
    func joined() -> NSAttributedString {
        let result = NSMutableAttributedString()
        for element in self {
            result.append(element)
        }
        return result
	}
}

extension UIFont {
    func boldFont() -> UIFont? {
        return addingSymbolicTraits(.traitBold)
    }

    func italicFont() -> UIFont? {
        return addingSymbolicTraits(.traitItalic)
    }

    func addingSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        let newTraits = fontDescriptor.symbolicTraits.union(traits)
        guard let descriptor = fontDescriptor.withSymbolicTraits(newTraits) else {
            return nil
        }

        return UIFont(descriptor: descriptor, size: 0)
    }
}
