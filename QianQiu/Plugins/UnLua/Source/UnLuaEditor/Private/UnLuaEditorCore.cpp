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

#include "UnLuaEditorCore.h"
#include "UnLuaInterface.h"
#include "UnLuaPrivate.h"
#include "Engine/Blueprint.h"
#include "Blueprint/UserWidget.h"


/**
* Whether the UFunction is overridable
*/
bool IsOverridable(UFunction* Function)
{
    check(Function);

	static const uint32 FlagMask = FUNC_Native | FUNC_Event | FUNC_Net;
	static const uint32 FlagResult = FUNC_Native | FUNC_Event;
	return Function->HasAnyFunctionFlags(FUNC_BlueprintEvent) || (Function->FunctionFlags & FlagMask) == FlagResult;
}

/**
* Get all UFUNCTIONs that can be overrode
*/
void GetOverridableFunctions(UClass* Class, TMap<FName, UFunction*>& Functions)
{
    if (!Class)
    {
        return;
    }

    // all 'BlueprintEvent'
    for (TFieldIterator<UFunction> It(Class, EFieldIteratorFlags::IncludeSuper, EFieldIteratorFlags::ExcludeDeprecated, EFieldIteratorFlags::IncludeInterfaces); It; ++It)
    {
        UFunction* Function = *It;
        if (IsOverridable(Function))
        {
            FName FuncName = Function->GetFName();
            UFunction** FuncPtr = Functions.Find(FuncName);
            if (!FuncPtr)
            {
                Functions.Add(FuncName, Function);
            }
        }
    }

    // all 'RepNotifyFunc'
    for (int32 i = 0; i < Class->ClassReps.Num(); ++i)
    {
        FProperty* Property = Class->ClassReps[i].Property;
        if (Property->HasAnyPropertyFlags(CPF_RepNotify))
        {
            UFunction* Function = Class->FindFunctionByName(Property->RepNotifyFunc);
            if (Function)
            {
                UFunction** FuncPtr = Functions.Find(Property->RepNotifyFunc);
                if (!FuncPtr)
                {
                    Functions.Add(Property->RepNotifyFunc, Function);
                }
            }
        }
    }
}

ELuaBindingStatus GetBindingStatus(const UBlueprint* Blueprint)
{
    if (!Blueprint)
        return ELuaBindingStatus::NotBound;

    const auto Target = Blueprint->GeneratedClass;

    if (!IsValid(Target))
        return ELuaBindingStatus::NotBound;

    if (!Target->ImplementsInterface(UUnLuaInterface::StaticClass()))
        return ELuaBindingStatus::NotBound;

    const auto Func = Target->FindFunctionByName(FName("GetModuleName"));
    if (!IsValid(Func))
        return ELuaBindingStatus::NotBound;

    FString ModuleName;
    auto DefaultObject = Target->GetDefaultObject();
    DefaultObject->UObject::ProcessEvent(Func, &ModuleName);

    const auto RelativePath = ModuleName.Replace(TEXT("."), TEXT("/")) + TEXT(".lua");
    const auto FullPath = GLuaSrcFullPath + "/" + RelativePath;
    if (!FPaths::FileExists(FullPath))
        return ELuaBindingStatus::BoundButInvalid;

    return ELuaBindingStatus::Bound;
}
