//
//  ImageCropPicker.swift
//  SwiftUIImageCropPicker
//
//  Created by Takenori Kabeya on 2023/02/06.
//

//  With the simulator, the first flower image causes the error.
//  This is a known issue.
//  see https://developer.apple.com/forums/thread/666338

import SwiftUI
import PhotosUI

class ImageCropViewHostingController: UIHostingController<ImageCropView> {
    var picker: UIViewController?
    var parentViewCoordinator: ImageCropPicker.Coordinator?
    
    required init?(coder: NSCoder) {
        self.parentViewCoordinator = nil
        super.init(coder: coder)
    }
    
    init(picker: UIViewController, parentViewCoordinator: ImageCropPicker.Coordinator, rootView: ImageCropView) {
        self.picker = picker
        self.parentViewCoordinator = parentViewCoordinator
        super.init(rootView: rootView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // when choose button is pressed
        if (rootView.croppedImage != nil) {
            picker?.dismiss(animated: true)
        }
    }
}

struct ImageCropPicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @State var pickedImage: UIImage? = nil
    @Binding var originalImage: UIImage?
    @Binding var croppedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        switch sourceType {
        case .photoLibrary:
            var config = PHPickerConfiguration()
            config.filter = .images
            config.selectionLimit = 1
            let viewController = PHPickerViewController(configuration: config)
            viewController.delegate = context.coordinator
            return viewController
        case .camera:
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = sourceType
            imagePicker.mediaTypes = [ UTType.image.identifier ]
            imagePicker.delegate = context.coordinator
            return imagePicker
        default:
            fatalError("Cannot pick from any other option")
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImageCropPicker
        var cropViewHostingController: ImageCropViewHostingController? = nil
        
        init(_ parent: ImageCropPicker) {
            self.parent = parent
        }
        
        // MARK: PHPickerViewControllerDelegate

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider else {
                picker.dismiss(animated: true)
                parent.croppedImage = nil
                return
            }
            if !provider.canLoadObject(ofClass: UIImage.self) {
                picker.dismiss(animated: true)
                parent.croppedImage = nil
                return
            }
            
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let image = image as? UIImage else {
                    self?.parent.croppedImage = nil
                    return
                }
                DispatchQueue.main.async {
                    self?.parent.pickedImage = image
                    self?.parent.croppedImage = nil
                    self?.showCropView(picker)
                }
            }
        }
        
        // MARK: UIImagePickerController
     
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                picker.dismiss(animated: true)
                parent.croppedImage = nil
                return
            }
            
            parent.pickedImage = image
            parent.croppedImage = nil
            showCropView(picker)
        }
        
        func showCropView(_ picker: UIViewController) {
            let viewControllerToPresent = ImageCropViewHostingController(picker: picker,
                                                                         parentViewCoordinator: self,
                                                                         rootView: ImageCropView(sourceImage: self.parent.$pickedImage,
                                                                                                 croppedImage: self.parent.$croppedImage,
                                                                                                 coordinator: self))
            self.cropViewHostingController = viewControllerToPresent
            if #available(iOS 15.0, *) {
                if let sheet = viewControllerToPresent.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                }
            }
            picker.present(viewControllerToPresent, animated: true, completion: nil)
        }
    }
}
