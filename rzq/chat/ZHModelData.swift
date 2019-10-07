//
//  ZHModelData.swift
//  ZHChatSwift
//
//  Created by aimoke on 16/12/16.
//  Copyright © 2016年 zhuo. All rights reserved.
//

import UIKit
import ZHChat
import Kingfisher

let kZHCDemoAvatarDisplayNameCook = "Tim Cook";
let kZHCDemoAvatarDisplayNameJobs = "Jobs";
let kZHCDemoAvatarIdCook = "468-768355-23123";
let kZHCDemoAvatarIdJobs = "707-8956784-57";

protocol ChatDelegate {
    func reloadChat()
}

class ZHModelData: NSObject {
    
    var order : DatumDel?
    var user : VerifyResponse?
    var delegate : ChatDelegate?
    
    var messages: NSMutableArray = [];
    var avatars: NSMutableDictionary = [:];
    var users: NSDictionary = [:];
    
    var senderImage : ZHCMessagesAvatarImage?
    var receiverImage : ZHCMessagesAvatarImage?
    
    var outgoingBubbleImageData: ZHCMessagesBubbleImage?;
    var incomingBubbleImageData: ZHCMessagesBubbleImage?;
    
//    func loadMessages() -> Void {
//        let avatarFactory: ZHCMessagesAvatarImageFactory = ZHCMessagesAvatarImageFactory.init(diameter: UInt(kZHCMessagesTableViewCellAvatarSizeDefault));
//        let cookImage: ZHCMessagesAvatarImage = avatarFactory.avatarImage(with: UIImage.init(named: "splash_logo"))
//        let jobsImage: ZHCMessagesAvatarImage = avatarFactory.avatarImage(with: UIImage.init(named: "splash_logo"));
//        avatars = [kZHCDemoAvatarIdCook : cookImage,kZHCDemoAvatarIdJobs : jobsImage];
//        users = [kZHCDemoAvatarIdJobs : kZHCDemoAvatarDisplayNameJobs,kZHCDemoAvatarIdCook : kZHCDemoAvatarDisplayNameCook];
//        let bubbleFactory: ZHCMessagesBubbleImageFactory = ZHCMessagesBubbleImageFactory.init();
//        outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImage(with: UIColor.zhc_messagesBubbleBlue());
//        incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImage(with: UIColor.zhc_messagesBubbleGreen());
//
//        let filePath: String = Bundle.main.path(forResource: "data", ofType: "json")!;
//        let data: NSData = try!NSData.init(contentsOfFile: filePath);
//        let dic: NSDictionary = try!JSONSerialization.jsonObject(with: data as Data, options: []) as! NSDictionary;
//        let array: NSArray = dic.object(forKey: "feed") as! NSArray;
//        let muArray: NSMutableArray = [];
//        for item in array {
//            let model: ZHUserModel = ZHUserModel.init();
//            model.initialDataWithDictionary(dic: item as! NSDictionary);
//            muArray.add(model);
//        }
//
//        for i in 0 ..< muArray.count{
//            let model: ZHUserModel = muArray.object(at: i) as! ZHUserModel;
//            let avatarId: NSString?;
//            let displayName: NSString?;
//            if i%3 == 0 {
//                avatarId = kZHCDemoAvatarIdCook as NSString?;
//                displayName = kZHCDemoAvatarDisplayNameCook as NSString?;
//            }else {
//                avatarId = kZHCDemoAvatarIdJobs as NSString?;
//                displayName = kZHCDemoAvatarDisplayNameJobs as NSString?;
//            }
//            let message: ZHCMessage = ZHCMessage.init(senderId: avatarId! as String, displayName: displayName! as String, text: model.content!)
//
//            messages.add(message);
//        }
//
//    }
    
    func loadMessages() -> Void {
        
        ApiService.getChatData(Authorization: self.user?.data?.accessToken ?? "", id: self.order?.chatId ?? 0) { (response) in
            self.messages.removeAllObjects()
            let avatarFactory: ZHCMessagesAvatarImageFactory = ZHCMessagesAvatarImageFactory.init(diameter: UInt(kZHCMessagesTableViewCellAvatarSizeDefault));
            
//            let cookImage: ZHCMessagesAvatarImage = avatarFactory.avatarImage(with: UIImage.init(named: "ic_back"))
//            self.avatars = [kZHCDemoAvatarIdCook : cookImage,kZHCDemoAvatarIdJobs : cookImage]
//            self.users = [kZHCDemoAvatarIdJobs : kZHCDemoAvatarDisplayNameJobs,kZHCDemoAvatarIdCook : kZHCDemoAvatarDisplayNameCook]
            
            let bubbleFactory: ZHCMessagesBubbleImageFactory = ZHCMessagesBubbleImageFactory.init();
            self.outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImage(with: UIColor.colorPrimary)
            self.incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImage(with: UIColor.processing)
            
            let muArray: NSMutableArray = [];
            let arr = response.chatData?.messages ?? [Message]()
            for message in arr {
                let model: ZHUserModel = ZHUserModel.init()
                model.id = message.id ?? 0
                model.content = message.content ?? ""
                model.type = message.type ?? 0
                model.image = message.image ?? ""
                model.voice = message.voice ?? ""
                model.userId = message.userID ?? ""
                model.userName = message.userName ?? ""
                model.userImage = message.userImage ?? ""
                model.createDate = message.createdDateString ?? ""
                
                if (model.userImage?.count ?? 0 > 0) {
                let url = URL(string: "\(Constants.IMAGE_URL)\(model.userImage ?? "")")
                    self.loadAvatarImage(url: url!, userId: model.userId ?? "")
                }
                
                muArray.add(model)
            }
            
            for i in 0 ..< muArray.count{
                let model: ZHUserModel = muArray.object(at: i) as! ZHUserModel
                let avatarId: String?
                let displayName: String?
                
                avatarId = model.userId ?? ""
                displayName = model.userName ?? ""
                
                let messageType = model.type ?? 1
                switch messageType {
                case 1://message
                    
//                    let message: ZHCMessage = ZHCMessage.init(senderId: avatarId! as String, displayName: displayName! as String, text: model.content!)
                    
                    let dateFormatter = DateFormatter()
                                     dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                                     dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                     let messageDate = dateFormatter.date(from:model.createDate!)!
                    
                    let message : ZHCMessage = ZHCMessage.init(senderId: avatarId! as String, senderDisplayName: displayName! as String, date: messageDate, text: model.content!)
                    
                    
                    self.messages.add(message)
                    self.delegate?.reloadChat()
                    break
                case 2://image
                        let url = URL(string: "\(Constants.IMAGE_URL)\(model.image ?? "")")
                        KingfisherManager.shared.retrieveImage(with: url!, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                            let photoItem = ZHCPhotoMediaItem.init(image: image)
                            photoItem.appliesMediaViewMaskAsOutgoing = false
                            let photoMessage = ZHCMessage.init(senderId: avatarId! as String, displayName: model.image ?? "", media: photoItem)
                            self.messages.add(photoMessage)
                            self.delegate?.reloadChat()
                        })
                    break
                case 3://audio
                    let url = URL(string: "\(Constants.IMAGE_URL)\(model.voice ?? "")")
                    let audioData: Data = try! Data.init(contentsOf: url!)
                    let audioItem: ZHCAudioMediaItem = ZHCAudioMediaItem.init(data: audioData as Data)
                    audioItem.appliesMediaViewMaskAsOutgoing = true
                    let audioMessage: ZHCMessage = ZHCMessage.init(senderId: avatarId! as String, displayName: displayName! as String, media: audioItem)
                    self.messages.add(audioMessage)
                     self.delegate?.reloadChat()
                    break
                default:
                    let message: ZHCMessage = ZHCMessage.init(senderId: avatarId! as String, displayName: displayName! as String, text: model.content ?? "")
                    
                    self.messages.add(message)
                    break

                }
                
            }
            self.delegate?.reloadChat()
            
        }
        
    }
    
    func addPhotoMediaMessage(image : UIImage) -> Void {
        let photoItem = ZHCPhotoMediaItem.init(image: image)
        photoItem.appliesMediaViewMaskAsOutgoing = false
        let photoMessage = ZHCMessage.init(senderId: self.user?.data?.userID ?? "", displayName: self.user?.data?.fullName ?? "", media: photoItem)
        messages.add(photoMessage)
    }
    
    func addLocationMediaMessageCompletion(completion: @escaping ZHCLocationMediaItemCompletionBlock) -> Void {
        let ferryBuildingInSF: CLLocation = CLLocation.init(latitude: 22.610599, longitude: 114.030238);
        let locationItem = ZHCLocationMediaItem.init();
        locationItem.setLocation(ferryBuildingInSF, withCompletionHandler: completion);
        locationItem.appliesMediaViewMaskAsOutgoing = true;
        let locationMessage: ZHCMessage = ZHCMessage.init(senderId: self.user?.data?.userID ?? "", displayName: self.user?.data?.fullName ?? "", media: locationItem);
        messages.add(locationMessage);
    }
    
    func addVideoMediaMessage() -> Void {
        let videoURL: NSURL = NSURL.fileURL(withPath: "file://") as NSURL;
        let videoItem: ZHCVideoMediaItem = ZHCVideoMediaItem.init(fileURL: videoURL as URL, isReadyToPlay: true);
        videoItem.appliesMediaViewMaskAsOutgoing = true;
        let videoMessage = ZHCMessage.init(senderId: self.user?.data?.userID ?? "", displayName: self.user?.data?.fullName ?? "", media: videoItem);
        messages.add(videoMessage);
    }
    
    func addAudioMediaMessage(audioData : Data) -> Void {
//        let sample: NSString = Bundle.main.path(forResource: "zhc_messages_sample", ofType: "m4a")! as NSString;
//        let audioData: NSData = try!NSData.init(contentsOfFile: sample as String);
        let audioItem: ZHCAudioMediaItem = ZHCAudioMediaItem.init(data: audioData as Data)
        audioItem.appliesMediaViewMaskAsOutgoing = true
        let audioMessage: ZHCMessage = ZHCMessage.init(senderId: self.user?.data?.userID ?? "", displayName: self.user?.data?.fullName ?? "", media: audioItem)
        messages.add(audioMessage)
    }
    
    func loadAvatarImage(url : URL, userId : String) {
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
             let avatarFactory: ZHCMessagesAvatarImageFactory = ZHCMessagesAvatarImageFactory.init(diameter: UInt(kZHCMessagesTableViewCellAvatarSizeDefault));
            
            let loadedImage: ZHCMessagesAvatarImage = avatarFactory.avatarImage(with: image)
            
          //  self.avatars.setNilValueForKey(userId)
            
            if (userId == self.user?.data?.userID ?? "") {
                self.senderImage = loadedImage
            }else {
                self.receiverImage = loadedImage
            }
            
            self.avatars[userId] = loadedImage
            
            self.delegate?.reloadChat()
           
        })
    }
    

}
