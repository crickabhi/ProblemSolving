import UIKit

var input = [[1,2,[3]],4] as [Any] // [1,2,[3,4,[5,6],7,8],9,10] as [Any]

func flatten(_ input: [Any]) -> [Int]{

    var output = [Int]()

    input.forEach { item in

        // check if its a number and if its an array get its children
        if let array = item as? [Any] {
            output = output + flatten(array)
        }
        else {
            if let integerItem = item as? Int {
                output.append(integerItem)
            }
        }
    }
    return output
}

let flatArray = flatten(input)
print("Flatten Array: \(flatArray)")

