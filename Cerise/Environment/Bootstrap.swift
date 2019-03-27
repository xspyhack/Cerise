//
//  Bootstrap.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/27.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import Keldeo

struct Bootstrap {
    private let charmander = Charmander()
    private let startedKey = "com.cerise.started"

    func start() {
        guard !UserDefaults.standard.bool(forKey: startedKey) else {
            return
        }
        UserDefaults.standard.set(true, forKey: startedKey)

        welcome()
        guiding()
    }

    private func welcome() {
        let matter = Matter(id: UUID().uuidString,
                            title: "🍒 Welcome to Cerise",
                            occurrenceDate: Date(),
                            notes: "Cerise is a simple countdown app.")
        do {
            try charmander.store(matter, forKey: matter.identifier)
        } catch {
            Log.e("Store wlecome matter failed: \(error)")
        }
    }

    private func guiding() {
        let notes = """
                    👐 Welcome! It’s easy to get started and master Cerise, so let’s show you around.

                    Cerise has three parts:

                    *📚 _Matters List_*: All your matters live here, there are /UPCOMING/ and /PAST/ sections.
                    *📖 _Matter Details_*: The matter's details contains /Title/, /Tag/, /When/ and /Notes/.
                    *📝 _Editor_*: This is where you can add your matters.

                    *🖋 Add a new matter*: You can `pull down` in home page (_Matters List_) to add a new matter.

                    *👀 View matter details*: You can `tap` a matter in _Matters List_ to view the matter details, or use `3D Touch` to preview. And then you can use `3D Touch` to pop back to _Matters List_ page.

                    *❌ Delete a matter*: You can use `swipe left` gesture to ~delete~ a matter in the _Matters List_.

                    Enjoy yourself. 🍻
                    """

        let matter = Matter(id: UUID().uuidString,
                            title: "🚀 Getting Started",
                            occurrenceDate: Date(timeIntervalSinceNow: 233_333),
                            notes: notes)

        do {
            try charmander.store(matter, forKey: matter.identifier)
        } catch {
            Log.e("Store getting started matter failed: \(error)")
        }
    }
}
