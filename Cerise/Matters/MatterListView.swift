//
//  MatterListView.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/7/12.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import SwiftUI

struct MatterListView: View {
    let items = Matter.mock()
    var body: some View {
        List {
            Text("UPCOMING")
                .font(.title)
            ForEach(items) { item in
                HStack {
                    Text(item.title)
                    Spacer()
                    Text("\(Date().cerise.absoluteDays(with: item.occurrenceDate))")
                }
            }
            Spacer()
            Text("PAST")
            ForEach(items) { item in
                HStack {
                    Text(item.title)
                    Spacer()
                    Text("\(Date().cerise.absoluteDays(with: item.occurrenceDate))")
                }
            }
        }
        .navigationBarTitle(Text("Cerise"))
    }
}

#if DEBUG
// swiftlint:disable all
struct MatterListView_Previews : PreviewProvider {
    static var previews: some View {
        MatterListView()
    }
}
// swiftlint:enable all
#endif
