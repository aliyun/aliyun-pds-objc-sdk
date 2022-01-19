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

SpecBegin(StringCategory)

describe(@"parse", ^{
    it(@"hex to decimal", ^{
        NSString *correct = @"4487330454159893554";
        NSString *converted = [@"0x3E463345EDFE2432" pds_hexToDecimal];
        expect(converted).equal(correct);
        converted = [@"3E463345EDFE2432" pds_hexToDecimal];
        expect(converted).equal(correct);
        converted = [@"#3E463345EDFE2432" pds_hexToDecimal];
        expect(converted).equal(correct);
    });
});

SpecEnd

