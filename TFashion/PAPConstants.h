//
//  PAPConstants.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/25/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

typedef enum {
	PAPHomeTabBarItemIndex = 0,
	PAPActivityTabBarItemIndex = 1,
	PAPEmptyTabBarItemIndex = 2,
    PAPProfileTabBarItemIndex = 3
} PAPTabBarControllerViewControllerIndex;

#pragma mark - NSUserDefaults
extern NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kPAPUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Launch URLs

extern NSString *const kPAPLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const PAPUtilityUserFollowingChangedNotification;
extern NSString *const PAPUtilityUserLikedUnlikedClothCallbackFinishedNotification;
extern NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserDeletedPhotoNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedClothNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserCommentedOnClothNotification;


#pragma mark - User Info Keys
extern NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedClothNotificationUserInfoLikedKey;
extern NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey;


#pragma mark - Installation Class

// Field keys
extern NSString *const kPAPInstallationUserKey;


#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kPAPActivityClassKey;

#pragma mark - PFObject Cloth Class
// Class key
extern NSString *const kPAPClothClassKey;

// Field key
extern NSString *const kPAPClothPhotoKey;

#pragma mark - PFObject ClothPiece Class
// Class key
extern NSString *const kPAPClothPieceClassKey;

// Field key
extern NSString *const kPAPClothPieceClothKey;

#pragma mark - PFObject Report Class
extern NSString *const kPAPReportClassKey;

// Field keys
extern NSString *const kPAPReportPhotoKey;
extern NSString *const kPAPReportToUserKey;
extern NSString *const kPAPReportFromUserKey;


// Field keys
extern NSString *const kPAPActivityTypeKey;
extern NSString *const kPAPActivityFromUserKey;
extern NSString *const kPAPActivityClothKey;
extern NSString *const kPAPActivityToUserKey;
extern NSString *const kPAPActivityContentKey;
extern NSString *const kPAPActivityPhotoKey;
extern NSString *const kPAPActivityCommentKey;

extern NSString *const kPAPTagTextKey;
extern NSString *const kPAPTagTaggedObjectKey;
extern NSString *const kPAPTagTypeKey;
extern NSString *const kPAPTagActivityKey;

// Type values
extern NSString *const kPAPActivityTypeLike;
extern NSString *const kPAPActivityTypeFollow;
extern NSString *const kPAPActivityTypeComment;
extern NSString *const kPAPActivityTypeJoined;
extern NSString *const kPAPActivityTypeMention;

extern NSString *const kPAPNotificationSettingTypeOff;
extern NSString *const kPAPNotificationSettingTypeFromPeopleIFollow;
extern NSString *const kPAPNotificationSettingTypeFromEveryone;


#pragma mark - PFObject User Class
// Field keys
extern NSString *const kPAPUserDisplayNameKey;
extern NSString *const kPAPUserFacebookIDKey;
extern NSString *const kPAPUserPhotoIDKey;
extern NSString *const kPAPUserProfilePicSmallKey;
extern NSString *const kPAPUserProfilePicMediumKey;
extern NSString *const kPAPUserFacebookFriendsKey;
extern NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey;
extern NSString *const kPAPUserEmailKey;
extern NSString *const kPAPUserLocationKey;
extern NSString *const kPAPUserPhoneNumberKey;
extern NSString *const kPAPUserObjectIdKey;
extern NSString *const kPAPUserAutoFollowKey;
extern NSString *const kPAPUserTwitterIDKey;
extern NSString *const kPAPUserInstagramIDKey;
extern NSString *const kPAPUserTumblrIDKey;
extern NSString *const kPAPUserDidUpdateUsernameKey;
extern NSString *const kPAPUserNumPhotosKey;


#pragma mark - PFObject Photo Class
// Class key
extern NSString *const kPAPPhotoClassKey;

// Field keys
extern NSString *const kPAPPhotoPictureKey;
extern NSString *const kPAPPhotoThumbnailKey;
extern NSString *const kPAPPhotoUserKey;
extern NSString *const kPAPPhotoOpenGraphIDKey;
extern NSString *const kPAPPhotoCaptionKey;


#pragma mark - Cached Photo Attributes
// keys

extern NSString *const kPAPPhotoAttributesClothesKey;

#pragma mark - Cached Cloth Attributes
// keys
extern NSString *const kPAPClothAttributesClothPiecesKey;
extern NSString *const kPAPClothAttributesIsLikedByCurrentUserKey;
extern NSString *const kPAPClothAttributesLikeCountKey;
extern NSString *const kPAPClothAttributesLikersKey;
extern NSString *const kPAPClothAttributesCommentCountKey;
extern NSString *const kPAPClothAttributesCommentersKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kPAPUserAttributesPhotoCountKey;
extern NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey;


#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kPAPPushPayloadPayloadTypeKey;
extern NSString *const kPAPPushPayloadPayloadTypeActivityKey;

extern NSString *const kPAPPushPayloadActivityTypeKey;
extern NSString *const kPAPPushPayloadActivityLikeKey;
extern NSString *const kPAPPushPayloadActivityCommentKey;
extern NSString *const kPAPPushPayloadActivityFollowKey;

extern NSString *const kPAPPushPayloadFromUserObjectIdKey;
extern NSString *const kPAPPushPayloadToUserObjectIdKey;
extern NSString *const kPAPPushPayloadPhotoObjectIdKey;
extern NSString *const kPAPPushPayloadCommentObjectIdKey;

#pragma mark - User Defaults

extern NSString *const kDidUserCompletedIntro;

#pragma mark - Social Account Types

extern NSString *const kSocialAccountTypeTwitter;
extern NSString *const kSocialAccountTypeInstagram;
extern NSString *const kSocialAccountTypeTumblr;
extern NSString *const kSocialAccountTypeFacebook;
