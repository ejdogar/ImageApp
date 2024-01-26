//
//  UploadViewController.swift
//  ImageApp
//
//  Created by Ej Dogar on 23/01/2024.
//

import UIKit
import CryptoKit

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTitleTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    let imagePicker = UIImagePickerController()
    let serverURL = URL(string: "http://localhost:3000/upload")!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    @IBAction func selectImageBtn(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func uploadBtnPressed(_ sender: Any) {
        guard let image = imageView.image,
              let password = passwordTextField.text, !password.isEmpty,
              let title = imageTitleTextField.text, !title.isEmpty else {
            print("Please provide both an image, a password, and a title.")
            return
        }

        if let imageData = image.jpegData(compressionQuality: 1.0) {
            let encryptedData = Crypto.encrypt(input: imageData, key: password)
            sendEncryptedDataToServer(encryptedData: encryptedData, imageName: title)
        } else {
            print("Error converting image to data.")
        }
    }

    func encryptImage(imageData: Data, password: String, title: String) -> Data? {
            let encryptedData = Crypto.encrypt(input: imageData, key: password)
            return encryptedData
    }

    func sendEncryptedDataToServer(encryptedData: Data, imageName: String) {
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        
        request.addValue(imageName, forHTTPHeaderField: "image-title")
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(encryptedData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Response: \(responseString ?? "")")
            }
        }
        
        task.resume()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)

        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
