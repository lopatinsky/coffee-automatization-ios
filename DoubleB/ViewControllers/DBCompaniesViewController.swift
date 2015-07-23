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
    
    @IBOutlet var titleView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var splashImageView: UIImageView!
    
    public var firstLaunch = true
    private var companies = [NSDictionary]()

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setNeedsStatusBarAppearanceUpdate()
        initializeViews()
        requestCompanies()
    }
    
    func initializeViews() {
        if firstLaunch {
            self.titleView.hidden = false
            self.titleView.backgroundColor = UIColor.db_defaultColor()
        } else {
            self.titleView.hidden = true
            titleViewHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.titleLabel.text = NSLocalizedString("Выберите регион", comment: "")
        self.titleLabel.textColor = UIColor.whiteColor()
        self.title = NSLocalizedString("Выберите регион", comment: "")
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let height = Int(UIScreen.mainScreen().bounds.size.height)
        let launchScreenName = "launch_\(height).png"
        if self.firstLaunch {
            self.splashImageView.image = UIImage(named:launchScreenName)
        }
    }
    
    func requestCompanies() {
        DBServerAPI.requestCompanies({ (response) -> Void in
            self.companies = response["companies"] as! [NSDictionary]
            self.tableView.reloadData()
            if self.companies.count == 1 {
                self.putSelectedNamespace(self.companies.first!.objectForKey("namespace") as! String)
                DBCompanyInfo.sharedInstance().currentCompanyName = self.companies.first!.objectForKey("name") as! String
            } else {
                self.splashImageView.hidden = true
            }
        }, failure: { (error) -> Void in
            
        })
    }
    
    func putSelectedNamespace(namespace: String) {
        DBAPIClient.sharedClient()!.setValue(namespace, forHeader: "namespace")
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.preloadData()
        if (DBCompanyInfo.sharedInstance().deliveryTypes != nil) {
            delegate.window.rootViewController = DBLaunchEmulationViewController()
        } else {
            delegate.window.rootViewController = DBTabBarController.sharedInstance()
        }
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return firstLaunch
    }
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
        putSelectedNamespace(namespace)
        DBCompanyInfo.sharedInstance().currentCompanyName = self.companies[indexPath.row].objectForKey("name") as! String
    }
    
    func preloadData() {
        DBServerAPI.registerUser(nil)
        Venue.dropAllVenues()
        Venue.fetchAllVenuesWithCompletionHandler { (venues) -> Void in
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            delegate.saveContext()
        }
        OrderManager.sharedManager().reset()
        DBDeliverySettings.sharedInstance().selectShipping()
        DBMenu.sharedInstance().clearMenu()
        DBMenu.sharedInstance().updateMenuForVenue(nil, remoteMenu: nil)
        Order.dropAllOrders()
        DBPromoManager.sharedManager().clear()
        DBPromoManager.sharedManager().updateInfo()
        DBTabBarController.sharedInstance().moveToStartState()
        DBCompanyInfo.sharedInstance().updateInfo()
    }
}