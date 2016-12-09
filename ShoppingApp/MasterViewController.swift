//
//  MasterViewController.swift
//  ShoppingApp
//
//  Created by Thiago dos Reis on 11/25/16.
//  Copyright © 2016 Thiago dos Reis. All rights reserved.
//

import UIKit
import Moltin

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let checkoutButton = UIBarButtonItem(title: "Checkout!", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MasterViewController.checkout))
        self.navigationItem.rightBarButtonItem = checkoutButton
        
        //Instanciate the Singleton for the particular Store in Moltin
        Moltin.sharedInstance().setPublicId("UoL7Uopanf6rvTmBi68qSGrWEYwRKJzOlz4fvY9KMN")
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        //Make a call to retrieve the store products
        Moltin.sharedInstance().product.listing(withParameters: nil, success: { (responseDictionary) in
            
            self.objects = responseDictionary?["result"] as! [AnyObject]
            
            print("Objects: \(self.objects)")
            
            //tell the tableview to reload its data
            self.tableView.reloadData()
            
            }) { (responseDictionary, error) in
                print("Something went wrong")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Checkout Methods
    
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
            print("Order succeeded: \(responseDictionary)")
            
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

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                //get what the used selected
                let object = objects[indexPath.row] as! NSDictionary
                
                
                //the viewcontroler we are transitioning to
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                controller.detailItem = object
                
                //sets the back button
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! [String:AnyObject]
        cell.textLabel!.text = object["title"] as? String
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

