// Fill out your copyright notice in the Description page of Project Settings.


#include "MuBPFunction.h"

#include "Blueprint/UserWidget.h"
#include "Engine/GameEngine.h"

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

FVector2D UMuBPFunction::GetWidgetAbsolutePosition(const UWidget* Widget)
{
    if (!Widget)
    {
        return FVector2D::ZeroVector;
    }
    return Widget->GetTickSpaceGeometry().GetAbsolutePosition();
}

FVector2D UMuBPFunction::GetMonitorBestDisplaySize()
{
    FVector2D Size = FVector2D::ZeroVector;
#if PLATFORM_WINDOWS

    const UGameEngine* GameEngine = Cast<UGameEngine>(GEngine);
    if (!GameEngine)
    {
        return Size;
    }
    const auto ViewportWidget = GameEngine->GetGameViewportWidget();
    const TSharedPtr<SWindow> WindowToResize = FSlateApplication::Get().FindWidgetWindow( ViewportWidget.ToSharedRef());

    if( WindowToResize.IsValid() )
    {
        const FVector2D OldWindowPos = WindowToResize->GetPositionInScreen();
        const FVector2D OldWindowSize = WindowToResize->GetClientSizeInScreen();
        const EWindowMode::Type OldWindowMode = WindowToResize->GetWindowMode();

        const FSlateRect BestWorkArea = FSlateApplication::Get().GetWorkArea(FSlateRect::FromPointAndExtent(OldWindowPos, OldWindowSize));
        Size = BestWorkArea.GetSize();
		
        FDisplayMetrics DisplayMetrics;
        FSlateApplication::Get().GetInitialDisplayMetrics(DisplayMetrics);

        // if (DisplayMetrics.MonitorInfo.Num() > 0)
        // {
        //     // Try to find the monitor that the viewport belongs to based on BestWorkArea.
        //     // For widowed fullscreen and fullscreen modes it should be top left position of one of monitors.
        //     FPlatformRect DisplayRect = DisplayMetrics.MonitorInfo[0].DisplayRect;
        //
        //     int32 NativeWidth = DisplayMetrics.MonitorInfo[0].NativeWidth;
        //     int32 NativeHeight = DisplayMetrics.MonitorInfo[0].NativeHeight;
        //     for (int32 Index = 1; Index < DisplayMetrics.MonitorInfo.Num(); ++Index)
        //     {
        //         const FMonitorInfo& MonitorInfo = DisplayMetrics.MonitorInfo[Index];
        //         if (BestWorkArea.GetTopLeft() == FVector2D(MonitorInfo.WorkArea.Left, MonitorInfo.WorkArea.Top))
        //         {
        //             NativeWidth = DisplayMetrics.MonitorInfo[Index].NativeWidth;
        //             NativeHeight = DisplayMetrics.MonitorInfo[Index].NativeHeight;
        //         }
        //     }
        //     FullscreenBestSize.X = NativeWidth;
        //     FullscreenBestSize.Y = NativeHeight;
        // }
        // else
        // {
        //     FullscreenBestSize.X = DisplayMetrics.PrimaryDisplayWidth;
        //     FullscreenBestSize.Y = DisplayMetrics.PrimaryDisplayHeight;
        // }
    }
    
#endif
    return Size;
}
