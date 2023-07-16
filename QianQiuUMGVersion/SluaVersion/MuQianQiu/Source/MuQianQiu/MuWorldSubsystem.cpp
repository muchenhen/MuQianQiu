// Fill out your copyright notice in the Description page of Project Settings.


#include "MuWorldSubsystem.h"

#include "Engine/GameEngine.h"
#include "GameFramework/GameUserSettings.h"

void UMuWorldSubsystem::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    if (IsInitialized())
    {
        if (!bWindowResized)
        {
            bWindowResized = true;
            const auto ViewportWidget = GEngine->GetGameViewportWidget();
            const TSharedPtr<SWindow> WindowToResize = FSlateApplication::Get().FindWidgetWindow(ViewportWidget.ToSharedRef());
            if (WindowToResize.IsValid())
            {
                // 获取当前屏幕的分辨率
                FDisplayMetrics DisplayMetrics;
                FSlateApplication::Get().GetInitialDisplayMetrics(DisplayMetrics);
                const FVector2d ScreenSize = FVector2d(DisplayMetrics.PrimaryDisplayWidth, DisplayMetrics.PrimaryDisplayHeight);
                GEngine->GetGameUserSettings()->SetFullscreenMode(EWindowMode::WindowedFullscreen);
                if (ScreenSize.X <= 2560 && ScreenSize.X >1920)
                {
                    GEngine->GetGameUserSettings()->SetScreenResolution(FIntPoint(1920, 1080));
                    GEngine->GetGameUserSettings()->SetFullscreenMode(EWindowMode::Windowed);
                }
                else
                {
                    GEngine->GetGameUserSettings()->SetScreenResolution(FIntPoint(1280, 720));
                    GEngine->GetGameUserSettings()->SetFullscreenMode(EWindowMode::Windowed);
                }
                GEngine->GetGameUserSettings()->ApplySettings(true);
            }
        }
    }
}

TStatId UMuWorldSubsystem::GetStatId() const
{
    RETURN_QUICK_DECLARE_CYCLE_STAT(UMuWorldSubsystem, STATGROUP_Tickables);
}
