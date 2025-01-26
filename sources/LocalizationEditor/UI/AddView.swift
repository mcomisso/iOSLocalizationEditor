//
//  AddView.swift
//  LocalizationEditor
//
//  Created by Matteo Comisso on 26/1/25.
//  Copyright © 2025 Igor Kulman. All rights reserved.
//

import SwiftUI

struct AddView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismiss) private var dismiss
    @State private var key: String = ""
    @State private var message: String = ""

    var onAddTranslation: ((String, String?) -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            // Key Text Field
            TextField("Key", text: $key)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Message Text Field
            TextField("Message (optional)", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Buttons
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Add") {
                    onAddTranslation?(key, message.isEmpty ? nil : message)
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(key.isEmpty)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Preview

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView { key, message in
            print("Added translation: Key=\(key), Message=\(String(describing: message))")
        }
    }
}
