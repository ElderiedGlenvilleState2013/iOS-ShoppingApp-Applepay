//
//  DetailViewController.swift
//  ShoppingApp
//
//  Created by Thiago dos Reis on 11/25/16.
//  Copyright © 2016 Thiago dos Reis. All rights reserved.
//

import UIKit
import Moltin

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var detailPriceLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            
            //Set the Product title
            let productTitle = detail["title"] as? String
            if let title = productTitle{
                self.detailTitleLabel?.text = title
            }
            
            //Set the PriceLabel
            let productPrice = detail.value(forKeyPath: "price.data.formatted.without_tax") as? String
            if let price = productPrice{
                self.detailPriceLabel?.text = price
            }
            
            //Set the DescriptionLabel
            let productDescription = detail["description"] as? String
            if let descr = productDescription{
                self.detailDescriptionLabel?.text = descr
            }
            
            //set the image for the product
            var imageUrl = ""
            
            if let images = detail.object(forKey: "images") as? NSArray {
                if (images.firstObject != nil) {
                    imageUrl = (images.firstObject as! NSDictionary).value(forKeyPath: "url.https") as! String
                }
                print("Product image URL: \(imageUrl)")
                
                
                if let url = URL(string: imageUrl) {
                    if let data = NSData(contentsOf: url) {
                        self.detailImageView?.image = UIImage(data: data as Data)
                    }
                }
            }
            
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    @IBAction func addToCartTapped(_ sender: UIButton) {
        //get the current product ID
        let productID = self.detailItem?["id"] as? String
        
        if let id = productID {
            
            //Add the product to hte Cart
            Moltin.sharedInstance().cart.insertItem(withId: id, quantity: 1, andModifiersOrNil: nil, success: { (responseDictionary) in
                
                ShowSimpleMessage(myMessage: "Added item to cart.", myTitle: "Added to cart!", myView: self)
                
                }, failure: { (responseDictionary, error) in
                    
                    ShowSimpleMessage(myMessage: "Catalog only, Product can not be purchased!" , myTitle: "Erro", myView: self)
                    //Couldn't add product to cart
                    print("Someting went wrong")
            })
        }
    }
    

}

func ShowSimpleMessage(myMessage: String, myTitle: String, myView: UIViewController) -> Void{
    
    //Display a message to the used that the item has been added
    let alert = UIAlertController(title: myTitle, message: myMessage, preferredStyle: UIAlertControllerStyle.alert)
    
    //enable an action button on the alert
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    
    //show the alert
    myView.present(alert, animated: true, completion: nil)
}


