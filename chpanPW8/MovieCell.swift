//
//  MovieCell.swift
//  chpanPW8
//
//  Created by ZhengWu Pan on 19.03.2022.
//

import Foundation
import UIKit

class MovieCell: UITableViewCell {
    static let identifier = "MovieCell"
    private let poster = UIImageView()
    private let title = UILabel()
    init() {
        super.init(style: .default, reuseIdentifier: Self.identifier)
        configureUI()
    }
    
    required init? (coder: NSCoder) {
        fatalError("init (coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Self.identifier)
        configureUI()
    }
    
    private func configureUI(){
        poster.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(poster)
        addSubview(title)
        
        NSLayoutConstraint.activate([
            poster.topAnchor.constraint(equalTo: topAnchor),
            poster.leadingAnchor.constraint(equalTo: leadingAnchor),
            poster.trailingAnchor.constraint(equalTo: trailingAnchor),
            poster.heightAnchor.constraint(equalToConstant:200),
            title.topAnchor.constraint(equalTo: poster.bottomAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor),
            title.heightAnchor.constraint(equalToConstant:20)
        ])
        title.textAlignment = .center
    }
    
    func configure(movie: Movie){
        title.text = movie.title
        poster.image = movie.poster
    }
}
