//
//  MyCollectionViewLayout.m
//  ExpandingCollectionView2
//
//  Created by Quang Tran on 5/24/17.
//  Copyright © 2017 Quang Tran. All rights reserved.
//

#import "CardCollectionViewLayout.h"

@interface CardCollectionViewLayout()

@property(nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *cache;
@property(nonatomic, readonly) NSInteger numberOfItems;
@property(nonatomic, readonly) CGFloat cellWidth;
@property(nonatomic, readonly) CGFloat cellHeight;
@property(nonatomic, readonly) CGFloat collectionViewWidth;
@property(nonatomic, readonly) CGFloat collectionViewHeight;

@end

@implementation CardCollectionViewLayout

const CGFloat kNonFeaturedScale = 0.8;

-(NSInteger)numberOfItems {
  return [self.collectionView numberOfItemsInSection:0];
}

-(CGFloat)cellWidth {
  return 200;
}

-(CGFloat)cellHeight {
  return self.collectionView.bounds.size.height;
}

-(CGFloat)collectionViewWidth {
  return self.collectionView.bounds.size.width;
}

-(CGFloat)collectionViewHeight {
  return self.collectionView.bounds.size.height;
}

-(CGSize)collectionViewContentSize {
  return CGSizeMake(self.cellWidth * self.numberOfItems + self.collectionViewWidth - self.cellWidth,
                    self.cellHeight);
}

-(NSInteger)featuredItemIndex {
  return (NSInteger)(self.collectionView.contentOffset.x / self.cellWidth);
}

-(CGFloat)nextItemPercentageOffset {
  return self.collectionView.contentOffset.x / self.cellWidth - [self featuredItemIndex];
}

-(void)prepareLayout {
  [super prepareLayout];
  
  if (self.cache == nil) {
    self.cache = [NSMutableArray new];
  }
  else {
    [self.cache removeAllObjects];
  }
  
  CGFloat paddingLeft = (self.collectionViewWidth - self.cellWidth) / 2;
  
  CGFloat cellWidth = 200;
  CGFloat cellHeight = self.collectionView.bounds.size.height;
  
  for (int i = 0; i < self.numberOfItems; i++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(i * cellWidth + paddingLeft,
                                  0,
                                  cellWidth,
                                  cellHeight);

    if (i == [self featuredItemIndex]) {
      CGFloat scale = 1 - ((1 - kNonFeaturedScale) * [self nextItemPercentageOffset]);
      attributes.transform3D = CATransform3DMakeScale(scale, scale, 1);
    }
    else if (i == [self featuredItemIndex] + 1) {
      CGFloat scale = kNonFeaturedScale + ((1 - kNonFeaturedScale) * [self nextItemPercentageOffset]);
      attributes.transform3D = CATransform3DMakeScale(scale, scale, 1);
    }
    else {
      CGFloat scale = kNonFeaturedScale;
      attributes.transform3D = CATransform3DMakeScale(scale, scale, 1);
    }
    
    [self.cache addObject:attributes];
  }
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes = [NSMutableArray new];
  for (UICollectionViewLayoutAttributes *attributes in self.cache) {
    if (CGRectIntersectsRect(attributes.frame, rect)) {
      [layoutAttributes addObject:attributes];
    }
  }
  return layoutAttributes;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
  NSInteger itemIndex = roundf(proposedContentOffset.x / self.cellWidth);
  CGFloat xOffset = itemIndex * self.cellWidth;
  return CGPointMake(xOffset, 0);
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  return YES;
}

@end
