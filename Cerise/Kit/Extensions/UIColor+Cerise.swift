//
//  UIColor+Cerise.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import UIKit

extension Cerise where Base: UIColor {
    static var tint: UIColor {
        return UIColor(named: "TINT")!
    }

    static var dark: UIColor {
        return UIColor(named: "DARK")!
    }

    static var lightText: UIColor {
        return UIColor(named: "lightText")!
    }

    static var darkText: UIColor {
        return UIColor(named: "darkText")!
    }

    static var darkContent: UIColor {
        return UIColor(named: "DKCT")!
    }

    static var title: UIColor {
        return UIColor(named: "BK30")!
    }

    static var text: UIColor {
        return UIColor(named: "BK80")!
    }

    static var description: UIColor {
        return UIColor(named: "BK70")!
    }

    static var bold: UIColor {
        return UIColor(named: "BK90")!
    }

    static var code: UIColor {
        return UIColor(named: "BK90")!
    }

    static var codeBackground: UIColor {
        return UIColor(named: "BK95")!
    }

#if DEBUG
    static var allColors: [UIColor] {
        return [
            self.tint,
            self.dark,
            self.lightText,
            self.darkText,
            self.darkContent,
            self.title,
            self.text,
            self.description,
            self.bold,
            self.code,
            self.codeBackground,
        ]
    }
#endif
}

/*
 heng fa chuen #b51921
 tai koo #b2103e
 kowloon bay #c41832
 tseung kwan o #ef342a
 wui kai sha #a84d18
 po lam #f68f26
 sai wan ho #faca07
 disneyland resort #07594a
 skek kip mei #4ba946
 racecourse #5fc0a7
 tai wai #0376c2
 central #c41832
 */
