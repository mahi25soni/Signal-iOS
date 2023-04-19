//
// Copyright 2019 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSBroadcastMediaMessageJobRecord.h"

NS_ASSUME_NONNULL_BEGIN

@implementation OWSBroadcastMediaMessageJobRecord

+ (NSString *)defaultLabel
{
    return @"BroadcastMediaMessage";
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    return [super initWithCoder:coder];
}

- (instancetype)initWithAttachmentIdMap:(NSDictionary<NSString *, NSArray<NSString *> *> *)attachmentIdMap
                  unsavedMessagesToSend:(nullable NSArray<TSOutgoingMessage *> *)unsavedMessagesToSend
                                  label:(NSString *)label
{
    self = [super initWithLabel:label];
    if (!self) {
        return self;
    }

    _attachmentIdMap = attachmentIdMap;
    _unsavedMessagesToSend = unsavedMessagesToSend;

    return self;
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
      exclusiveProcessIdentifier:(nullable NSString *)exclusiveProcessIdentifier
                    failureCount:(NSUInteger)failureCount
                           label:(NSString *)label
                          sortId:(unsigned long long)sortId
                          status:(SSKJobRecordStatus)status
                 attachmentIdMap:(NSDictionary<NSString *,NSArray<NSString *> *> *)attachmentIdMap
           unsavedMessagesToSend:(nullable NSArray<TSOutgoingMessage *> *)unsavedMessagesToSend
{
    self = [super initWithGrdbId:grdbId
                        uniqueId:uniqueId
        exclusiveProcessIdentifier:exclusiveProcessIdentifier
                      failureCount:failureCount
                             label:label
                            sortId:sortId
                            status:status];

    if (!self) {
        return self;
    }

    _attachmentIdMap = attachmentIdMap;
    _unsavedMessagesToSend = unsavedMessagesToSend;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

@end

NS_ASSUME_NONNULL_END