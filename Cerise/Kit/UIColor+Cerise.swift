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
        return UIColor(named: "TINT") ?? UIColor(red: 0.871, green: 0.192, blue: 0.388, alpha: 1.00)
    }

    static var dark: UIColor {
        return UIColor(named: "DARK") ?? UIColor(red: 0.12, green: 0.13, blue: 0.13, alpha: 1.00)
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
