import UIKit

enum MatrixErrors : Error{
	case notInvertible
	case notSquareMatrix
	case dimensionMismatch((Int,Int),(Int,Int))
}

extension MatrixErrors : CustomStringConvertible {
    var description: String {
        switch self {
            case .notInvertible:
                return NSLocalizedString("notInvertible", comment: "")
            case .notSquareMatrix:
                return NSLocalizedString("notSquare", comment: "")
			case .dimensionMismatch(let (a,b),let (c,d)):
				return String(format: NSLocalizedString("dimensionMismatch", comment: ""), arguments: [a,b,c,d])
        }
    }
}
