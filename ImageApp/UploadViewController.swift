//
//  UploadViewController.swift
//  ImageApp
//
//  Created by Ej Dogar on 23/01/2024.
//

import UIKit
import Foundation

class UploadViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var image: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func selectImageBtn(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func uploadBtnPressed(_ sender: Any) {
        let imageURL = URL(string: "http://localhost:3000/imageUpload")!
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("Error faced while converting JSON to data")
            return
        }
        
        var request = URLRequest(url: imageURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let ses = URLSession.shared
        
        request.httpMethod="POST"
        
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        request.setValue("File Name", forHTTPHeaderField: "X-FileName")
        
        let jpgData = (image.image!).jpegData(compressionQuality: 1.0)
        
        
        request.httpBodyStream = InputStream(data: jpgData!)
        let task = ses.uploadTask(withStreamedRequest: request as URLRequest) // files[0]
        task.resume()

   
        }
    
        let image = UIImage(named: "your_image_name")!
        uploadImage(image: image.image!) { result in
            switch result {
            case .success(let fileNames):
                print("Image uploaded successfully. File names: \(fileNames)")
            case .failure(let error):
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self

    }
    
    
    // MARK: - UIImagePickerControllerDelegate Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image.contentMode = .scaleAspectFit
            image.image = pickedImage
        }

        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
