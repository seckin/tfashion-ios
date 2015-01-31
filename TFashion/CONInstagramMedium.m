//
//  CONInstagramFeed.m
//  TFashion
//
//  Created by Utku Sakil on 1/30/15.
//
//

#import "CONInstagramMedium.h"

@implementation CONInstagramMedium

#pragma mark - <MTLJSONSerializing>

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"standardResolutionImageURL": @"data.images.standard_resolution.url"
             };
}

+ (NSValueTransformer *)standardResolutionImageURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
