
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {

    @Binding var isShown: Bool
    @Binding var uiImage: UIImage?
    var onDismiss: () -> ()
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        @Binding var isShown: Bool
        @Binding var uiImage: UIImage?
        var onDismissPicker: () -> ()
      init(isShown: Binding<Bool>, uiImage: Binding<UIImage?>, onDismiss: @escaping () -> ()) {
            _isShown = isShown
            _uiImage = uiImage
            onDismissPicker = onDismiss
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            uiImage = imagePicked
            isShown = false
            onDismissPicker()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isShown = false
            onDismissPicker()
        }

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShown: $isShown, uiImage: $uiImage, onDismiss: onDismiss)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

}
