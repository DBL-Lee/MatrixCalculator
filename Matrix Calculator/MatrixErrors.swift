import UIKit

enum MatrixErrors : ErrorType{
	case NotInvertible
	case NotSquareMatrix
	case DimensionMismatch((Int,Int),(Int,Int))
}

extension MatrixErrors : CustomStringConvertible {
    var description: String {
        switch self {
            case .NotInvertible:
                return NSLocalizedString("notInvertible", comment: "")
            case .NotSquareMatrix:
                return NSLocalizedString("notSquare", comment: "")
			case .DimensionMismatch(let (a,b),let (c,d)):
				return String(format: NSLocalizedString("dimensionMismatch", comment: ""), arguments: [a,b,c,d])
        }
    }
}