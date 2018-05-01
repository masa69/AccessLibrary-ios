
import UIKit
import Photos

class ALViewController: UIViewController {

    @IBOutlet weak var alCollectionView: ALCollectionView!
    
    
    var item: DefaultNavigationItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNav()
        self.initCollectionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initNav() {
        self.title = "Lists"
        self.item = DefaultNavigationItem(item: self.navigationItem)
        self.item?.addLeftItem(type: .close) {
            self.close()
        }
    }
    
    
    private func initCollectionView() {
        alCollectionView.didOverScrollTop = {
            self.close()
        }
        alCollectionView.didSelectItemAt = { (collectionView: UICollectionView, indexPath: IndexPath) in
            if let cell: ALCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ALCollectionViewCell {
                if let asset: PHAsset = cell.asset {
                    self.gotoEditor(asset: asset)
                }
            }
        }
        alCollectionView.initList(type: .imageAndVideo) { (isAuthorization: Bool) in
            print("isAuthorization: \(isAuthorization)")
        }
    }
    
    
    private func gotoEditor(asset: PHAsset) {
        switch asset.mediaType {
        case .image:
            let storyboard: UIStoryboard = UIStoryboard(name: "ImagePreview", bundle: nil)
            let vc: ALImagePreviewViewController = storyboard.instantiateViewController(withIdentifier: "ALImagePreview") as! ALImagePreviewViewController
            vc.asset = asset
            self.navigationController?.pushViewController(vc, animated: true)
        case .video:
            let storyboard: UIStoryboard = UIStoryboard(name: "VideoPreview", bundle: nil)
            let vc: ALVideoPreviewViewController = storyboard.instantiateViewController(withIdentifier: "ALVideoPreview") as! ALVideoPreviewViewController
            vc.asset = asset
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    
    private func close() {
        self.dismiss(animated: true, completion: nil)
    }

}
