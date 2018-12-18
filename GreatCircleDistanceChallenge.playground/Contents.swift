import UIKit

// Location
struct Location: Codable
{
    var latitude: Double?
    var longitude: Double?
    
    private enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}

// Gurgaon Location
let gurgaon = Location(latitude: 28.413824, longitude: 77.042282) //(28.413824,77.042282)

// User Model
class User {
    var id: String?
    var name: String?
    var location: Location?
    
    init(attributes:[String:AnyHashable]?) {
        
        // Validation
        guard let attributes = attributes else  {
            return
        }
        id = attributes["user_id"] as? String
        name = attributes["user_name"] as? String
        if let coordinate = attributes["location"] as? [String:Double] {
            location = Location.init(latitude: coordinate["lat"], longitude: coordinate["lng"])
        }
    }
}

// Calculation of Great Circle Distance
func greatCircleDistance(la1: Double, lo1: Double, la2: Double, lo2: Double, radius: Double = 6371.0) -> Double {
    
    // Converts from degrees to radians
    let dToR = { (angle: Double) -> Double in
        return ((.pi/180) * angle)
    }
    
    let lat1 = dToR(la1)
    let lon1 = dToR(lo1)
    let lat2 = dToR(la2)
    let lon2 = dToR(lo2)
    
    let latDiff = abs(lat2 - lat1)
    let lonDiff = abs(lon2 - lon1)
    
    let a = pow(sin(latDiff/2), 2) + cos(lat1) * cos(lat2) * pow(sin(lonDiff/2), 2)
    let d_sigma = 2 * asin(sqrt(a))
    let ans = radius * d_sigma
    return ans
}


// Fetch Users Information
func fetchMatchingCustomers() -> [User] {
    
    var matchingCustomers = [User]()
    
    if let url = URL(string: "https://s3-us-west-2.amazonaws.com/hate2wait/customers.json") {
        
        do {
            // Fetch Users Data
            let jsonData = try Data(contentsOf: url)
            
            // Parse Response
            let userRecords = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments)
            
            if let records = userRecords as? [[String: AnyHashable]]  {
                
                for record in records {
                    
                    // User Info
                    let user = User(attributes: record)
                    
                    // Valid Matching Customers
                    if greatCircleDistance(la1: gurgaon.latitude ?? 0.0, lo1: gurgaon.longitude ?? 0.0, la2: user.location?.latitude ?? 0.0, lo2: user.location?.longitude ?? 0.0) < 50.0 {
                        matchingCustomers.append(user)
                    }
                }
                
                // Sort customers based on id's
                matchingCustomers.sort { (user1, user2) -> Bool in
                    if let userId1 = user1.id,
                        let userId2 = user2.id {
                        return userId1 < userId2
                    }
                    return false
                }
            }
        }
        catch {
            print(error)
        }
    }
    return matchingCustomers
}

// Fetch Matching Customers
var matchingCustomers = fetchMatchingCustomers()

// Print all matched customer details
for user in matchingCustomers {
    print("User Name:\(user.name ?? "") id: \(user.id ?? "")")
}
