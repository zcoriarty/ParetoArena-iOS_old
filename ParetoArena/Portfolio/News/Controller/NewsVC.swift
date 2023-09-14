//
//  NewsVC.swift
//  Pareto
//
//  Created by Zachary Coriarty on 4/21/23.
//

import SwiftUI
import WebKit
import Combine



struct NewsArticle: Identifiable, Codable {
    let amp_url: String?
    let article_url: String
    let author: String?
    let description: String
    let id: String
    let image_url: String?
    let keywords: [String]?
    let published_utc: String
    let publisher: Publisher
    let tickers: [String]
    let title: String?

    struct Publisher: Codable {
        let favicon_url: String
        let homepage_url: String
        let logo_url: String
        let name: String
    }
}


class NewsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var newsArticles: [NewsArticle] = []

    func loadData(stocks: [String], completion: @escaping ([NewsArticle]) -> Void) {
        let tickers = stocks.joined(separator: ",")
        let url = EndPoint.kServerBase + EndPoint.news + "?tickers=\(tickers)"


        NetworkUtil.request(apiMethod: url, parameters: nil, requestType: .get, showProgress: true, onSuccess: { [weak self] resp in
            self?.isLoading = false

            do {
                let decoder = JSONDecoder()
                let jsonData = try JSONSerialization.data(withJSONObject: resp as Any, options: [])
                let decodedData = try decoder.decode([NewsArticle].self, from: jsonData)

                self?.newsArticles = decodedData
                completion(decodedData)

            } catch {
                print(error)
            }

        }) { [weak self] error in
            self?.isLoading = false
            print(error)
        }
    }
}

struct NewsCardView: View {
    let article: NewsArticle
    let cardWidth = UIScreen.main.bounds.width * 0.9

    var body: some View {
        NavigationLink(destination: WebView(request: URLRequest(url: URL(string: article.article_url)!))) {
            
            VStack {
                HStack {
                    RemoteImage(url: article.image_url ?? "")
                        .frame(width: 100, height: 100)
                        .scaledToFill()
                        .clipShape(Rectangle())
                        .cornerRadius(10)
                        .padding(2)

                    
                    VStack(alignment: .leading) {
                        HStack {
                            RemoteImage(url: article.publisher.favicon_url)
                                .frame(width: 20, height: 20)
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(6)
                            Text(article.publisher.name)
                                .font(.subheadline)
                                
                        }
                        Text(article.title ?? "")
                            .font(.system(size: 17, weight: .bold))
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)

                            
    //                    Text(article.description)
    //                        .font(.body)
    //                        .lineLimit(2)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(article.tickers.prefix(4), id: \.self) { keyword in
                                    Capsule()
                                        .foregroundColor(Color(.tertiarySystemBackground))
                                        .overlay(
                                            Text(keyword)
                                                .foregroundColor(.primary)
                                                .font(.caption)
                                        )
                                        .padding(.horizontal, 4)
                                        .frame(width: 70, height: 20)
                                }
                            }
                        }

                        
                    
                    


                    }
                    .padding([.top, .bottom, .trailing])
                    
                }
                
                
                Divider()
                HStack {
                    Text(article.author ?? "")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.gray.opacity(0.45))
                    
                    Spacer()
                    
                    Text(timeAgo(from: article.published_utc) ?? "")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.gray.opacity(0.45))
                    
                }
                .padding(.bottom)

            }
            .foregroundColor(Color(.label))
            .frame(minHeight: 120, maxHeight: 150)
            .padding()
            .background(Color(.systemGray5).opacity(0.5))
            .cornerRadius(10)
        }
        
    }
    
    func timeAgo(from utcTimestamp: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = dateFormatter.date(from: utcTimestamp) else {
            return nil
        }

        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .day], from: date, to: now)

        if let days = components.day, days > 0 {
            return days == 1 ? "\(days) day ago" : "\(days) days ago"
        } else if let hours = components.hour {
            return hours == 1 ? "\(hours) hour ago" : "\(hours) hours ago"
        } else {
            return nil
        }
    }
}

struct NewsListView: View {
    @StateObject private var viewModel = NewsViewModel()
    let stocks: [String]

    var body: some View {
        
            LazyVStack {
                HStack {
                    Text("News")
                        .font(.title)
                        .bold()
                        .padding(.leading, 15)
                    Spacer()
                }
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ForEach(viewModel.newsArticles) { article in
                        NewsCardView(article: article)
                            .padding(.horizontal, 30)
                    }
                }
            }
            .onAppear {
                viewModel.loadData(stocks: stocks) { _ in }
            }

    }
}


struct RemoteImage: View {
    @StateObject private var loader = ImageLoader()
    private let url: String

    init(url: String) {
        self.url = url
    }

    var body: some View {
        bodyView()
    }

    private func bodyView() -> some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loader.load(from: url)
        }
    }
}




struct WebView: UIViewRepresentable {
    let request: URLRequest

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(request)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Handle navigation events if needed
        }
    }
}


class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var cancellable: AnyCancellable?
    
    func load(from url: String) {
        guard let imageURL = URL(string: url) else { return }
        
        if let cachedImage = Self.cache.object(forKey: url as NSString) {
            self.image = cachedImage
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: imageURL)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                if let image = image {
                    Self.cache.setObject(image, forKey: url as NSString)
                }
                self?.image = image
            }
    }
    
    private static let cache = NSCache<NSString, UIImage>()
}



