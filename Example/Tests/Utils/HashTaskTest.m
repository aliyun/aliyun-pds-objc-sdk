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

// https://github.com/Specta/Specta

@import PDS_SDK;
#import "PDSTestConfig+Hash.h"

PDSTestConfig *testConfig = nil;

SpecBegin(HashTask)
beforeAll(^{
    testConfig = [[PDSTestConfig alloc] init];
});

describe(@"000init", ^{
    it(@"config validate", ^{
        expect(testConfig.hashFilePath).toNot.beNil();
        expect(testConfig.hashFileData).toNot.beNil();
        expect(testConfig.md5HashValue).toNot.beNil();
        expect(testConfig.sha1HashValue).toNot.beNil();
        expect(testConfig.crc32HashValue).toNot.beNil();
        expect(testConfig.crc64HashValue).toNot.beNil();
    });
});

describe(@"001md5", ^{
    it(@"data", ^{
        NSString *result = [PDSFileHash md5HashOfData:testConfig.hashFileData];
        expect([result lowercaseString]).equal(testConfig.md5HashValue);
    });
    it(@"path", ^{
        NSString *result = [PDSFileHash md5HashOfFileAtPath:testConfig.hashFilePath];
        expect([result lowercaseString]).equal(testConfig.md5HashValue);
    });
});

describe(@"002sha1", ^{
    it(@"data", ^{
        NSString *result = [PDSFileHash sha1HashOfData:testConfig.hashFileData];
        expect([result lowercaseString]).equal(testConfig.sha1HashValue);
    });
    it(@"path", ^{
        NSString *result = [PDSFileHash sha1HashOfFileAtPath:testConfig.hashFilePath];
        expect([result lowercaseString]).equal(testConfig.sha1HashValue);
    });
});

describe(@"003crc32", ^{
    it(@"data", ^{
        NSString *result = [PDSFileHash crc32HashOfData:testConfig.hashFileData];
        expect([result lowercaseString]).equal(testConfig.crc32HashValue);
    });
    it(@"path", ^{
        NSString *result = [PDSFileHash crc32HashOfFileAtPath:testConfig.hashFilePath];
        expect([result lowercaseString]).equal(testConfig.crc32HashValue);
    });
});

describe(@"004crc64", ^{
    it(@"data", ^{
        NSString *result = [PDSFileHash crc64HashOfData:testConfig.hashFileData];
        expect([result lowercaseString]).equal(testConfig.crc64HashValue);
    });
    it(@"path", ^{
        NSString *result = [PDSFileHash crc64HashOfFileAtPath:testConfig.hashFilePath];
        expect([result lowercaseString]).equal(testConfig.crc64HashValue);
    });
});


SpecEnd

