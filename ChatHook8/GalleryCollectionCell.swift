//
//  GalleryCollectionCell.swift
//  ChatHook
//
//  Created by Kevin Farm on 9/13/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit

class GalleryCollectionCell: UICollectionViewCell {
    
    //var profileViewController:ProfileViewController?

    var galleryImageView: UIImageView!
    
    let uncheckedImageView: UIImageView = {
        let imageView = UIImageView()
            imageView.image = UIImage(named: "Unchecked")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.isHidden = true
            imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var gallery: GalleryImage? {
        didSet {
            if let gallery = gallery {
                galleryImageView.loadImageUsingCacheWithUrlString(urlString: gallery.galleryImageUrl!)
            }
        }
    }
    
    var editing: Bool = false{
        didSet{
            uncheckedImageView.isHidden = !editing
            gradientView.isHidden = !editing
        }
    }
    
    override var isSelected: Bool{
        didSet{
            if editing{
                uncheckedImageView.image = UIImage(named: isSelected ? "Checked" : "Unchecked")
            }
        }
    }
    
    let gradientView: GradientView = {
        let gView = GradientView()
            gView.translatesAutoresizingMaskIntoConstraints = false
        return gView  
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 5.0
        contentView.clipsToBounds = true
        contentView.layer.shadowOpacity = 0.8
        contentView.layer.shadowRadius = 5.0
        contentView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        contentView.layer.shadowColor = UIColor.black.cgColor
        
        //galleryImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 120))
        galleryImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        galleryImageView.contentMode = .scaleAspectFill

        contentView.addSubview(galleryImageView)
        galleryImageView.addSubview(gradientView)
        galleryImageView.addSubview(uncheckedImageView)
        
        setupEditImages()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupEditImages(){
        uncheckedImageView.centerXAnchor.constraint(equalTo: galleryImageView.centerXAnchor).isActive = true
        uncheckedImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
        uncheckedImageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        uncheckedImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        gradientView.centerXAnchor.constraint(equalTo: galleryImageView.centerXAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: galleryImageView.bottomAnchor).isActive = true
        gradientView.widthAnchor.constraint(equalTo: galleryImageView.widthAnchor).isActive = true
        gradientView.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    


}
