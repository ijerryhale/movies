//	LabelPadded.swift
// Copyright (c) 2019 Jerry Hale

//
//  Created by Jerry Hale on 5/28/18.

@IBDesignable
class LabelPadded: UILabel
{
   override func drawText(in rect: CGRect)
    {
         super.drawText(in: rect.inset(by: UIEdgeInsets(top: 0, left: CGFloat(2), bottom: 0, right: CGFloat(4))))
    }

    override public var intrinsicContentSize: CGSize
    {
        var contentSize = super.intrinsicContentSize
        contentSize.width += CGFloat(2) + CGFloat(4)
		
		return (contentSize)
    }
}
