
import Foundation
import RealmSwift

class FavoriteImage: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var regularUrl: String = ""
    @Persisted var thumbUrl: String = ""
    @Persisted var authorName: String = ""
    @Persisted var notes: String?

}
