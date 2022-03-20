//
//  SearchViewController.swift
//  chpanPW8
//
//  Created by ZhengWu Pan on 19.03.2022.
//

import Foundation

import UIKit

class SearchViewController: UIViewController {
        
    private let tableView = UITableView()
    
    private var movies = [Movie]()
    
    private var session: URLSessionDataTask!
    
    private let apiKey = "93e28afb2d742c286532168fd4b53439"
    
    private let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configUI()
        tableView.rowHeight = CGFloat(CGFloat(MovieCell.imageHeight) + 40)
        
        // Do any additional setup after loading the view.
    }
    
    private func configUI(){
        view.addSubview(tableView)
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo:view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo:view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo:view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo:view.bottomAnchor)
        ])
        tableView.reloadData()
    }
    
    private func loadImagesForMovies(_ movies: [Movie], completion: @escaping ([Movie]) -> Void) {
        let group = DispatchGroup()
        for movie in movies {
            group.enter()
            DispatchQueue.global(qos: .background).async {
                movie.loadPoster { _ in
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completion(movies)
        }
        
    }
    
    private func loadHomePage(id: Int) -> String {
        return "https://www.themoviedb.org/movie/\(id)"
    }
    
    private func loadMovies(movieName: String){
        if(session != nil){
            session!.cancel()
        }
        guard let url = URL(string:"https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=ru-RU&query=\(movieName)&page=1".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        else {return assertionFailure()}
        session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: {data, _, _ in
            guard
                let data = data,
                let dict = try? JSONSerialization.jsonObject (with: data, options: .json5Allowed) as? [String: Any],
                let results = dict["results"] as? [[String: Any]]
            else { return }
            let movies: [Movie] = results.map { params in
                let title = params["title"] as! String
                let imagePath = params["poster_path"] as? String
                let id = params["id"] as? Int
                let backdropPath = self.loadHomePage(id: id!)
                return Movie(
                    title: title,
                    posterPath: imagePath,
                    backdropPath: backdropPath
                )
            }
            self.loadImagesForMovies(movies) { movies in
                self.movies = movies
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        session.resume()
    }
    
}

extension SearchViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
}

extension SearchViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies(movieName: searchText)
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: movies[indexPath.row].backdropPath!) {
            let vc = WebViewController()
            vc.url = url
            navigationController?.modalPresentationStyle = .fullScreen
            navigationController!.pushViewController(vc, animated: true)
        }
    }
}



