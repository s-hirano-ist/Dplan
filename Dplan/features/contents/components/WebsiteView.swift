//
//  URLViewController.swift
//  Dplan
//
//  Created by S.Hirano on 2019/11/08.
//  Copyright © 2019 Sola Studio. All rights reserved.
//

import UIKit
import WebKit

enum WebsiteState {
    case others
    case candidate
    case error
    init() {
        self = .error
    }
}

class WebsiteView: UIViewController{
    private var _observers = [NSKeyValueObservation]()
    private var o = RealmOthers()
    private let c = RealmCandidate()

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var goBackButton: UIBarButtonItem!
    @IBOutlet weak var goForwardButton: UIBarButtonItem!

    private var refController:UIRefreshControl!

    var state = WebsiteState()
    var firstData = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        presetUrlView()
        addRefController()
        didLoad()
    }
    func didLoad(){
        if let url = URL(string: firstData){
            let request = URLRequest(url: url)
            webView.load(request)
        }
        didReloadFinish()
    }
    func didReloadFinish(){
        guard let url = webView.url else{
            ERROR("can not find url")
            return
        }

        if url == URL(string: "https://www.google.com".localized) ||
        url.absoluteString == "https://www.google.com".localized {
            DEBUG("gogole home so no delete or ...")
            bookmarkButton.title = String.empty
            return
        }
        if state == .others {
            if o.isIncluded(string: url) {
                DEBUG("ISINCLUDED")
                bookmarkButton.title = "Delete this page".localized
            }else{
                DEBUG("NOTINCLUDED")
                bookmarkButton.title = "Save this page".localized
            }
        }else if state == .candidate {
            if c.isIncluded(string: url) {
                DEBUG("ISINCLUDED")
                bookmarkButton.title = "Delete this page".localized
            }else{
                DEBUG("NOTINCLUDED")
                bookmarkButton.title = "Save this page".localized
            }
        }else{
            ERROR("!!!")
        }
    }
    @IBAction func bookmarkButtonClicked(_ sender: UIBarButtonItem) {
        if state == .others {
            if o.isIncluded(string: webView.url!) {
                DEBUG("DELETE URL")
                bookmarkButton.title = "Save this page".localized
                o.deleteWebsite(at: o.includedWebsiteIs(string: webView.url!))
            }else{
                DEBUG("ADD URL")
                bookmarkButton.title = "Delete this page".localized
                o.saveWebsite(URLData(title: webView.title!, website: webView.url!.absoluteString))
            }
        }else if state == .candidate {
            if c.isIncluded(string: webView.url!) {
                DEBUG("DELETE URL")
                bookmarkButton.title = "Save this page".localized
                c.deleteWebsite(at: c.includedWebsiteIs(string: webView.url!))
            }else{
                DEBUG("ADD URL")
                bookmarkButton.title = "Delete this page".localized
                c.saveWebsite(URLData(title: webView.title!, website: webView.url!.absoluteString))
            }
        }else{
            ERROR("ERROR")
        }
    }

    @objc func refreshActivated(refresh:UIRefreshControl){
        webView.reload()
        refController.endRefreshing()
    }

    @IBAction func goBackButtonPressed(_ sender: Any) {
        webView.goBack()
    }
    @IBAction func goForwardButtonPressed(_ sender: Any) {
        webView.goForward()
    }
    @IBAction func reloadButtonPressed(_ sender: Any) {
        webView.reload()
    }
    @IBAction func homeButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://www.google.com".localized){
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    @IBAction func shareButtonClicked(_ sender: UIBarButtonItem) {
        //open in safari or share
        Segues().webTypeShare(controller: self)
    }

    @IBAction func dismissButton(_ sender: Any) {
        Settings().reloadRightViewDismiss(controller: self)
        dismiss(animated: true, completion: nil)
    }
}
extension WebsiteView {

    private func presetUrlView(){
        _observers.append(webView.observe(\.canGoBack, options: .new){ _, change in
            if let value = change.newValue {
                DispatchQueue.main.async {
                    self.goBackButton.isEnabled = value
                    //self.goBack.alpha = value ? 1.0 : 0.4
                }
            }
        })
        _observers.append(webView.observe(\.canGoForward, options: .new){ _, change in
            if let value = change.newValue {
                DispatchQueue.main.async {
                    self.goForwardButton.isEnabled = value
                    //self.goForward.alpha = value ? 1.0 : 0.4
                }
            }
        })
        _observers.append(webView.observe(\.isLoading, options: .new) {_, change in
            if let value = change.newValue {
                DispatchQueue.main.async {
                    self.reloadButton.isEnabled = !value
                    self.bookmarkButton.isEnabled = !value

                    //IMPROVE 更新処理中は更新停止可能に!
                    /*if value {
                        self.reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
                    }else{
                        self.reloadButton.setImage(UIImage(systemName: "xmark"), for: .normal)
                    }*/
                    self.reloadButton.alpha = !value ? 1.0 : 0.4
                }
            }
        })

        _observers.append(webView.observe(\.title, options: .new) {_, change in
            if let value = change.newValue {
                DispatchQueue.main.async {
                    self.titleLabel.text = value
                }
            }
        })
    }
    func addRefController(){
        refController = UIRefreshControl()
        refController.bounds = CGRect(x: 0, y: 50, width: refController.bounds.size.width, height: refController.bounds.size.height)
        refController.addTarget(self, action: #selector(refreshActivated), for: UIControl.Event.valueChanged)
        refController.attributedTitle = NSAttributedString(string: "Pull to refresh".localized)
        webView.scrollView.addSubview(refController)
    }

    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        setUpProgressView()
    }
    func setUpProgressView() {
        self.progressView.progressViewStyle = .bar
        _observers.append(self.webView.observe(\.estimatedProgress, options: .new, changeHandler: { (webView, change) in
            self.progressView.alpha = 1.0
            // estimatedProgressが変更された時にプログレスバーの値を変更
            self.progressView.setProgress(Float(change.newValue!), animated: true)
            if self.webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3,
                               delay: 0.3,
                               options: [.curveEaseOut],
                               animations: { [weak self] in
                                self?.progressView.alpha = 0.0
                    }, completion: {_ in
                        self.progressView.setProgress(0.0, animated: false)
                })
            }
        })
        )
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //titleLabel.text = webView.title
        didReloadFinish()
        DispatchQueue.main.async {
            self.goBackButton.isEnabled = webView.canGoBack
            //self.goBack.alpha = webView.canGoBack ? 1.0 : 0.4
            self.goForwardButton.isEnabled = webView.canGoForward
            //self.goForward.alpha = webView.canGoForward ? 1.0 : 0.4
        }
    }
}
//MARK:認証対応
extension WebsiteView : WKNavigationDelegate,WKUIDelegate {

    /*func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        DEBUG("webView:didReceive challenge: completionHandler called.")
        // SSL/TLS接続ならここで処理する
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.rejectProtectionSpace, nil)
                return
            }
            var trustResult = SecTrustResultType.invalid
            guard SecTrustEvaluate(serverTrust, &trustResult) == noErr else {
                completionHandler(.rejectProtectionSpace, nil)
                return
            }
            switch trustResult {
            case .recoverableTrustFailure:
                ERROR("Trust failed recoverably")
                // Safariのような認証書のエラーが出た時にアラートを出してそれでも信頼して接続する場合は続けるをタップしてください -> タップされたら強制的に接続のような実装はここで行う。
                return
            case .fatalTrustFailure:
                completionHandler(.rejectProtectionSpace, nil)
                return
            case .invalid:
                completionHandler(.rejectProtectionSpace, nil)
                return
            case .proceed:
                break
            case .deny:
                completionHandler(.rejectProtectionSpace, nil)
                return
            case .unspecified:
                break
            default:
                break
            }

        } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic
            || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest
            || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodDefault
            || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNegotiate
            || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM {
            // Basic認証等の対応
            let alert = UIAlertController(
                title: "Authentication is needed".localized,
                message: "Input username and password".localized,
                preferredStyle: .alert
            )
            alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
                textField.placeholder = "user name".localized
                textField.tag = 1
            })
            alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
                textField.placeholder = "password".localized
                textField.isSecureTextEntry = true
                textField.tag = 2
            })

            let okAction = UIAlertAction(title: "Log in".localized, style: .default, handler: { _ in
                var user = String.empty
                var password = String.empty

                if let textFields = alert.textFields {
                    for textField in textFields {
                        if textField.tag == 1 {
                            user = textField.text ?? String.empty
                        } else if textField.tag == 2 {
                            password = textField.text ?? String.empty
                        }
                    }
                }

                let credential = URLCredential(user: user, password: password, persistence: URLCredential.Persistence.forSession)
                completionHandler(.useCredential, credential)
            })

            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { _ in
                completionHandler(.cancelAuthenticationChallenge, nil)
            })
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            return
        }
        completionHandler(.performDefaultHandling, nil)
    }*/

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //IMPROVE ???
        if let url =  navigationAction.request.url,
            //取得したURLが対象のリンクか確認を行う
            url == URL(string:"https://news.yahoo.co.jp/"){
            //アプリからsafariを起動
            UIApplication.shared.open(url)
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }

        if url.absoluteString.range(of: "//itunes.apple.com/") != nil {
            if UIApplication.shared.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: false], completionHandler: { (finished: Bool) in
                })
            } else {
                UIApplication.shared.open(url)
                return nil
            }
        } else if !url.absoluteString.hasPrefix("http://") && !url.absoluteString.hasPrefix("https://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return nil
            }
        }
        // target="_blank"のリンクを開く
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            webView.load(URLRequest(url: url))
            return nil
        }
        return nil
    }


    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // alert対応
        let alertController = UIAlertController(title: String.empty, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK".localized, style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        // confirm対応
        let alertController = UIAlertController(title: String.empty, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "OK".localized, style: .default) { _ in
            completionHandler(true)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        // prompt対応
        let alertController  = UIAlertController(title: String.empty, message: prompt, preferredStyle: .alert)
        let okHandler: () -> Void = {
            if let textField = alertController.textFields?.first {
                completionHandler(textField.text)
            } else {
                completionHandler(String.empty)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { _ in
            completionHandler(nil)
        }
        let okAction = UIAlertAction(title: "OK".localized, style: .default) { _ in
            okHandler()
        }
        alertController.addTextField { $0.text = defaultText }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
