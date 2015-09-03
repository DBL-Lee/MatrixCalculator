enum MatrixErrors : ErrorType{
	case NotInvertible
	case NotSquareMatrix
	case DimensionMismatch((Int,Int),(Int,Int))
}

extension MatrixErrors : CustomStringConvertible {
    var description: String {
        switch self {
            case .NotInvertible:
                return "Matrix is not invertible!"            
            case .NotSquareMatrix:
                return "Matrix is not square matrix!"
			case .DimensionMismatch((a,b),(c,d)):
				return "Cannot perform operation on \(a)×\(b) and \(c)×\(d) matrices."
        }
    }
}