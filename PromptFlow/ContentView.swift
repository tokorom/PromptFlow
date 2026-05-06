//
//  ContentView.swift
//  PromptFlow
//
//  Created by Yuta Tokoro on 2026/05/06.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: PromptFlowModel
    @EnvironmentObject private var settings: AppSettings

    @State private var selectedItem: PromptListItem? = .current

    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView {
                List(PromptListItem.allCases, selection: $selectedItem) { item in
                    Label(item.title, systemImage: item.systemImage)
                        .tag(item)
                }
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
            } detail: {
                editorPane
            }

            Divider()

            bottomToolbar
        }
        .frame(minWidth: 760, minHeight: 480)
    }

    private var editorPane: some View {
        VStack(spacing: 0) {
            HStack {
                Text(selectedItem?.title ?? PromptListItem.current.title)
                    .font(.headline)
                Spacer()
                if settings.usesVimKeyBindings {
                    Label("Vim", systemImage: "keyboard")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.bar)

            WebPromptEditor(
                text: $model.promptText,
                isSelectionEmpty: $model.isEditorSelectionEmpty,
                usesVimKeyBindings: settings.usesVimKeyBindings,
                focusRequestID: model.focusRequestID,
                onSubmit: model.submitPrompt,
                onCopyAll: model.copyPrompt
            )
        }
    }

    private var bottomToolbar: some View {
        HStack(spacing: 10) {
            Button {
                model.submitPrompt()
            } label: {
                Label("Submit", systemImage: "paperplane")
            }
            .keyboardShortcut("s", modifiers: .command)
            .disabled(!model.canSubmit)
            .help(model.canSubmit ? "Return to the previous app and paste" : "No previous app is known yet")

            Button {
                model.copyPrompt()
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            .keyboardShortcut("c", modifiers: .command)
            .disabled(!model.isEditorSelectionEmpty)
            .help(model.isEditorSelectionEmpty ? "Copy the full prompt" : "Use the editor selection copy")

            Spacer()

            if !model.targetHistory.isEmpty {
                Menu {
                    ForEach(model.targetHistory, id: \.bundleIdentifier) { app in
                        Button {
                            model.setTarget(app)
                        } label: {
                            Text(app.localizedName ?? "Unknown App")
                        }
                    }
                } label: {
                    Text(model.statusText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            } else {
                Text(model.statusText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.bordered)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.bar)
    }
}

private enum PromptListItem: String, CaseIterable, Identifiable {
    case current

    var id: String { rawValue }

    var title: String {
        switch self {
        case .current:
            "Current Prompt"
        }
    }

    var systemImage: String {
        switch self {
        case .current:
            "text.alignleft"
        }
    }
}
