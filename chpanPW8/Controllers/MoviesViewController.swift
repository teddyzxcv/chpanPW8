//
//  ViewController.swift
//  chpanPW8
//
//  Created by ZhengWu Pan on 19.03.2022.
//

import UIKit

class MoviesViewController: UIViewController {
    
    private let tableView = UITableView()
    
    private var movies = [Movie]()
    
    private let apiKey = "93e28afb2d742c286532168fd4b53439"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configUI()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies()
        }
        tableView.rowHeight = 240
        
        // Do any additional setup after loading the view.
    }
    
    private func configUI(){
        view.addSubview(tableView)
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
    
    private func loadMovies(){
        guard let url = URL(string:"https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=ruRU") else {return assertionFailure()}
        let session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: {data, _, _ in
            guard
                let data = data,
                let dict = try? JSONSerialization.jsonObject (with: data, options: .json5Allowed) as? [String: Any],
                let results = dict["results"] as? [[String: Any]]
            else { return }
            let movies: [Movie] = results.map { params in
                let title = params["title"] as! String
                let imagePath = params["poster_path"] as? String
                return Movie(
                    title: title,
                    posterPath: imagePath
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

extension MoviesViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
}


