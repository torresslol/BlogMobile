//
//  Float+ToInt.swift
//  BlogMobile
//
//  Created by yy on 2024/12/28.
//

import Foundation

extension CGFloat {
    // MARK: - Numeric Extensions

    var ceil: CGFloat {
        return Darwin.ceil(self)
    }

    var floor: CGFloat {
        return Darwin.floor(self)
    }

    var round: CGFloat {
        return Darwin.round(self)
    }

    func rounded(to places: Int) -> CGFloat {
        let multiplier = pow(10, CGFloat(places))
        return (self * multiplier).round / multiplier
    }

    var int: CGFloat {
        return CGFloat(Int(self))
    }
}

