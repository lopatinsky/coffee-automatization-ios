//
//  DBCompaniesViewController.swift
//  
//
//  Created by Balaban Alexander on 18/06/15.
//
//

import UIKit

@objc
public class DBCompaniesViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var companies = [NSDictionary]()

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        requestCompanies()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestCompanies() {
        DBServerAPI.requestCompanies({ (response) -> Void in
            self.companies = response["companies"] as! [NSDictionary]
            self.tableView.reloadData()
        }, failure: { (error) -> Void in
            
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DBCompaniesViewController: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.companies.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell.textLabel!.text = self.companies[indexPath.row].objectForKey("name") as? String
        return cell
    }
}

extension DBCompaniesViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let namespace = self.companies[indexPath.row].objectForKey("namespace") as! String
        DBAPIClient.sharedClient()!.setValue(namespace, forHeader: "namespace")
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if (DBCompanyInfo.sharedInstance().deliveryTypes != nil) {
            delegate.window.rootViewController = DBLaunchEmulationViewController()
        } else {
            delegate.window.rootViewController = DBTabBarController.sharedInstance()
        }
    }
}