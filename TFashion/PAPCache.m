//
//  PAPCache.m
//  Anypic
//
//  Created by Héctor Ramos on 5/31/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPCache.h"

@interface PAPCache()

@property (nonatomic, strong) NSCache *cache;
- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo;
@end

@implementation PAPCache
@synthesize cache;

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - PAPCache

- (void)clear {
    [self.cache removeAllObjects];
}

- (void)setAttributesForCloth:(PFObject *)cloth likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:likedByCurrentUser],kPAPClothAttributesIsLikedByCurrentUserKey,
                                      @([likers count]),kPAPClothAttributesLikeCountKey,
                                      likers,kPAPClothAttributesLikersKey,
                                      @([commenters count]),kPAPClothAttributesCommentCountKey,
                                      commenters,kPAPClothAttributesCommentersKey,
                                      nil];
    [self setAttributes:attributes forCloth:cloth];
}

- (void)setClothesForPhoto:(PFObject *)photo clothes:(NSArray *)clothes {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    clothes,kPAPPhotoAttributesClothesKey,
                                    nil];

    [self setAttributes:attributes forPhoto:photo];
}

- (void)setClothPiecesForCloth:(PFObject *)cloth clothPieces:(NSArray *)clothPieces {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
            clothPieces,kPAPClothAttributesClothPiecesKey,
                    nil];

    [self setAttributes:attributes forCloth:cloth];
}

- (NSArray *)clothPiecesForCloth:(PFObject *)cloth {
    NSDictionary *attributes = [self attributesForCloth:cloth];
    if (attributes) {
        return [attributes objectForKey:kPAPClothAttributesClothPiecesKey];
    }

    return [NSArray array];
}


- (NSDictionary *)attributesForPhoto:(PFObject *)photo {
    NSString *key = [self keyForPhoto:photo];
    return [self.cache objectForKey:key];
}

- (NSDictionary *)attributesForCloth:(PFObject *)cloth {
    NSString *key = [self keyForCloth:cloth];
    return [self.cache objectForKey:key];
}

- (NSNumber *)likeCountForCloth:(PFObject *)cloth {
    NSDictionary *attributes = [self attributesForCloth:cloth];
    if (attributes) {
        return [attributes objectForKey:kPAPClothAttributesLikeCountKey];
    }

    return [NSNumber numberWithInt:0];
}

- (NSNumber *)commentCountForCloth:(PFObject *)cloth {[self keyForCloth:cloth];
    NSDictionary *attributes = [self attributesForCloth:cloth];
    if (attributes) {
        return [attributes objectForKey:kPAPClothAttributesCommentCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSArray *)likersForCloth:(PFObject *)cloth {
    NSDictionary *attributes = [self attributesForCloth:cloth];
    if (attributes) {
        return [attributes objectForKey:kPAPClothAttributesLikersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)commentersForCloth:(PFObject *)cloth {
    NSDictionary *attributes = [self attributesForCloth:cloth];
    if (attributes) {
        return [attributes objectForKey:kPAPClothAttributesCommentersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)clothesForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kPAPPhotoAttributesClothesKey];
    }

    return [NSArray array];
}

- (void)setClothIsLikedByCurrentUser:(PFObject *)cloth liked:(BOOL)liked {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForCloth:cloth]];
    [attributes setObject:[NSNumber numberWithBool:liked] forKey:kPAPClothAttributesIsLikedByCurrentUserKey];
    [self setAttributes:attributes forCloth:cloth];
}

- (BOOL)isClothLikedByCurrentUser:(PFObject *)cloth {
    NSDictionary *attributes = [self attributesForCloth:cloth];
    if (attributes) {
        return [[attributes objectForKey:kPAPClothAttributesIsLikedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (void)incrementLikerCountForCloth:(PFObject *)cloth {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForCloth:cloth] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForCloth:cloth]];
    [attributes setObject:likerCount forKey:kPAPClothAttributesLikeCountKey];
    [self setAttributes:attributes forCloth:cloth];
}

- (void)decrementLikerCountForCloth:(PFObject *)cloth {
    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForCloth:cloth] intValue] - 1];
    if ([likerCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForCloth:cloth]];
    [attributes setObject:likerCount forKey:kPAPClothAttributesLikeCountKey];
    [self setAttributes:attributes forCloth:cloth];
}

- (void)incrementCommentCountForCloth:(PFObject *)cloth {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForCloth:cloth] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForCloth:cloth]];
    [attributes setObject:commentCount forKey:kPAPClothAttributesCommentCountKey];
    [self setAttributes:attributes forCloth:cloth];
}

- (void)decrementCommentCountForCloth:(PFObject *)cloth {
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForCloth:cloth] intValue] - 1];
    if ([commentCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForCloth:cloth]];
    [attributes setObject:commentCount forKey:kPAPClothAttributesCommentCountKey];
    [self setAttributes:attributes forCloth:cloth];
}

- (void)setAttributesForUser:(PFUser *)user photoCount:(NSNumber *)count followedByCurrentUser:(BOOL)following {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                count,kPAPUserAttributesPhotoCountKey,
                                [NSNumber numberWithBool:following],kPAPUserAttributesIsFollowedByCurrentUserKey,
                                nil];
    [self setAttributes:attributes forUser:user];
}

- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSNumber *)photoCountForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *photoCount = [attributes objectForKey:kPAPUserAttributesPhotoCountKey];
        if (photoCount) {
            return photoCount;
        }
    }
    
    return [NSNumber numberWithInt:0];
}

- (BOOL)followStatusForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *followStatus = [attributes objectForKey:kPAPUserAttributesIsFollowedByCurrentUserKey];
        if (followStatus) {
            return [followStatus boolValue];
        }
    }

    return NO;
}

- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:kPAPUserAttributesPhotoCountKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFollowStatus:(BOOL)following user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:[NSNumber numberWithBool:following] forKey:kPAPUserAttributesIsFollowedByCurrentUserKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFacebookFriends:(NSArray *)friends {
    NSString *key = kPAPUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)facebookFriends {
    NSString *key = kPAPUserDefaultsCacheFacebookFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }

    return friends;
}


#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo {
    NSString *key = [self keyForPhoto:photo];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];    
}

- (void)setAttributes:(NSDictionary *)attributes forCloth:(PFObject *)cloth {
    NSString *key = [self keyForCloth:cloth];
    [self.cache setObject:attributes forKey:key];
}

- (NSString *)keyForPhoto:(PFObject *)photo {
    return [NSString stringWithFormat:@"photo_%@", [photo objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

- (NSString *)keyForCloth:(PFObject *)cloth {
    return [NSString stringWithFormat:@"cloth_%@", [cloth objectId]];
}

+(NSString *)getKeyForClothesForPhoto:(PFObject *)photo {
    return [NSString stringWithFormat:@"clothes_for_photo_%@", [photo objectId]];
}

+(NSString *)getKeyForClothPiecesForCloth:(PFObject *)cloth {
    return [NSString stringWithFormat:@"cloth_pieces_for_cloth_%@", [cloth objectId]];
}

@end
