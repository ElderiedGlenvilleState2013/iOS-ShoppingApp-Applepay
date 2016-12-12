//
//  CustomTableViewCell.swift
//  ShoppingApp
//
//  Created by Thiago dos Reis on 12/9/16.
//  Copyright © 2016 Thiago dos Reis. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var cellPrice: UILabel!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithProduct(_ productDict: AnyObject) {
        // Setup the cell with information provided in productDict.
        cellTitle?.text = productDict.value(forKey: "title") as? String
        
        cellPrice?.text = productDict.value(forKeyPath: "price.data.formatted.with_tax") as? String
        
        //set the image for the product
        var imageUrl = ""
        
        if let images = productDict.object(forKey: "images") as? NSArray {
            if (images.firstObject != nil) {
                imageUrl = (images.firstObject as! NSDictionary).value(forKeyPath: "url.https") as! String
            }

            
            if let url = URL(string: imageUrl) {
                if let data = NSData(contentsOf: url) {
                    cellImage?.image = UIImage(data: data as Data)
                }
            }
        }
    }


}
