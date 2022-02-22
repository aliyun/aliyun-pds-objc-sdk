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
    it(@"decimalToHex", ^{
        NSString *converted = [@"4487330454159893554" pds_decimalToHexWithCompleteLength:0];
        expect(converted).to.equal(@"3e463345edfe2432");
        converted = [@"487330454159893554" pds_decimalToHexWithCompleteLength:0];
        expect(converted).to.equal(@"6c35877506e2432");
        converted = [@"487330454159893554" pds_decimalToHexWithCompleteLength:16];
        expect(converted).to.equal(@"06c35877506e2432");
    });
});

SpecEnd

