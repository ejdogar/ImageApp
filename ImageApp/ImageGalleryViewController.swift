//
//  ImageGalleryViewController.swift
//  ImageApp
//
//  Created by Ej Dogar on 25/01/2024.
//

import UIKit

class ImageGalleryViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchAndDisplayImages()
        
        scrollView.isUserInteractionEnabled = true
        
        for case let imageView as UIImageView in scrollView.subviews {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                    imageView.isUserInteractionEnabled = true
                    imageView.addGestureRecognizer(tapGesture)
            
        }
    }
    
    func fetchAndDisplayImages() {
        guard let url = URL(string: "http://localhost:3000/images") else {
                print("Invalid URL")
                return
            }
        
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error fetching images: \(error)")
                    return
                }

                if let data = data {
                    // Parse the base64-encoded images
                    if let base64Images = try? JSONDecoder().decode([String].self, from: data) {
                        // Display images on the main thread
                        DispatchQueue.main.async {
                            self.displayImages(base64Images)
                        }
                    }
                }
            }

            task.resume()
        }

        func displayImages(_ base64Images: [String]) {
            for (index, base64Image) in base64Images.enumerated() {
                if let imageData = Data(base64Encoded: base64Image), let image = UIImage(data: imageData) {
                    // Create UIImageView for each image
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFit

                    // Calculate position and size for the UIImageView
                    let xPosition = CGFloat(index) * scrollView.frame.width
                    imageView.frame = CGRect(x: xPosition, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)

                    // Add UIImageView to the UIScrollView
                    scrollView.addSubview(imageView)
                }
            }

            // Set content size of UIScrollView based on the number of images
            scrollView.contentSize = CGSize(width: CGFloat(base64Images.count) * scrollView.frame.width, height: scrollView.frame.height)
        }
    
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        print("image tapped")
        guard let tappedImageView = sender.view as? UIImageView, let tappedImage = tappedImageView.image else {
            return
        }

        // Create a new view to display the tapped image
        let largeImageView = UIImageView(image: tappedImage)
        largeImageView.contentMode = .scaleAspectFit

        // Set up a tap gesture recognizer to dismiss the view when tapped
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTappedImageView(_:)))
        tappedImageView.isUserInteractionEnabled = true
        tappedImageView.addGestureRecognizer(dismissTapGesture)

        // Add the tapped image view to the main view
        let containerView = UIView(frame: view.bounds)
        containerView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        containerView.addSubview(tappedImageView)
        view.addSubview(containerView)
    }

    @objc func dismissTappedImageView(_ sender: UITapGestureRecognizer) {
        // Remove the tapped image view when tapped
        sender.view?.superview?.removeFromSuperview()
    }
}
    


