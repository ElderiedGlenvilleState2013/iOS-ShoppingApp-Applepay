//
//  CartTableViewCell.swift
//  ShoppingApp
//
//  Created by Thiago dos Reis on 12/11/16.
//  Copyright © 2016 Thiago dos Reis. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var cartCellTitle: UILabel!
    @IBOutlet weak var cartCellPrice: UILabel!
    @IBOutlet weak var cartCellQty: UILabel!
    @IBOutlet weak var cartCellImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setItemDictionary(_ itemDict: NSDictionary) {
        
        cartCellTitle?.text = itemDict.value(forKey: "title") as? String
        
        cartCellPrice?.text = itemDict.value(forKeyPath: "totals.post_discount.formatted.with_tax") as? String
        
        if let qty:NSNumber = itemDict.value(forKeyPath: "quantity") as? NSNumber {
            _ = "Qty. \(qty.intValue)"
            cartCellQty?.text = String(qty.doubleValue)
        }
        
        
        var imageUrl = ""
        
        if let images = itemDict.object(forKey: "images") as? NSArray {
            if (images.firstObject != nil) {
                imageUrl = (images.firstObject as! NSDictionary).value(forKeyPath: "url.https") as! String
            }
            
            if let url = URL(string: imageUrl) {
                if let data = NSData(contentsOf: url) {
                    cartCellImg?.image = UIImage(data: data as Data)
                }
            }
        }
    }

    
}
