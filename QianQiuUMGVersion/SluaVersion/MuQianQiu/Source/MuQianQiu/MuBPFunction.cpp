// Fill out your copyright notice in the Description page of Project Settings.


#include "MuBPFunction.h"

#include "Blueprint/UserWidget.h"

UGameInstance* UMuBPFunction::GameInstance = nullptr;

void UMuBPFunction::SetGameInstance(UGameInstance* InGameInstance)
{
    GameInstance = InGameInstance;
}

void UMuBPFunction::Test(const FString& String)
{
    UE_LOG(LogTemp, Warning, TEXT("Test: %s"), *String);
}

UTexture2D* UMuBPFunction::LoadTexture2D(FString CardType, FString TexturePath)
{
    FString Path = TEXT("/Game/Texture") / CardType / TexturePath;
    Path = "Texture2D'" + Path + "." + TexturePath + "'";
    UTexture2D* Texture = LoadObject<UTexture2D>(nullptr, *Path);
    if (Texture == nullptr)
    {
        UE_LOG(LogTemp, Warning, TEXT("LoadTexture2D failed: %s"), *Path);
        return Texture;
    }
    return Texture;
}

UUserWidget* UMuBPFunction::CreateUserWidget(const FString& WidgetPath)
{
    FString Path = TEXT("/Game/UserWidget") / WidgetPath;
    Path = "WidgetBlueprint'" + Path + "." + WidgetPath + "_C'";
    UClass* WidgetClass = LoadClass<UUserWidget>(nullptr, *Path);
    if (WidgetClass == nullptr)
    {
        UE_LOG(LogTemp, Warning, TEXT("CreateUserWidget failed: %s"), *Path);
        return nullptr;
    }
    UWorld* World = GEngine->GetWorld();
    if (!World)
    {
        if (GameInstance)
        {
            World = GameInstance->GetWorld();
            if (!World)
            {
                UE_LOG(LogTemp, Warning, TEXT("CreateUserWidget failed: World is nullptr"));
                return nullptr;
            }
        }
    }
    UUserWidget* Widget = CreateWidget<UUserWidget>(World, WidgetClass);
    if (Widget == nullptr)
    {
        UE_LOG(LogTemp, Warning, TEXT("CreateUserWidget failed: %s"), *Path);
        return nullptr;
    }
    return Widget;
}
