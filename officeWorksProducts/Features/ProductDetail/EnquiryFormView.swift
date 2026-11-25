import SwiftUI

struct EnquiryFormView: View {
    let productName: String

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var isSubmitted = false
    @FocusState private var focused: Field?

    private enum Field { case name, email }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && email.contains("@") && email.contains(".")
            && !email.contains(" ")
    }

    var body: some View {
        NavigationStack {
            Group {
                if isSubmitted {
                    ContentUnavailableView(
                        "Thank you",
                        systemImage: "checkmark.circle.fill",
                        description: Text("Thank you and we will reach out to you shortly.")
                    )
                    .foregroundStyle(.green, .secondary)
                } else {
                    form
                }
            }
            .navigationTitle("Enquire")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isSubmitted ? "Done" : "Cancel") { dismiss() }
                }
            }
        }
    }

    private var form: some View {
        Form {
            Section("Your details") {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .focused($focused, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focused = .email }
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .email)
            }
            Section("Product") {
                Text(productName)
                    .foregroundStyle(.secondary)
            }
            Section {
                Button {
                    focused = nil
                    isSubmitted = true
                } label: {
                    Text("Submit").frame(maxWidth: .infinity)
                }
                .disabled(!isValid)
            }
        }
    }
}
