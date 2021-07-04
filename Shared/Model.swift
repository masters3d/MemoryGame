//
//  Model.swift
//  MemoryGame
//
//  Created by Cheyo Jimenez on 6/30/21.
//

import Foundation
import SwiftUI


enum ImageCache {

    private static var _cache = Dictionary<String,UIImage>()

    private static var _cacheQueue = DispatchQueue(label: "masters3d.cache.queue", attributes: .concurrent)

    static func warmCacheWith(emojiAsString:String) {
        _cacheQueue.async {
            if let _ = _cache[emojiAsString] {
            } else {
                print("selected: cache warming \(emojiAsString)")
                let newImage = emojiToImageBlocking(emojiAsString)
                _cacheQueue.async(flags: .barrier) {
                        _cache[emojiAsString] = newImage
                }
            }
        }
    }

    static subscript(emojiAsString: String) -> UIImage {
        get {
           _cacheQueue.sync(flags: .barrier) {
                if let image = _cache[emojiAsString] {
                    return image
                }
                print("selected: cache miss \(emojiAsString)")
                let newImage = emojiToImageBlocking(emojiAsString)
                _cache[emojiAsString] = newImage
                return newImage

            }
        }
        set(newValue) {
           _cacheQueue.sync(flags: .barrier) {
                _cache[emojiAsString] = newValue
            }
        }
    }

    private static func emojiToImageBlocking(_ emojiAsString:String) -> UIImage {
        let nsString = (emojiAsString as NSString)
        let font = UIFont.systemFont(ofSize: 1024)
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        UIColor.clear.set()
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }


}

struct EmojiValue:Hashable {
    var emojiAsString: String
}

struct EmojiState:Hashable {
    var value: EmojiValue
    var isFaceUp = false
    var isMatch = false
    var selectedCount = 0
}

extension EmojiState {
    func emojiToImage() -> UIImage {
        ImageCache[self.value.emojiAsString]
    }
}

struct MemorizeModel {

    static let allEmojis = getAllEmojis()

    static func getRandomEmoji() -> String {
        return allEmojis.randomElement() ?? "😎"
    }

    static func getRandomEmoji(count: Int)-> [String]{

        guard count > 0, count < allEmojis.count
        else {
         return allEmojis
        }

        return Array(allEmojis.shuffled()[0..<count])
    }

    static func getMemorizeCards(count:Int) -> [EmojiState] {
        return getRandomEmoji(count: count).map {

            let emojiAsString = $0
            defer {
                ImageCache.warmCacheWith(emojiAsString: emojiAsString)
            }
            return EmojiState.init(value: .init(emojiAsString: emojiAsString))
            }
        }

    private static func getAllEmojis() -> [String] {
        var emojis = Set<String>()
        for i in 8400...0x1F9FF{
            if let scalar = UnicodeScalar(i), scalar.properties.isEmojiPresentation {
                emojis.insert((String(scalar)))
            }
        }
        return Array(emojis)
    }
}

