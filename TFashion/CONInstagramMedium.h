//
//  CONInstagramFeed.h
//  TFashion
//
//  Created by Utku Sakil on 1/30/15.
//
//

#import <Mantle/Mantle.h>

@interface CONInstagramMedium : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSURL *standardResolutionImageURL;

@end
