
import UIKit
import Photos

class ALImagePreviewViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    var asset: PHAsset?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNav()
        self.initEditor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initNav() {
        self.title = "Photo"
    }
    
    
    private func initEditor() {
        if let asset: PHAsset = self.asset {
            asset.toImage { (imageData: Data?) in
                if let data: Data = imageData {
                    self.imageView?.image = UIImage(data: data)
                    self.imageView?.contentMode = .scaleAspectFit
                }
            }
        }
    }
    
}
