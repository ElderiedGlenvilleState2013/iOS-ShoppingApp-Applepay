//
//  CartViewController.swift
//  ShoppingApp
//
//  Created by Thiago dos Reis on 12/11/16.
//  Copyright © 2016 Thiago dos Reis. All rights reserved.
//

import UIKit
import Moltin

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    fileprivate var cartData:NSDictionary?
    fileprivate var cartProducts:NSDictionary?
    @IBOutlet weak var totalCart: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonCheckout: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        totalCart?.text = ""
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshCart()
    }
    
    func refreshCart() {
        // Get the cart contents from Moltin API
        Moltin.sharedInstance().cart.getContentsWithsuccess({ (response) -> Void in
            // Got cart contents succesfully!
            // Set local var's
            self.cartData = response as NSDictionary?
            //print("My Cart \(self.cartData)")
            
            self.cartProducts = self.cartData?.value(forKeyPath: "result.contents") as? NSDictionary
            
            // Reset cart total
            if let cartPriceString:NSString = self.cartData?.value(forKeyPath: "result.totals.post_discount.formatted.with_tax") as? NSString {
                self.totalCart?.text = cartPriceString as String
                
            }
            
            // And reload table of cart items...
            self.tableView?.reloadData()
            //print("Requested to ReloadData from Cart")
        
            
            // If there's < 1 product in the cart, disable the checkout button
            self.buttonCheckout?.isEnabled = (self.cartProducts != nil && (self.cartProducts?.count)! > 0)
            //print("Check the qtd Items")
            
            }, failure: { (response, error) -> Void in
                // Something went wrong; hide loading UI and warn user
                
                
                ShowSimpleMessage(myMessage: "Sorry, we couldn't load cart!", myTitle: "Ops! Error", myView: self)
                
                
                print("Something went wrong with the Cart...")
                print(error)
        })
        
        
        
    }

    
    // MARK: - TableView Data source & Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("Table Cell: numberOfRowsInSection")
        if (cartProducts != nil) {
            return cartProducts!.allKeys.count
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("Table Cell")
        
        let cell: CartTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartTableViewCell
        
        
        let row = (indexPath as NSIndexPath).row
        
        let product:NSDictionary = cartProducts!.allValues[row] as! NSDictionary
        
        cell.setItemDictionary(product)
        //print("Called the cell for product: \(product)")
        
        //cell.productId = cartProducts!.allKeys[row] as? String
        return cell
        
    }
    
    
    // MARK: - Checkout Methods
    @IBAction func checkoutTouch(_ sender: UIButton) {
        checkout()
    }
    
    
    func checkout() {
        
        //Hardcode the order data. In a real app, you would gather this data from the user using a bunch of textfield and labels
        let orderParameters = [
            
            "customer": ["first_name":"Thiago",
                         "last_name":"Reis",
                         "email":"thiagodreis@gmail.com"],
            "gateway": "dummy",
            "shipping": "my-shipping",
            "bill_to": ["first_name":"John",
                        "last_name":"Doe",
                        "address_1":"123 Main St.",
                        "address_2":"",
                        "city": "Sunnyvale",
                        "county": "California",
                        "country": "US",
                        "postcode":"CA94040",
                        "phone":"8313323344"],
            "ship_to": "bill_to"
            ] as [AnyHashable: Any]
        
        //create an order
        Moltin.sharedInstance().cart.order(withParameters: orderParameters, success: { (responseDictionary) in
            // Order succesful
            //print("Order succeeded: \(responseDictionary)")
            
            // Extract the Order ID so that it can be used in payment too...
            let orderId = NSDictionary(dictionary: responseDictionary!).value(forKeyPath: "result.id")
            print("Order ID: \(orderId)")
            
            if let myOrderId = orderId {
                
                //Hardcode the credit card details.
                let paymentParameters = ["data": [
                    "number":"4242424242424242",
                    "expiry_month": "02",
                    "expiry_year": "2017",
                    "cvv": "123"]
                    ] as [AnyHashable: Any]
                
                //Process the payment
                Moltin.sharedInstance().checkout.payment(withMethod: "purchase", order: String(describing: myOrderId), parameters: paymentParameters, success: { (responseDictionary) in
                    
                    //Display the message of sucess
                    ShowSimpleMessage(myMessage: "Your order was sucessfuly posted!", myTitle: "Order Complete", myView: self)
                    
                    }, failure: { (responseDictionary, error) in
                        
                        ShowSimpleMessage(myMessage: "Sorry, we couldn't process the payment!", myTitle: "Ops! Error", myView: self)
                        //print("Could not process the payment!")
                })
                
            }
            
        }) { (responseDictionary, error) in
            ShowSimpleMessage(myMessage: "Sorry, we couldn't process the order!", myTitle: "Ops! Error", myView: self)
        }
        
        //process payment
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
