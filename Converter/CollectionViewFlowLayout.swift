//
//  CollectionViewFlowLayout.swift
//  Converter
//
//  Created by Alan Yepez on 11/8/15.
//  Copyright © 2015 alanypz. All rights reserved.
//

import UIKit

class CollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let attributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath) else { return nil }
        
        attributes.transform = CGAffineTransformMakeScale(0, 0)
        
        attributes.alpha = 0
        
        return attributes
        
    }
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let attributes = super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath) else { return nil }
                
        attributes.alpha = 0
        
        return attributes

        
    }
    
}
