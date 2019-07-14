//
//  MatterDetailView.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/7/14.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import SwiftUI

struct MatterDetailView : View {
    var body: some View {
        VStack() {
            VStack() {
                Text("Title")
                Spacer()
                Text("2019-9-9")
                    .padding(20)
            }
            .frame(height: 300)

            Text("Notes")
            Spacer()
        }
    }
}

#if DEBUG
struct MatterDetailView_Previews : PreviewProvider {
    static var previews: some View {
        MatterDetailView()
    }
}
#endif
