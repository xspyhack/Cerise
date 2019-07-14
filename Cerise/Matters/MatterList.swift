//
//  MatterList.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/7/12.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import SwiftUI

struct MatterList: View {
    let matters = Matter.mock()
    var body: some View {
        NavigationView() {
            List {
                Text("UPCOMING")
                    .font(.title)
                ForEach(matters) { matter in
                    NavigationButton(destination: MatterDetail(matter: matter)) {
                        MatterItem(matter: matter)
                    }
                }
            }
            .navigationBarTitle(Text("Cerise"))
        }
    }
}

#if DEBUG
// swiftlint:disable all
struct MatterListView_Previews : PreviewProvider {
    static var previews: some View {
        MatterList()
    }
}
// swiftlint:enable all
#endif
