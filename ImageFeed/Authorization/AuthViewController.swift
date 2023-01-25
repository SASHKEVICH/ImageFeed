//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 25.01.2023.
//

import UIKit

final class AuthViewController: UIViewController {

    @IBOutlet private weak var loginButton: UIButton!
    
    private let showWebViewSegueId = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoginButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueId {
            let vc = segue.destination as! WebViewViewController
            vc.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func setupLoginButton() {
        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
    }

}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}
