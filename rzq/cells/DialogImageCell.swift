//
//  DialogImageCell.swift
//  rzq
//
//  Created by Zaid najjar on 4/2/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class DialogImageCell: UICollectionViewCell {
    @IBOutlet weak var ivAddedImage: UIImageView!
    var deleteImage : (() -> Void)? = nil
    @IBAction func deleteAction(_ sender: Any) {
        if let deleteImage = self.deleteImage {
            deleteImage()
        }
    }
}
