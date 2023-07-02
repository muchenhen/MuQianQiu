// Fill out your copyright notice in the Description page of Project Settings.


#include "MuQianQiuGameInstance.h"

#include "MuBPFunction.h"

// read file content
static uint8* ReadFile(IPlatformFile& PlatformFile, FString path, uint32& len)
{
    IFileHandle* FileHandle = PlatformFile.OpenRead(*path);
    if (FileHandle)
    {
        len = static_cast<uint32>(FileHandle->Size());
        uint8* buf = new uint8[len];

        FileHandle->Read(buf, len);

        // Close the file again
        delete FileHandle;

        return buf;
    }

    return nullptr;
}

UMuQianQiuGameInstance::UMuQianQiuGameInstance() :
    State(nullptr)
{
    if (!HasAnyFlags(RF_ClassDefaultObject | RF_ArchetypeObject))
    {
        CreateLuaState();
    }
}

void UMuQianQiuGameInstance::Init()
{
    Super::Init();
}

void UMuQianQiuGameInstance::Shutdown()
{
    CloseLuaState();

    Super::Shutdown();
}

static int32 PrintLog(NS_SLUA::lua_State* L)
{
    FString str;
    size_t len;
    const char* s = luaL_tolstring(L, 1, &len);
    if (s) str += UTF8_TO_TCHAR(s);
    NS_SLUA::Log::Log("PrintLog %s", TCHAR_TO_UTF8(*str));
    return 0;
}

void UMuQianQiuGameInstance::LuaStateInitCallback(slua::lua_State* L)
{
    lua_pushcfunction(L, PrintLog);
    lua_setglobal(L, "PrintLog");
}

void UMuQianQiuGameInstance::CreateLuaState()
{
    NS_SLUA::LuaState::onInitEvent.AddUObject(this, &UMuQianQiuGameInstance::LuaStateInitCallback);

    CloseLuaState();
    State = new NS_SLUA::LuaState("SLuaMainState", this);
    State->setLoadFileDelegate([](const char* fn, FString& filepath)-> TArray<uint8> {
        IPlatformFile& PlatformFile = FPlatformFileManager::Get().GetPlatformFile();
        FString path = FPaths::ProjectContentDir();
        FString filename = UTF8_TO_TCHAR(fn);
        path /= "Lua";
        path /= filename.Replace(TEXT("."), TEXT("/"));

        TArray<uint8> Content;
        TArray<FString> luaExts = {UTF8_TO_TCHAR(".lua"), UTF8_TO_TCHAR(".luac")};
        for (auto& it : luaExts)
        {
            auto fullPath = path + *it;

            FFileHelper::LoadFileToArray(Content, *fullPath);
            if (Content.Num() > 0)
            {
                filepath = fullPath;
                return MoveTemp(Content);
            }
        }

        return MoveTemp(Content);
    });
    State->init();
    UMuBPFunction::SetGameInstance(this);
}

void UMuQianQiuGameInstance::CloseLuaState()
{
    if (State)
    {
        State->close();
        delete State;
        State = nullptr;
    }
}
