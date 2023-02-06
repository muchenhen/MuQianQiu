// Fill out your copyright notice in the Description page of Project Settings.


#include "UIManager.h"

#include "Blueprint/UserWidget.h"

UUIManager::UUIManager()
{
    UClass* DisableInputWidgetClass = LoadClass<UUserWidget>(nullptr, TEXT("/Game/UI/UI_DisableInput.UI_DisableInput_C"));
    DisableInputUI = CreateWidget<UUserWidget>(UObject::GetWorld(), DisableInputWidgetClass);
}

void UUIManager::OpenDisableInputUI()
{
    if (IsValid(DisableInputUI))
    {
        DisableInputCount++;
        if (DisableInputCount == 1)
        {
            DisableInputUI->AddToViewport();
        }
        DisableInputUI->SetVisibility(ESlateVisibility::Visible);
    }
}

void UUIManager::CloseDisableInputUI()
{
    if (IsValid(DisableInputUI))
    {
        DisableInputCount--;
        if (DisableInputCount <= 0)
        {
            DisableInputCount = 0;
            DisableInputUI->SetVisibility(ESlateVisibility::Collapsed);
        }
    }
}

void UUIManager::ForceCloseDisableInputUI()
{
    if (IsValid(DisableInputUI))
    {
        DisableInputCount = 0;
        DisableInputUI->SetVisibility(ESlateVisibility::Collapsed);
    }
}
