import Foundation
import UIKit

class PagerViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    
    var pages = [UIViewController]()
    
    var messageFlag = false
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        let currentIndex = pages.indexOf(viewController)!
        
        if (currentIndex == 0) {
            return nil
        } else {
            return pages[currentIndex-1]
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.indexOf(viewController)!
        
        if (currentIndex == pages.count-1) {
            return nil
        } else {
            return pages[currentIndex+1]
        }
    }
    
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if !messageFlag {
            let pop = PopOver(vc: self,message: "Message d'accueil pour l'utilisateur")
            pop.affichePopOver({ print("tu as cliqué sur ok") }, cancelHandler: nil)
            messageFlag = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        
        let home  = (self.storyboard?.instantiateViewControllerWithIdentifier("StationsController")) as! MainViewController
        let work  = (self.storyboard?.instantiateViewControllerWithIdentifier("StationsController")) as! MainViewController
        let geo  = (self.storyboard?.instantiateViewControllerWithIdentifier("StationsController")) as! MainViewController
        
        home.screenType = .Home
        work.screenType = .Work
        geo.screenType = .Geo
        
        pages = [home,work,geo]
        
        setViewControllers([home], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    
    
}