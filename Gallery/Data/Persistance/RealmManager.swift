import Foundation
import RealmSwift

final class RealmManager {
    private lazy var realm: Realm = {
        try! Realm()
    }()

    func save(_ favoriteImage: FavoriteImage) {
        try? realm.write {
            realm.add(favoriteImage, update: .all)
        }
    }

    func delete(favoriteImageId: String) {
        guard let favoriteImage = realm.object(ofType: FavoriteImage.self, forPrimaryKey: favoriteImageId) else {
            return
        }

        try? realm.write {
            realm.delete(favoriteImage)
        }
    }

    func isFavorite(favoriteImageId: String) -> Bool {
        return realm.object(ofType: FavoriteImage.self, forPrimaryKey: favoriteImageId) != nil
    }
    
    func getFavorites() -> [FavoriteImage] {
        return Array(realm.objects(FavoriteImage.self))
    }
    
    func getFavorite(imageId: String) -> FavoriteImage? {
        return realm.object(ofType: FavoriteImage.self, forPrimaryKey: imageId)
    }
    
    func updateNotes(favoriteImageId: String, notes: String?) {
        guard let favoriteImage = realm.object(ofType: FavoriteImage.self, forPrimaryKey: favoriteImageId) else {
            return
        }
            
        try? realm.write {
            favoriteImage.notes = notes
        }
    }
}
