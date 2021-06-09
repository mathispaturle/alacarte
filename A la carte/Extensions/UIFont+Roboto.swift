//
//  UIFont+Roboto.swift
//  A la carte
//
//  Created by Sopra on 24/02/2021.
//

import Foundation
import UIKit

extension UIFont {

    //ROBOTO LIGHT
    static var robotoLight16: UIFont {
        return Fonts.robotoLight(size: 16)
    }
    
    static var robotoLight14: UIFont {
        return Fonts.robotoLight(size: 14)
    }
    
    static var robotoLight12: UIFont {
        return Fonts.robotoLight(size: 11)
    }
    
    // ROBOTO REGULAR
    static var robotoRegular64: UIFont {
        return Fonts.robotoRegular(size: 64)
    }

    static var robotoRegular16: UIFont {
        return Fonts.robotoRegular(size: 16)
    }

    static var robotoRegular14: UIFont {
        return Fonts.robotoRegular(size: 14)
    }
    
    static var robotoRegular13: UIFont {
        return Fonts.robotoRegular(size: 13)
    }

    static var robotoRegular12: UIFont {
        return Fonts.robotoRegular(size: 12)
    }

    static var robotoRegular20: UIFont {
        return Fonts.robotoRegular(size: 20)
    }

    // ROBOTO BOLD

    static var robotoBold64: UIFont {
        return Fonts.robotoBold(size: 64)
    }

    static var robotoBold32: UIFont {
        return Fonts.robotoBold(size: 32)
    }

    static var robotoBold24: UIFont {
        return Fonts.robotoBold(size: 24)
    }
    
    static var robotoBold22: UIFont {
        return Fonts.robotoBold(size: 22)
    }

    static var robotoBold20: UIFont {
        return Fonts.robotoBold(size: 20)
    }

    static var robotoBold18: UIFont {
        return Fonts.robotoBold(size: 18)
    }

    static var robotoBold16: UIFont {
        return Fonts.robotoBold(size: 16)
    }

    static var robotoBold14: UIFont {
        return Fonts.robotoBold(size: 14)
    }
    
    static var robotoBold12: UIFont {
        return Fonts.robotoBold(size: 12)
    }


    private enum Fonts {
        static func robotoRegular(size: CGFloat) -> UIFont {
            return UIFont(name: "Nunito-Regular", size: size) ?? defaultFont(size: size)
        }

        static func robotoBold(size: CGFloat) -> UIFont {
            return UIFont(name: "Nunito-Bold", size: size) ?? defaultFont(size: size)
        }
        
        static func robotoLight(size: CGFloat) -> UIFont {
            return UIFont(name: "Nunito-Light", size: size) ?? defaultFont(size: size)
        }
        
        private static func defaultFont(size: CGFloat) -> UIFont {
            return systemFont(ofSize: size)
        }
    }

}
