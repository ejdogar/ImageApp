//
//  UploadViewController.swift
//  ImageApp
//
//  Created by Ej Dogar on 23/01/2024.
//

import UIKit
import Foundation
import CryptoKit

class UploadViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var selectedPic = UIImage()
    var selectionCheck = 0
    
    @IBAction func selectImageBtn(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    @IBAction func uploadBtnPressed(_ sender: Any) {
        if (selectionCheck == 1){
            uploadImage(image: selectedPic)
            selectionCheck = 0
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)

        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            selectedPic = selectedImage
            selectionCheck = 1
        }
    }
    
    func uploadImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Unable to convert image to data.")
            return
        }

        let url = URL(string: "http://localhost:3000/upload")!
        var request = URLRequest(url: url)
         request.httpMethod = "POST"

         let boundary = "Boundary-\(UUID().uuidString)"
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

         var body = Data()

         body.append("--\(boundary)\r\n".data(using: .utf8)!)
         body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
         body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
         body.append(imageData)
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

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
    
    

