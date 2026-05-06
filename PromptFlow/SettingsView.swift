//
//  SettingsView.swift
//  PromptFlow
//
//  Created by Yuta Tokoro on 2026/05/06.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        Form {
            Picker("Hotkey", selection: $settings.hotkey) {
                ForEach(HotkeyTrigger.allCases) { trigger in
                    Text(trigger.title)
                        .tag(trigger)
                }
            }

            Toggle("Vim key bindings", isOn: $settings.usesVimKeyBindings)
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 420)
    }
}
