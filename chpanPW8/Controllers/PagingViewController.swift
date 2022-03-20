//
//  PagingViewController.swift
//  chpanPW8
//
//  Created by ZhengWu Pan on 19.03.2022.
//

import Foundation
import UIKit

// Point 6
class PagingViewController : UIViewController{
    
    private let tableView = UITableView()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let pickerView = UIPickerView()
    
    private var session: URLSessionDataTask!
    
    private var movies = [Movie]()
    
    private let paging = ["1", "2", "3", "4", "5", "6", "7", "8"]
    
    private let apiKey = "93e28afb2d742c286532168fd4b53439"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        configUI()
        navigationItem.titleView!.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: (navigationItem.titleView!.centerXAnchor)).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: (navigationItem.titleView!.centerYAnchor)).isActive = true
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies(page: 1)
        }
        tableView.rowHeight = CGFloat(MovieCell.imageHeight) + 40
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.backgroundColor = .white
        configUI()
    }
    
    private func configUI(){
        view.addSubview(tableView)
        navigationItem.titleView = pickerView
        let rotationAngle: CGFloat! = -90  * (.pi/180)
        pickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        tableView.delegate = self
        pickerView.frame = CGRect(x: -150, y: 100.0, width: view.bounds.width + 300, height: 200)
        pickerView.delegate = self
        pickerView.dataSource = self
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
    
    private func loadMovies(page: Int){
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        if (session != nil) {
            session!.cancel()
        }
        guard let url = URL(string:"https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=ru-RU&page=\(page)") else {return assertionFailure()}
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
                    self.activityIndicator.stopAnimating()
                }
            }
        })
        session.resume()
    }
    
}

extension PagingViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
}

extension PagingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies(page: row + 1)
        }
    }
    
}

extension PagingViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return paging.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let modeView = UIView()
        modeView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let modeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        modeLabel.textColor = .blue
        modeLabel.text = paging[row]
        modeLabel.textAlignment = .center
        modeView.addSubview(modeLabel)
        let rotationAngle: CGFloat! = 90  * (.pi/180)
        modeView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        return modeView
    }
    
    
}

extension PagingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: movies[indexPath.row].backdropPath!) {
            let vc = WebViewController()
            vc.url = url
            navigationController?.modalPresentationStyle = .fullScreen
            navigationController!.pushViewController(vc, animated: true)
        }
    }
}
