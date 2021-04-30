// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "TimerManager.h"
#include "Animation/WidgetAnimation.h"
#include "UserWidget.h"
#include "Image.h"
#include "UIGraphLibrary.generated.h"

/**
 * 
 */
UCLASS()
class QIANQIU_API UUIGraphLibrary : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()
	
public:
	/* unbind a function at the end of animations by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
	static void ActionUnbindToAnimationsFinished(UUserWidget* Widget, TArray<UWidgetAnimation*> UIAnimations, FName OnFinishHandlerName);

};
