
import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var openButton: DefaultButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initButton() {
        openButton.touchDown = {
            self.gotoHome()
        }
    }
    
    
    private func gotoHome() {
        let storyboard: UIStoryboard = UIStoryboard(name: "List", bundle: nil)
        let vc: ALViewController = storyboard.instantiateViewController(withIdentifier: "AL") as! ALViewController
        let nav: DefaultNavigationController = DefaultNavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
}
