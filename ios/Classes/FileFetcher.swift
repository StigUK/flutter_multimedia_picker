import Foundation
import Photos

class FileFetcher {
    
    //MARK: GET IMAGE PATH
    static func getImage() -> [MediaFile] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var files = [MediaFile]()
        assets.enumerateObjects{asset, index, info in
            
            var mediaFile: MediaFile? = nil
            var url: String? = nil
            var orientation: Int = 0
            (url, orientation) = getFullSizeImageURLAndOrientation(for: asset)

            let since1970 = asset.creationDate?.timeIntervalSince1970
            var dateAdded: Int? = nil
            if since1970 != nil {
                dateAdded = Int(since1970!)
            }
            mediaFile = MediaFile.init(
                id: asset.localIdentifier,
                dateAdded: dateAdded,
                path: url,
                thumbnailPath: nil,
                orientation: orientation,
                duration: nil,
                mimeType: nil,
                type: .IMAGE)
            files.append(mediaFile!)
        }

        print("GET PHOTOS: ", files)
        return files
    }
    
    //MARK: GET VIDEOS PATH
    static func getVideo() -> [MediaFile] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        var files = [MediaFile]()
        assets.enumerateObjects{asset, index, info in
            
            var mediaFile: MediaFile? = nil
            var url: String? = nil
            let orientation: Int = 0
            
            var duration: Double? = nil
            
            let semaphore = DispatchSemaphore(value: 0)
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, _, info) in
                let avURLAsset = avAsset as? AVURLAsset
                url = avURLAsset?.url.path
                let durationTime = avAsset?.duration
                if durationTime != nil {
                    duration = (CMTimeGetSeconds(durationTime!) * 1000).rounded()
                    UserDefaults.standard.set(duration, forKey: "duration-\(asset.localIdentifier)")
                }
                semaphore.signal()
            }
            semaphore.wait()

            let since1970 = asset.creationDate?.timeIntervalSince1970
            var dateAdded: Int? = nil
            if since1970 != nil {
                dateAdded = Int(since1970!)
            }
            mediaFile = MediaFile.init(
                id: asset.localIdentifier,
                dateAdded: dateAdded,
                path: url,
                thumbnailPath: nil,
                orientation: orientation,
                duration: duration,
                mimeType: nil,
                type: .VIDEO)
            files.append(mediaFile!)
        }
        
        print("GET VIDEOS: ", files)
        return files
    }
    
    //MARK: GET ALL PHOTOS AND VIDEOS
    static func getAllPhotosVideos() -> [MediaFile] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        var files = [MediaFile]()
        
        assets.enumerateObjects{asset, index, info in
            if let mediaFile = getMediaFile(for: asset, loadPath: true, generateThumbnailIfNotFound: false) {
                files.append(mediaFile)
            } else {
                print("File path not found for an item in \(String(describing: asset))")
            }
        }
        
        return files
    }
    
        
    static func getThumbnail(for fileId: String, type: MediaType) -> String? {
        let cachePath = getCachePath(for: fileId)
        if FileManager.default.fileExists(atPath: cachePath.path) {
            return cachePath.path
        }
        
        
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [fileId], options: .none).firstObject
        if asset == nil {
            return nil
        }
        
        if generateThumbnail(asset: asset!, destination: cachePath) {
            return cachePath.path
        }
        
        return nil
    }
    
    static func getMediaFile(for asset: PHAsset, loadPath: Bool, generateThumbnailIfNotFound: Bool) -> MediaFile? {
        
        var mediaFile: MediaFile? = nil
        var url: String? = nil
        var duration: Double? = nil
        var orientation: Int = 0
        
        var cachePath: URL? = getCachePath(for: asset.localIdentifier)
        if !FileManager.default.fileExists(atPath: cachePath!.path) {
            if generateThumbnailIfNotFound {
                if !generateThumbnail(asset: asset, destination: cachePath!) {
                    cachePath = nil
                }
            } else {
                cachePath = nil
            }
        }
        
        
        if (asset.mediaType ==  .image) {
            
            if loadPath {
         
                (url, orientation) = getFullSizeImageURLAndOrientation(for: asset)
                
                // Not working since iOS 13
                // (url, orientation) = getPHImageFileURLKeyAndOrientation(for: asset)
                
            }
            
            
            
            let since1970 = asset.creationDate?.timeIntervalSince1970
            var dateAdded: Int? = nil
            if since1970 != nil {
                dateAdded = Int(since1970!)
            }
            mediaFile = MediaFile.init(
                id: asset.localIdentifier,
                dateAdded: dateAdded,
                path: url,
                thumbnailPath: cachePath?.path,
                orientation: orientation,
                duration: nil,
                mimeType: nil,
                type: .IMAGE)
            
        } else if (asset.mediaType == .video) {
            
            if loadPath {
                let semaphore = DispatchSemaphore(value: 0)
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, _, info) in
                    let avURLAsset = avAsset as? AVURLAsset
                    url = avURLAsset?.url.path
                    let durationTime = avAsset?.duration
                    if durationTime != nil {
                        duration = (CMTimeGetSeconds(durationTime!) * 1000).rounded()
                        UserDefaults.standard.set(duration, forKey: "duration-\(asset.localIdentifier)")
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            } else {
                duration = UserDefaults.standard.double(forKey: "duration-\(asset.localIdentifier)")
                if duration == 0 {
                    duration = nil
                }
            }
            
            let since1970 = asset.creationDate?.timeIntervalSince1970
            var dateAdded: Int? = nil
            if since1970 != nil {
                dateAdded = Int(since1970!)
            }
            mediaFile = MediaFile.init(
                id: asset.localIdentifier,
                dateAdded: dateAdded,
                path: url,
                thumbnailPath: cachePath?.path,
                orientation: 0,
                duration: duration,
                mimeType: nil,
                type: .VIDEO)
            
        }
        return mediaFile
    }
    
    private static func generateThumbnail(asset: PHAsset, destination: URL) -> Bool {
        
        let scale = UIScreen.main.scale
        let imageSize = CGSize(width: 79 * scale, height: 79 * scale)
        let imageContentMode: PHImageContentMode = .aspectFill
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        var saved = false
        PHCachingImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: imageContentMode, options: options) { (image, info) in
            do {
//                try image!.pngData()?.write(to: destination)
                try UIImagePNGRepresentation(image!)?.write(to: destination)
                saved = true
            } catch (let error) {
                print(error)
                saved = false
            }
            
        }
        return saved
    }
    
    private static func getCachePath(for identifier: String) -> URL {
        let fileName = Data(identifier.utf8).base64EncodedString().replacingOccurrences(of: "==", with: "")
        let path = try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(fileName + ".png")
        return path
    }
    
    private static func getFullSizeImageURLAndOrientation(for asset: PHAsset)-> (String?, Int) {
        var url: String? = nil
        var orientation: Int = 0
        let semaphore = DispatchSemaphore(value: 0)
        let options2 = PHContentEditingInputRequestOptions()
        options2.isNetworkAccessAllowed = true
        asset.requestContentEditingInput(with: options2){(input, info) in
            orientation = Int(input?.fullSizeImageOrientation ?? 0)
            url = input?.fullSizeImageURL?.path
            semaphore.signal()
        }
        semaphore.wait()
        
        return (url, orientation)
    }
    
}

extension UIImage.Orientation{
    func inDegrees() -> Int {
        switch  self {
        case .down:
            return 180
        case .downMirrored:
            return 180
        case .left:
            return 270
        case .leftMirrored:
            return 270
        case .right:
            return 90
        case .rightMirrored:
            return 90
        case .up:
            return 0
        case .upMirrored:
            return 0
        }
    }
}
