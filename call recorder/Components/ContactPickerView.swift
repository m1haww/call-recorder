import SwiftUI
import ContactsUI

/// Presents the system contact picker; selected contact's first phone number is written to `selectedNumber`.
/// Add "Privacy - Contacts Usage Description" (NSContactsUsageDescription) to the app's Info if not already set.
struct ContactPickerView: UIViewControllerRepresentable {
    @Binding var selectedNumber: String
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerView

        init(_ parent: ContactPickerView) {
            self.parent = parent
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let number = contact.phoneNumbers.first?.value.stringValue ?? ""
            let digits = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            DispatchQueue.main.async {
                self.parent.selectedNumber = digits
                self.parent.dismiss()
            }
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            DispatchQueue.main.async {
                self.parent.dismiss()
            }
        }
    }
}
