// /*
// * Copyright 2009-2021 Alibaba Cloud All rights reserved.
// *
// * Licensed under the Apache License, Version 2.0 (the "License");
// * you may not use this file except in compliance with the License.
// * You may obtain a copy of the License at
// *
// *      http://www.apache.org/licenses/LICENSE-2.0
// *
// * Unless required by applicable law or agreed to in writing, software
// * distributed under the License is distributed on an "AS IS" BASIS,
// * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// * See the License for the specific language governing permissions and
// * limitations under the License.
// *

#import "PDSTestConfig.h"
@import Photos;
@import PDS_SDK;

SpecBegin(ExportPhoto)
    __block PDSInternalExportPhotoTask *exportPhotoTask = nil;
    describe(@"001 photo export", ^{
        it(@"001 normal export", ^{
            waitUntilTimeout(1000, ^(DoneCallback done) {
                PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
                fetchOptions.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
                PHAsset *asset = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions].firstObject;
                expect(asset).toNot.beNil();
                exportPhotoTask = [[PDSInternalExportPhotoTask alloc] initWithPhotoLocalIdentifier:asset.localIdentifier];
                [exportPhotoTask setResponseBlock:^(BOOL success, NSString *localPath,NSString *fileName, NSError *error) {
                    expect(success).beTruthy;
                    expect(localPath).toNot.beNil();
                    expect(fileName).toNot.beNil();
                    expect(error).to.beNil();
                    done();
                }];
                [exportPhotoTask start];
            });
        });
    });

SpecEnd
