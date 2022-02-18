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

#include "UnLuaEditorCommands.h"

#define LOCTEXT_NAMESPACE "FUnLuaEditorCommands"

void FUnLuaEditorCommands::RegisterCommands()
{
    UI_COMMAND(CreateLuaTemplate, "Create Lua Template", "Create lua template file", EUserInterfaceActionType::Button, FInputChord());
    UI_COMMAND(CopyAsRelativePath, "Copy as Relative Path", "Copy module name as relative path.", EUserInterfaceActionType::Button, FInputChord());
    UI_COMMAND(BindToLua, "Bind", "Implement UnLuaInterface", EUserInterfaceActionType::Button, FInputChord());
    UI_COMMAND(UnbindFromLua, "Unbind", "Remove the implementation of UnLuaInterface", EUserInterfaceActionType::Button, FInputChord());
    UI_COMMAND(HotfixLua, "Lua Hotfix", "Hotfix lua", EUserInterfaceActionType::Button, FInputChord(TEXT("L"), false, true, false, false));
}

#undef LOCTEXT_NAMESPACE
