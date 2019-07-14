//
//  MatterItem.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/7/14.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import SwiftUI

struct MatterItem : View {
    let matter: Matter
    var body: some View {
        HStack {
            Text(matter.title)
            Spacer()
            Text("\(Date().cerise.absoluteDays(with: matter.occurrenceDate))")
        }
    }
}

#if DEBUG
struct MatterItem_Previews : PreviewProvider {
    static var previews: some View {
        MatterItem(matter: Matter.mock()[0])
    }
}
#endif
