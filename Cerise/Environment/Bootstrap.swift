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
                    📚 Matters List: All your matters live here, there are UPCOMING and PAST sections.
                    📖 Matter Details: The matter's details contains 'Title', 'Tag', 'When' and 'Notes'.
                    📝 Editor: This is where you can add your matters.

                    🖋 Add a new matter: You can pull down in home page (Matters List) to add a new matter.

                    👀 View matter details: You can tap a matter in Matters List to view the matter details, or use 3D Touch to preview. And then you can use 3D Touch to pop back to Matters List page.

                    ❌ Delete a matter: You can use swipe left gesture to delete a matter in the Matters List.

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
