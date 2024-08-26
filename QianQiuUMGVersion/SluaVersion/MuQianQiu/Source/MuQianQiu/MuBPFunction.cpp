// Fill out your copyright notice in the Description page of Project Settings.


#include "MuBPFunction.h"

#include "Blueprint/SlateBlueprintLibrary.h"
#include "Blueprint/UserWidget.h"
#include "Blueprint/WidgetLayoutLibrary.h"
#include "Components/CanvasPanel.h"
#include "Components/CanvasPanelSlot.h"
#include "Components/Overlay.h"
#include "Components/OverlaySlot.h"
#include "Engine/GameEngine.h"
#include "Kismet/GameplayStatics.h"
#include "Kismet/KismetMathLibrary.h"

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
    const TSharedPtr<SWindow> WindowToResize = FSlateApplication::Get().FindWidgetWindow(ViewportWidget.ToSharedRef());

    if (WindowToResize.IsValid())
    {
        const FVector2D OldWindowPos = WindowToResize->GetPositionInScreen();
        const FVector2D OldWindowSize = WindowToResize->GetClientSizeInScreen();

        const FSlateRect BestWorkArea = FSlateApplication::Get().GetWorkArea(FSlateRect::FromPointAndExtent(OldWindowPos, OldWindowSize));
        Size = BestWorkArea.GetSize();

        FDisplayMetrics DisplayMetrics;
        FSlateApplication::Get().GetInitialDisplayMetrics(DisplayMetrics);
    }

#endif
    return Size;
}

USoundBase* UMuBPFunction::LoadSoundBase(const FString& SoundPath)
{
    FString Path = TEXT("/Game/Audio") / SoundPath;
    Path = "SoundWave'" + Path + "." + SoundPath + "'";
    USoundBase* SoundBase = LoadObject<USoundBase>(nullptr, *Path);
    if (SoundBase == nullptr)
    {
        UE_LOG(LogTemp, Warning, TEXT("LoadSoundBase failed: %s"), *Path);
        return SoundBase;
    }
    return SoundBase;
}

FVector2D UMuBPFunction::GetWidgetPositionInViewport(UWidget* Widget)
{
    if (!Widget)
    {
        UE_LOG(LogTemp, Warning, TEXT("Widget is null"));
        return FVector2D::ZeroVector;
    }

    if (GEngine && GEngine->GameViewport)
    {
        FGeometry WidgetGeometry = Widget->GetCachedGeometry();
        FVector2D LocalPosition = FVector2D(0, 0);

        // 转换为视口坐标
        FVector2D PixelPosition, ViewportPosition;
        USlateBlueprintLibrary::LocalToViewport(Widget, WidgetGeometry, LocalPosition, PixelPosition, ViewportPosition);

        return ViewportPosition;
    }

    return FVector2D::ZeroVector;
}


void UMuBPFunction::SetWidgetPositionInViewport(UWidget* Widget, const FVector2D& NewViewportPosition)
{
    if (!Widget)
    {
        UE_LOG(LogTemp, Warning, TEXT("Widget is null"));
        return;
    }

    if (GEngine && GEngine->GameViewport)
    {
        FGeometry WidgetGeometry = Widget->GetCachedGeometry();
        FVector2D LocalPosition = FVector2D(0, 0);
        FVector2D PixelPosition, CurrentViewportPosition;

        // 获取当前的视口位置
        USlateBlueprintLibrary::LocalToViewport(Widget, WidgetGeometry, LocalPosition, PixelPosition, CurrentViewportPosition);

        // 计算偏移量
        FVector2D Offset = NewViewportPosition - CurrentViewportPosition;

        // 获取当前的渲染变换
        FWidgetTransform RenderTransform = Widget->RenderTransform;

        // 更新位置
        RenderTransform.Translation += Offset;
        Widget->SetRenderTransform(RenderTransform);
    }
}