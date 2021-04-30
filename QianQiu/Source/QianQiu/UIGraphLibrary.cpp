// Fill out your copyright notice in the Description page of Project Settings.


#include "UIGraphLibrary.h"

void UUIGraphLibrary::ActionUnbindToAnimationsFinished(UUserWidget* Widget, TArray<UWidgetAnimation*> UIAnimations, FName OnFinishHandlerName)
{
	ensure(Widget);

	for (UWidgetAnimation* UIAnimation : UIAnimations)
	{
		FWidgetAnimationDynamicEvent de;
		de.BindUFunction(Widget, OnFinishHandlerName);
		Widget->UnbindFromAnimationFinished(UIAnimation, de);
	}
}
