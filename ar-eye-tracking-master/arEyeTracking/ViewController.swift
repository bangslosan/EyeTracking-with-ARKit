//
//  ViewController.swift
//  arEyeTracking
//
//  Created by 장수한 on 10/05/2019.
//  Copyright © 2019 장수한. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let eyeTracker: EyeTrackingManager = EyeTrackingManager()
    private let cellIdentifier = "Cell"
    lazy var cellAttributes = [UICollectionViewLayoutAttributes]()
    
    private var checkPlayGif: Bool = false
    
    private var gifImageList = ["1","2","3","4","5","6","7","8","9","10","11","12"]
    
    var waitTime = 3
    var timer = Timer()
    var startTimer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.eyeTracker.delegate = self
        self.eyeTracker.showCursorView(parent: self.view)
        self.eyeTracker.showStatusView(parent: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.eyeTracker.run()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.eyeTracker.pause()
    }
}

extension ViewController: EyeTrackingDelegate {
    func didChange(lookAtPoint: CGPoint) {
        var cellIndex: Int = 0
        for i in 0..<self.cellAttributes.count {
            if self.cellAttributes[i].frame.contains(lookAtPoint) {
                self.selectCellAnimating(i, 1)
                cellIndex = i
            }
        }
        self.selectCellAnimating(cellIndex, 2)
    }
    
    func didChange(eyeTrackingState: EyeTrackingState) {
        // Do something
    }
    
}




extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath)
        
        if let checkCell = cell as? CollectionViewCell {
            guard let attribute = collectionView.layoutAttributesForItem(at: indexPath) else { return cell }
            cellAttributes.append(attribute)
            print(attribute)
            if let gifImage = UIImage.gif(asset: gifImageList[indexPath.item]) {
                checkCell.checkAnimating(gifImage)
            }
            return checkCell
        } else {
            return cell
        }
    }
    
    func selectCellAnimating(_ index: Int, _ menu: Int) {
        
        let cell = self.collectionView.cellForItem(at: self.cellAttributes[index].indexPath)
        
        if let checkCell = cell as? CollectionViewCell {
            checkCell.isAnimating = true
            guard let gifImage = UIImage.gif(asset: self.gifImageList[index]) else { return }
            
            switch menu {
            case 1:
                checkCell.startAnimation(gifImage)
            case 2:
                checkCell.stopAnimation(gifImage)
            default:
                break
            }
            
        }
        
    }
    
}
