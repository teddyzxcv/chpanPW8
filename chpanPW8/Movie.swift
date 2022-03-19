//
//  Movie.swift
//  chpanPW8
//
//  Created by ZhengWu Pan on 19.03.2022.
//

import Foundation
import UIKit

class Movie {
    let title: String
    let posterPath: String?
    var poster: UIImage? = nil
    var backdropPath: String?
    init(title: String, posterPath: String?, backdropPath: String?) {
        self.title = title
        self.posterPath = posterPath
        self.backdropPath = backdropPath
    }
    
    init(title: String, posterPath: String?) {
        self.title = title
        self.posterPath = posterPath
    }
    
    func loadPoster(completion: @escaping (UIImage?) -> Void){
        guard
            let posterPath = posterPath,
            let url = URL(string:"https://image.tmdb.org/t/p/original/\(posterPath)")
        else { return completion(nil) }
        let request = URLSession.shared.dataTask(with: URLRequest (url: url)) { [weak self] data, _, _ in
            guard
                let data = data,
                let image = UIImage (data: data) else {
                return completion(nil)
            }
            self?.poster = image
            completion(image)
            
        }
        request.resume()
    }
}

