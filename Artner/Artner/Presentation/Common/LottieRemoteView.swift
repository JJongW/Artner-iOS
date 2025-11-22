import UIKit
import WebKit

/// dotlottie-wc 웹 컴포넌트를 사용한 Lottie 애니메이션 뷰
/// - .lottie 파일을 웹뷰를 통해 재생 (dotlottie-wc 사용)
final class LottieRemoteView: UIView {
    
    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.scrollView.isScrollEnabled = false
        wv.scrollView.bounces = false
        wv.scrollView.backgroundColor = .clear
        wv.translatesAutoresizingMaskIntoConstraints = false
        return wv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// dotlottie-wc를 사용하여 .lottie 파일을 로드합니다.
    /// - Parameter urlString: .lottie 파일 URL
    func load(urlString: String) {
        let sanitized = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
        // dotlottie-wc 웹 컴포넌트를 사용하는 HTML
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
          <style>
            html, body { 
              margin: 0; 
              padding: 0; 
              background: transparent; 
              overflow: hidden; 
              width: 100%;
              height: 100%;
              display: flex;
              align-items: center;
              justify-content: center;
            }
          </style>
          <script src="https://unpkg.com/@lottiefiles/dotlottie-wc@0.8.5/dist/dotlottie-wc.js" type="module"></script>
        </head>
        <body>
          <dotlottie-wc 
            src="\(sanitized)" 
            style="width: 100%; height: 100%;" 
            autoplay 
            loop>
          </dotlottie-wc>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}


