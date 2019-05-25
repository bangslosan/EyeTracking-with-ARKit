//
//  CollectionViewCell.swift
//  arEyeTracking
//
//  Created by youngjun goo on 17/05/2019.
//  Copyright © 2019 장수한. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var gifImageView: UIImageView!
    var isAnimating: Bool = false
    
    
    func stopAnimation(_ gifImage: UIImage) {
        if isAnimating == true {
            return
        }
        self.gifImageView.image = gifImage.images?.first
        print("stopAnimation")
    }
    
    func startAnimation(_ gifImage: UIImage) {
        if isAnimating == false {
            print("exit animation")
            return
        }
        self.gifImageView.animationImages = gifImage.images
        // 반복주기 설정
        self.gifImageView.animationRepeatCount = 1
        //self.gifImageView.animationDuration = gifImage.duration
        self.gifImageView.startAnimating()
        self.isAnimating = false
    }
    
    func checkAnimating(_ gifImage: UIImage) {
        if self.isAnimating == false {
            self.stopAnimation(gifImage)
            isAnimating = true
        } else {
            self.startAnimation(gifImage)
            isAnimating = false
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
}
