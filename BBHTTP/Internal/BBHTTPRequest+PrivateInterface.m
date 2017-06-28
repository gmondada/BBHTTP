//
// Copyright 2013 BiasedBit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

//
//  Created by Bruno de Carvalho - @biasedbit / http://biasedbit.com
//  Copyright (c) 2013 BiasedBit. All rights reserved.
//

#import "BBHTTPRequest+PrivateInterface.h"

#import "BBHTTPUtils.h"



#pragma mark -

@implementation BBHTTPRequest (PrivateInterface)


#pragma mark Events

- (BOOL)executionStarted
{
    if ([self hasFinished]) return NO;

    _startTimestamp = BBHTTPCurrentTimeMillis();
    if (self.startBlock != nil) {
        dispatch_async(self.callbackQueue, ^{
            self.startBlock();

            self.startBlock = nil;
        });
    }

    return YES;
}

- (BOOL)executionFailedWithFinalResponse:(BBHTTPResponse*)response error:(NSError*)error
{
    if ([self hasFinished]) return NO;

    _endTimestamp = BBHTTPCurrentTimeMillis();
    _error = error;
    _response = response;

    if (self.finishBlock != nil) {
        dispatch_async(self.callbackQueue, ^{
            self.finishBlock(self);

            self.uploadProgressBlock = nil;
            self.downloadProgressBlock = nil;
            self.finishBlock = nil;
        });
    }
    
    return YES;
}

- (BOOL)uploadProgressedToCurrent:(unsigned long long)current ofTotal:(unsigned long long)total
{
    if ([self hasFinished]) return NO;

    _sentBytes = current;

    if (self.uploadProgressBlock != nil) {
        dispatch_async(self.callbackQueue, ^{
            self.uploadProgressBlock(current, total);
        });
    }

    return YES;
}

- (BOOL)downloadProgressedToCurrent:(unsigned long long)current ofTotal:(unsigned long long)total
{
    if ([self hasFinished]) return NO;

    _receivedBytes = current;

    if (self.downloadProgressBlock != nil) {
        dispatch_async(self.callbackQueue, ^{
            self.downloadProgressBlock(current, total);
        });
    }

    return YES;
}

@end
