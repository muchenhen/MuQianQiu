// Tencent is pleased to support the open source community by making UnLua available.
// 
// Copyright (C) 2019 THL A29 Limited, a Tencent company. All rights reserved.
//
// Licensed under the MIT License (the "License"); 
// you may not use this file except in compliance with the License. You may obtain a copy of the License at
//
// http://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, 
// software distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
// See the License for the specific language governing permissions and limitations under the License.

#include "LuaContext.h"
#include "UnLuaTestCommon.h"
#include "Engine/SimpleConstructionScript.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

struct FUnLuaTest_Issue288 : FUnLuaTestBase
{
    virtual bool InstantTest() override
    {
        return true;
    }

    virtual bool SetUp() override
    {
        FUnLuaTestBase::SetUp();

        const char* Chunk1 = "\
		local UMGClass = UE.UClass.Load('/Game/Tests/Regression/Issue288/UnLuaTestUMG_Issue288.UnLuaTestUMG_Issue288_C')\
		G_UMG = NewObject(UMGClass)\
		";
        UnLua::RunChunk(L, Chunk1);

        auto Texture2D = FindObject<UTexture2D>(nullptr, TEXT("/Game/FPWeapon/Textures/UE4_LOGO_CARD.UE4_LOGO_CARD"));
        RUNNER_TEST_NOT_NULL(Texture2D);

        const char* Chunk2 = "\
		G_UMG:Release()\
		G_UMG = nil\
		";
        UnLua::RunChunk(L, Chunk2);


        lua_gc(L, LUA_GCCOLLECT, 0);
        CollectGarbage(RF_NoFlags, true);

        Texture2D = FindObject<UTexture2D>(nullptr, TEXT("/Game/FPWeapon/Textures/UE4_LOGO_CARD.UE4_LOGO_CARD"));
        if (Texture2D)
        {
#if ENGINE_MAJOR_VERSION > 4 || (ENGINE_MAJOR_VERSION == 4 && ENGINE_MINOR_VERSION >= 26)
            FReferenceChainSearch Search(Texture2D, EReferenceChainSearchMode::PrintAllResults | EReferenceChainSearchMode::FullChain);
#else
			FReferenceChainSearch Search(Texture2D, EReferenceChainSearchMode::PrintAllResults);
#endif
        }
        RUNNER_TEST_NULL(Texture2D);

        return true;
    }
};

IMPLEMENT_UNLUA_INSTANT_TEST(FUnLuaTest_Issue288, TEXT("UnLua.Regression.Issue288 UMG里Image用到的Texture内存泄漏"))

#endif //WITH_DEV_AUTOMATION_TESTS
