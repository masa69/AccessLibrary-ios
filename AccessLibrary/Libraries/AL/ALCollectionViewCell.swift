
import UIKit
import Photos

class ALCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var durationLabel: ALDurationLabel!
    
    
    var asset: PHAsset? {
        get {
            return self.originAsset
        }
    }
    
    /*var image: UIImage? {
        get {
            return self.originImage
        }
    }*/
    
    private var originAsset: PHAsset?
    
//    private var originImage: UIImage?
    
    
    func setCell(asset: PHAsset, size: CGSize) {
        
        self.originAsset = asset
        
        asset.toImage(size: size, contentMode: .aspectFill) { (image: UIImage?) in
            self.imageView.image = image
//            self.originImage = image
        }
        
        switch asset.mediaType {
        case .video:
            durationLabel.text = asset.duration.toFormatedString()
        default:
            durationLabel.text = ""
            break
        }
        
    }
    
}
