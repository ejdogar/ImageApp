//
//  DisplayViewController.swift
//  ImageApp
//
//  Created by Ej Dogar on 26/01/2024.
//

import UIKit
import CryptoKit

class DisplayViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!

    let serverURL = URL(string: "http://localhost:3000/images")!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func decryptImageBtnPressed(_ sender: Any) {
        guard let password = passwordTextField.text, !password.isEmpty else {
            print("Please enter the password.")
            return
        }
        fetchEncryptedImageFromServer(password: password)
    }

    func fetchEncryptedImageFromServer(password: String) {
        var request = URLRequest(url: serverURL)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                print("Received encrypted data from the server.")
                self?.decryptAndDisplayImage(encryptedData: data, password: password)
            }
        }

        task.resume()
    }

    func decryptAndDisplayImage(encryptedData: Data, password: String) {
        do {
            let decryptedData = Crypto.decrypt(input: encryptedData, key: password)

            if let decryptedImage = UIImage(data: decryptedData) {
                DispatchQueue.main.async {
                    self.imageView.image = decryptedImage
                }
            } else {
                print("Decryption failed: Unable to create an image from decrypted data.")
            }
        } catch {
            print("Decryption error: \(error)")
        }
    }
}
