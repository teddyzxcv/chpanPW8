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
    
    private var filterView: FilterView!
    
    private var isAdult = false
    
    private var yearsContents = ["All"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        filterView = FilterView(frame: (navigationController?.view.frame)!)
        configUI()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies(isAdult: self!.isAdult, year: "All")
        }
        tableView.rowHeight = CGFloat(MovieCell.imageHeight) + 40
        filterView.adultDelegate = self
        navigationItem.titleView = filterView
        for year in (1930...2022).reversed() {
            yearsContents.append(String(year))
        }
        
        // Do any additional setup after loading the view.
    }
    
    private func configUI(){
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        filterView.yearPicker.delegate = self
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
    
    private func loadMovies(isAdult: Bool, year: String){
        var urlString = "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=ru-RU&include_adult=\(isAdult)"
        if (year != "All"){
            urlString += "&primary_release_year=\(year)"
        }
        print(urlString)
        guard let url = URL(string:urlString) else {return assertionFailure()}
        let session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: {data, _, _ in
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
    
//    private func loadMovies(){
//        guard let url = URL(string:"https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=ru-RU") else {return assertionFailure()}
//        let session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: {data, _, _ in
//            guard
//                let data = data,
//                let dict = try? JSONSerialization.jsonObject (with: data, options: .json5Allowed) as? [String: Any],
//                let results = dict["results"] as? [[String: Any]]
//            else { return }
//            let movies: [Movie] = results.map { params in
//                let title = params["title"] as! String
//                let imagePath = params["poster_path"] as? String
//                let id = params["id"] as? Int
//                let backdropPath = self.loadHomePage(id: id!)
//                return Movie(
//                    title: title,
//                    posterPath: imagePath,
//                    backdropPath: backdropPath
//                )
//            }
//            self.loadImagesForMovies(movies) { movies in
//                self.movies = movies
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        })
//        session.resume()
//    }
    
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

extension MoviesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: movies[indexPath.row].backdropPath!) {
            let vc = WebViewController()
            vc.url = url
            navigationController?.modalPresentationStyle = .fullScreen
            navigationController!.pushViewController(vc, animated: true)
        }
    }
}

extension MoviesViewController: AdultDelegate {
    func setAdultFilter(isAdult: Bool) {
        print("YEs!!!")
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies(isAdult: isAdult, year: self!.yearsContents[self!.filterView.yearPicker.selectedRow(inComponent: 0)])
            self!.isAdult = isAdult
        }
    }
}

extension MoviesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies(isAdult: self!.isAdult, year: self!.yearsContents[row])
        }
    }
    
}

extension MoviesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearsContents.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let modeView = UIView()
        modeView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let modeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        modeLabel.textColor = .blue
        modeLabel.text = yearsContents[row]
        modeLabel.textAlignment = .center
        modeView.addSubview(modeLabel)
        return modeView
    }
    
    
}


