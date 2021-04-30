#include "XGUIGraphLibrary.h"
#include "LuaBlueprintLibrary.h"
#include "FMod/FModBpLib.h"
#include "CanvasPanelSlot.h"
#include "SlateBlueprintLibrary.h"
#include "UMGSequencePlayer.h"

TMap<UUserWidget*, TArray<UWidgetAnimation*>>* UXGUIGraphLibrary::MapWidgetCareAnimations = nullptr;
TMap<UUserWidget*, TArray<UParticleSystemWidget*>>* UXGUIGraphLibrary::MapWidgetCareParicleSystemSync = nullptr;
TMap<UUserWidget*, TArray<UAsyncParticleSystemWidget*>>* UXGUIGraphLibrary::MapWidgetCareParicleSystemAsync = nullptr;

void UXGUIGraphLibrary::ActionSendCommand(UWidget* Widget, FString CommandName)
{
	TArray<FLuaBPVar> ParamList;
	FLuaBPVar luaVarCommandName = ULuaBlueprintLibrary::CreateVarFromString(CommandName);
	ParamList.Add(luaVarCommandName);
	SendCommand(Widget, ParamList);
}

void UXGUIGraphLibrary::ActionSendCommandWithInt(UWidget* Widget, FString CommandName, int32 ParamInt)
{
	TArray<FLuaBPVar> ParamList;
	FLuaBPVar luaVarCommandName = ULuaBlueprintLibrary::CreateVarFromString(CommandName);
	ParamList.Add(luaVarCommandName);
	FLuaBPVar luaVarParamInt = ULuaBlueprintLibrary::CreateVarFromInt(ParamInt);
	ParamList.Add(luaVarParamInt);
	SendCommand(Widget, ParamList);
}

void UXGUIGraphLibrary::ActionSendCommandWithString(UWidget* Widget, FString CommandName, FString ParamStr)
{
	TArray<FLuaBPVar> ParamList;
	FLuaBPVar luaVarCommandName = ULuaBlueprintLibrary::CreateVarFromString(CommandName);
	ParamList.Add(luaVarCommandName);
	FLuaBPVar luaVarParamString = ULuaBlueprintLibrary::CreateVarFromString(ParamStr);
	ParamList.Add(luaVarParamString);
	SendCommand(Widget, ParamList);
}

void UXGUIGraphLibrary::ActionPlayParticleSystem(UAsyncParticleSystemWidget* Widget, bool Reset)
{
	ensure(Widget);
	//Widget->SetVisibility(ESlateVisibility::Collapsed);
	//Widget->SetVisibility(ESlateVisibility::Visible);
	Widget->ActivateParticles(true, Reset);
}

void UXGUIGraphLibrary::ActionStopParticleSystem(UAsyncParticleSystemWidget* Widget)
{
	ensure(Widget);
	Widget->ActivateParticles(false, true);
}

void UXGUIGraphLibrary::ActionPlayParticleSystemSync(UParticleSystemWidget* Widget, bool Reset)
{
	ensure(Widget);
	//Widget->SetVisibility(ESlateVisibility::Collapsed);
	//Widget->SetVisibility(ESlateVisibility::Visible);
	Widget->SetReactivate(Reset);
}

void UXGUIGraphLibrary::ActionStopParticleSystemSync(UParticleSystemWidget* Widget)
{
	ensure(Widget);
	Widget->ActivateParticles(false, true);
}

void UXGUIGraphLibrary::ActionPlayParticleSystemAndBindFinished(UUserWidget* Widget, UAsyncParticleSystemWidget* ParticleSystemWidget, bool Reset, FName OnFinishHandlerName)
{
	ensure(Widget);
	ensure(ParticleSystemWidget);

	ParticleSystemWidget->ActivateParticles(true, Reset);
	ParticleSystemWidget->BindFinishHandler(Widget, OnFinishHandlerName);
	AddToCareParicleSystemAsyncMap(Widget, ParticleSystemWidget);
}

void UXGUIGraphLibrary::ActionParticleSystemUnbindFinished(UUserWidget* Widget, UAsyncParticleSystemWidget* ParticleSystemWidget, FName OnFinishHandlerName)
{
	ensure(Widget);
	ensure(ParticleSystemWidget);

	ParticleSystemWidget->UnbindFinishHandler(Widget, OnFinishHandlerName);
}

void UXGUIGraphLibrary::ActionPlayParticleSystemAndBindFinishedSync(UUserWidget* Widget, UParticleSystemWidget* ParticleSystemSyncWidget, bool Reset, FName OnFinishHandlerName)
{
	ensure(Widget);
	ensure(ParticleSystemSyncWidget);

	ParticleSystemSyncWidget->ActivateParticles(true, Reset);
	ParticleSystemSyncWidget->BindFinishHandler(Widget, OnFinishHandlerName);
	AddToCareParicleSystemSyncMap(Widget, ParticleSystemSyncWidget);
}

void UXGUIGraphLibrary::ActionParticleSystemUnbindFinishedSync(UUserWidget* Widget, UParticleSystemWidget* ParticleSystemSyncWidget, FName OnFinishHandlerName)
{
	ensure(Widget);

	ParticleSystemSyncWidget->UnbindFinishHandler(Widget, OnFinishHandlerName);
}

void UXGUIGraphLibrary::ActionPlayUIAnimation(UUserWidget* Widget, UWidgetAnimation* UIAnimation, float StartAtTime, int32 NumberOfLoops, EUMGSequencePlayMode::Type PlayMode, float PlaybackSpeed, bool bRestoreState)
{
	ensure(Widget);
	Widget->PlayAnimation(UIAnimation, StartAtTime, NumberOfLoops, PlayMode, PlaybackSpeed, bRestoreState);
}

void UXGUIGraphLibrary::ActionStopUIAnimation(UUserWidget* Widget, UWidgetAnimation* UIAnimation)
{
	ensure(Widget);
	Widget->StopAnimation(UIAnimation);
}

void UXGUIGraphLibrary::ActionSetImage(UImage* UIImage, UTexture2D* Texture2D)
{
	ensure(UIImage);
	ensure(Texture2D);

	UIImage->SetBrushFromTexture(Texture2D, true);
}

void UXGUIGraphLibrary::ActionEnableWidget(UWidget* Widget)
{
	ensure(Widget);
	if (Widget->GetIsEnabled() != true)
	{
		Widget->SetIsEnabled(true);
	}
}

void UXGUIGraphLibrary::ActionDisableWidget(UWidget* Widget)
{
	ensure(Widget);
	if (Widget->GetIsEnabled() != false)
	{
		Widget->SetIsEnabled(false);
	}
}

void UXGUIGraphLibrary::ActionSetVisible(UWidget* Widget, ESlateVisibility Visibility)
{
	ensure(Widget);
	Widget->SetVisibility(Visibility);
}

void UXGUIGraphLibrary::ActionSetWidgetsVisible(TArray<UWidget*> Widgets, ESlateVisibility Visibility)
{
	for (UWidget* widget : Widgets)
	{
		if (IsValid(widget))
		{
			ActionSetVisible(widget, Visibility);
		}
	}
}

void UXGUIGraphLibrary::ActionBindToAnimationStarted(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnStartHandlerName)
{
	ensure(Widget);
	ensure(UIAnimation);

	FWidgetAnimationDynamicEvent de;
	de.BindUFunction(Widget, OnStartHandlerName);
	Widget->BindToAnimationStarted(UIAnimation, de);
	AddToCareAnimationMap(Widget, UIAnimation);
}

void UXGUIGraphLibrary::ActionBindToAnimationFinished(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnFinishHandlerName)
{
	ensure(Widget);
	ensure(UIAnimation);

	FWidgetAnimationDynamicEvent de;
	de.BindUFunction(Widget, OnFinishHandlerName);
	Widget->BindToAnimationFinished(UIAnimation, de);
	AddToCareAnimationMap(Widget, UIAnimation);
}

void UXGUIGraphLibrary::ActionUnbindToAnimationStarted(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnStartHandlerName)
{
	ensure(Widget);
	ensure(UIAnimation);

	FWidgetAnimationDynamicEvent de;
	de.BindUFunction(Widget, OnStartHandlerName);
	Widget->UnbindFromAnimationStarted(UIAnimation, de);
}

void UXGUIGraphLibrary::ActionUnbindToAnimationFinished(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnFinishHandlerName)
{
	ensure(Widget);
	ensure(UIAnimation);

	FWidgetAnimationDynamicEvent de;
	de.BindUFunction(Widget, OnFinishHandlerName);
	Widget->UnbindFromAnimationFinished(UIAnimation, de);
}

void UXGUIGraphLibrary::ActionBindToAnimationsStarted(UUserWidget* Widget, TArray<UWidgetAnimation*> UIAnimations, FName OnStartHandlerName)
{
	ensure(Widget);

	for (UWidgetAnimation* UIAnimation : UIAnimations)
	{
		FWidgetAnimationDynamicEvent de;
		de.BindUFunction(Widget, OnStartHandlerName);
		Widget->BindToAnimationStarted(UIAnimation, de);
		AddToCareAnimationMap(Widget, UIAnimation);
	}
}

void UXGUIGraphLibrary::ActionBindToAnimationsFinished(UUserWidget* Widget, TArray<UWidgetAnimation*> UIAnimations, FName OnFinishHandlerName)
{
	ensure(Widget);

	for (UWidgetAnimation* UIAnimation : UIAnimations)
	{
		FWidgetAnimationDynamicEvent de;
		de.BindUFunction(Widget, OnFinishHandlerName);
		Widget->BindToAnimationFinished(UIAnimation, de);
		AddToCareAnimationMap(Widget, UIAnimation);
	}
}

void UXGUIGraphLibrary::ActionUnbindToAnimationsStarted(UUserWidget* Widget, TArray<UWidgetAnimation*> UIAnimations, FName OnStartHandlerName)
{
	ensure(Widget);

	for (UWidgetAnimation* UIAnimation : UIAnimations)
	{
		FWidgetAnimationDynamicEvent de;
		de.BindUFunction(Widget, OnStartHandlerName);
		Widget->UnbindFromAnimationStarted(UIAnimation, de);
	}
}

void UXGUIGraphLibrary::ActionUnbindToAnimationsFinished(UUserWidget* Widget, TArray<UWidgetAnimation*> UIAnimations, FName OnFinishHandlerName)
{
	ensure(Widget);

	for (UWidgetAnimation* UIAnimation : UIAnimations)
	{
		FWidgetAnimationDynamicEvent de;
		de.BindUFunction(Widget, OnFinishHandlerName);
		Widget->UnbindFromAnimationFinished(UIAnimation, de);
	}
}

void UXGUIGraphLibrary::ActionPlayAnimationAndBindStarted(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnStartHandlerName, float StartAtTime, int32 NumberOfLoops, EUMGSequencePlayMode::Type PlayMode, float PlaybackSpeed, bool bRestoreState)
{
	ensure(Widget);
	ensure(UIAnimation);

	FWidgetAnimationDynamicEvent de;
	de.BindUFunction(Widget, OnStartHandlerName);
	Widget->BindToAnimationStarted(UIAnimation, de);

	Widget->PlayAnimation(UIAnimation, StartAtTime, NumberOfLoops, PlayMode, PlaybackSpeed, bRestoreState);
}

void UXGUIGraphLibrary::ActionPlayAnimationAndBindFinished(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnStartHandlerName, float StartAtTime, int32 NumberOfLoops, EUMGSequencePlayMode::Type PlayMode, float PlaybackSpeed, bool bRestoreState)
{
	ensure(Widget);
	ensure(UIAnimation);

	FWidgetAnimationDynamicEvent de;
	de.BindUFunction(Widget, OnStartHandlerName);
	Widget->BindToAnimationFinished(UIAnimation, de);

	Widget->PlayAnimation(UIAnimation, StartAtTime, NumberOfLoops, PlayMode, PlaybackSpeed, bRestoreState);
}

void UXGUIGraphLibrary::ActionFilterPlayAnimationInclude(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> EnableObjs, float StartAtTime, int32 NumberOfLoops, EUMGSequencePlayMode::Type PlayMode, float PlaybackSpeed, bool bRestoreState)
{
	ensure(Widget);
	ensure(UIAnimation);

	UMovieScene* MovieScene = UIAnimation->GetMovieScene();
	int32 PossessableCount = MovieScene->GetPossessableCount();
	auto Bindings = MovieScene->GetBindings();
	for (int32 i = 0; i < PossessableCount; i++)
	{
		auto Possessable = MovieScene->GetPossessable(i);
		bool wontEvaluteAtRuntime = true;
		if (EnableObjs.Contains(Possessable.GetName()))
		{
			wontEvaluteAtRuntime = false;
		}
		auto Binding = Bindings[i];
		for (const auto& Track : Binding.GetTracks())
		{
			Track->SetWontEvaluteAtRuntime(wontEvaluteAtRuntime);
		}
	}

	UXGUIGraphLibrary::ActionPlayUIAnimation(Widget, UIAnimation, StartAtTime, NumberOfLoops, PlayMode, PlaybackSpeed, bRestoreState);
	// here, we need to reset
	for (auto Binding : MovieScene->GetBindings())
	{
		for (const auto& Track : Binding.GetTracks())
		{
			Track->SetWontEvaluteAtRuntime(false);
		}
	}
}

void UXGUIGraphLibrary::ActionFilterPlayAnimationExclude(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> DisableObjs, float StartAtTime, int32 NumberOfLoops, EUMGSequencePlayMode::Type PlayMode, float PlaybackSpeed, bool bRestoreState)
{
	ensure(Widget);
	ensure(UIAnimation);

	UMovieScene* MovieScene = UIAnimation->GetMovieScene();
	int32 PossessableCount = MovieScene->GetPossessableCount();
	auto Bindings = MovieScene->GetBindings();
	for (int32 i = 0; i < PossessableCount; i++)
	{
		auto Possessable = MovieScene->GetPossessable(i);
		bool wontEvaluteAtRuntime = false;
		if (DisableObjs.Contains(Possessable.GetName()))
		{
			wontEvaluteAtRuntime = true;
		}
		auto Binding = Bindings[i];
		for (const auto& Track : Binding.GetTracks())
		{
			Track->SetWontEvaluteAtRuntime(wontEvaluteAtRuntime);
		}
	}

	UXGUIGraphLibrary::ActionPlayUIAnimation(Widget, UIAnimation, StartAtTime, NumberOfLoops, PlayMode, PlaybackSpeed, bRestoreState);
	// here, we need to reset
	for (auto Binding : MovieScene->GetBindings())
	{
		for (const auto& Track : Binding.GetTracks())
		{
			Track->SetWontEvaluteAtRuntime(false);
		}
	}
}

void UXGUIGraphLibrary::ActionFilterPlayAnimationIncludeAndBindStarted(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> EnableObjs, FName OnStartHandlerName, float StartAtTime, int32 NumberOfLoops, EUMGSequencePlayMode::Type PlayMode, float PlaybackSpeed, bool bRestoreState)
{
	UXGUIGraphLibrary::ActionFilterPlayAnimationInclude(Widget, UIAnimation, EnableObjs, StartAtTime, NumberOfLoops, PlayMode, PlaybackSpeed, bRestoreState);
	UXGUIGraphLibrary::ActionBindToAnimationStarted(Widget, UIAnimation, OnStartHandlerName);
}

void UXGUIGraphLibrary::ActionFilterPlayAnimationExcludeAndBindStarted(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> DisableObjs, FName OnStartHandlerName, float StartAtTime, int32 NumberOfLoops, EUMGSequencePlayMode::Type PlayMode, float PlaybackSpeed, bool bRestoreState)
{
	UXGUIGraphLibrary::ActionFilterPlayAnimationExclude(Widget, UIAnimation, DisableObjs, StartAtTime, NumberOfLoops, PlayMode, PlaybackSpeed, bRestoreState);
	UXGUIGraphLibrary::ActionBindToAnimationStarted(Widget, UIAnimation, OnStartHandlerName);
}

void UXGUIGraphLibrary::ActionFilterPlayAnimationIncludeAndBindFinished(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> EnableObjs, FName OnFinishHandlerName, float StartAtTime, int32 NumberOfLoops, EUMGSequencePlayMode::Type PlayMode, float PlaybackSpeed, bool bRestoreState)
{
	UXGUIGraphLibrary::ActionFilterPlayAnimationInclude(Widget, UIAnimation, EnableObjs, StartAtTime, NumberOfLoops, PlayMode, PlaybackSpeed, bRestoreState);
	UXGUIGraphLibrary::ActionBindToAnimationFinished(Widget, UIAnimation, OnFinishHandlerName);
}

void UXGUIGraphLibrary::ActionFilterPlayAnimationExcludeAndBindFinished(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> DisableObjs, FName OnFinishHandlerName, float StartAtTime, int32 NumberOfLoops, EUMGSequencePlayMode::Type PlayMode, float PlaybackSpeed, bool bRestoreState)
{
	UXGUIGraphLibrary::ActionFilterPlayAnimationExclude(Widget, UIAnimation, DisableObjs, StartAtTime, NumberOfLoops, PlayMode, PlaybackSpeed, bRestoreState);
	UXGUIGraphLibrary::ActionBindToAnimationFinished(Widget, UIAnimation, OnFinishHandlerName);
}

UWidget* UXGUIGraphLibrary::ActionFindWidget(UUserWidget* Widget, FString WidgetName)
{
	ensure(Widget);

	return Widget->GetWidgetFromName(FName(*WidgetName));
}

FVector2D UXGUIGraphLibrary::ActionGetWidgetPos(UWidget* Widget)
{
	ensure(Widget);

	return Widget->RenderTransform.Translation;
}

float UXGUIGraphLibrary::ActionGetWidgetAngel(UWidget* Widget)
{
	ensure(Widget);

	return Widget->RenderTransform.Angle;
}

FMargin UXGUIGraphLibrary::ActionGetWidgetSlotOffsets(UWidget* Widget)
{
	ensure(Widget);

	UCanvasPanelSlot* PanelSlot = Cast<UCanvasPanelSlot>(Widget->Slot);

	ensure(PanelSlot);

	return PanelSlot->GetOffsets();
}

void UXGUIGraphLibrary::ActionSetWidgetPos(UWidget* Widget, FVector2D Pos)
{
	ensure(Widget);
	Widget->SetRenderTranslation(Pos);
}

void UXGUIGraphLibrary::ActionSetWidgetAngel(UWidget* Widget, float Angel)
{
	ensure(Widget);
	Widget->SetRenderTransformAngle(Angel);
}

void UXGUIGraphLibrary::ActionSetWidgetSlotOffsets(UWidget* Widget, FMargin InOffset)
{
	ensure(Widget);

	UCanvasPanelSlot* PanelSlot = Cast<UCanvasPanelSlot>(Widget->Slot);

	ensure(PanelSlot);

	PanelSlot->SetOffsets(InOffset);
}

FVector2D UXGUIGraphLibrary::ActionCoordLocalToAbsolute(UWidget* Widget, FVector2D Coord)
{
	ensure(Widget);

	return USlateBlueprintLibrary::LocalToAbsolute(Widget->GetCachedGeometry(), Coord);
}

FVector2D UXGUIGraphLibrary::ActionCoordAbsoluteToLocal(UWidget* Widget, FVector2D Coord)
{
	ensure(Widget);

	return USlateBlueprintLibrary::AbsoluteToLocal(Widget->GetCachedGeometry(), Coord);
}

FTimerHandle UXGUIGraphLibrary::ActionDelayFunction(UUserWidget* Widget, float InRate, FName OnHandlerName, float DelayTime, bool Loop)
{
	ensure(Widget);
	ensure(DelayTime >= 0);

	FTimerHandle TimeHandler;
	FTimerDelegate TimerDelegate;
	TimerDelegate.BindUFunction(Widget, OnHandlerName);
	Widget->GetWorld()->GetTimerManager().SetTimer(TimeHandler, TimerDelegate, InRate, Loop, DelayTime);

	return TimeHandler;
}

void UXGUIGraphLibrary::ActionRemoveDelayFunction(UUserWidget* Widget, FTimerHandle TimerHandler)
{
	ensure(Widget);
	Widget->GetWorld()->GetTimerManager().ClearTimer(TimerHandler);
}

void UXGUIGraphLibrary::ActionPlaySound(FString EventName)
{
	UFModBpLib::PlayEvent2D(EventName);
}

void UXGUIGraphLibrary::UnbindAllHandlerFromWidget(UUserWidget* Widget)
{
	if (MapWidgetCareAnimations)
	{
		TArray<UWidgetAnimation*>* Animations = MapWidgetCareAnimations->Find(Widget);
		if (Animations)
		{
			for (auto Animation : *Animations)
			{
				Widget->UnbindAllFromAnimationStarted(Animation);
				Widget->UnbindAllFromAnimationFinished(Animation);
			}
			MapWidgetCareAnimations->Remove(Widget);
		}
	}

	if (MapWidgetCareParicleSystemSync)
	{
		TArray<UParticleSystemWidget*>* ParticleSystems = MapWidgetCareParicleSystemSync->Find(Widget);
		if (ParticleSystems)
		{
			for (auto ParticleSystem : *ParticleSystems)
			{
				ParticleSystem->UnbindAllFinishHandler();
			}
			MapWidgetCareParicleSystemSync->Remove(Widget);
		}
	}

	if (MapWidgetCareParicleSystemAsync)
	{
		TArray<UAsyncParticleSystemWidget*>* AsyncParticleSystems = MapWidgetCareParicleSystemAsync->Find(Widget);
		if (AsyncParticleSystems)
		{
			for (auto AsyncParticleSystem : *AsyncParticleSystems)
			{
				AsyncParticleSystem->UnbindAllFinishHandler();
			}
			MapWidgetCareParicleSystemAsync->Remove(Widget);
		}
	}
}

void UXGUIGraphLibrary::SendCommand(UWidget* Widget, TArray<FLuaBPVar>& ParamList)
{
	ensure(Widget);
	ULuaBlueprintLibrary::GameInstanceCallToLuaWithArgs(Widget->GetGameInstance(), "SendCommandGlobal", ParamList, "");
}

void UXGUIGraphLibrary::AddToCareAnimationMap(UUserWidget* Widget, UWidgetAnimation* Animation)
{
	if (!MapWidgetCareAnimations)
	{
		MapWidgetCareAnimations = new TMap<UUserWidget*, TArray<UWidgetAnimation*>>();
	}
	if (!MapWidgetCareAnimations->Contains(Widget))
	{
		MapWidgetCareAnimations->Add(Widget, *new TArray<UWidgetAnimation*>());
	}
	auto ArrAnimations = MapWidgetCareAnimations->Find(Widget);
	if (!ArrAnimations->Contains(Animation))
	{
		ArrAnimations->Add(Animation);
	}
}

void UXGUIGraphLibrary::AddToCareParicleSystemSyncMap(UUserWidget* Widget, UParticleSystemWidget* ParticleSystemWidget)
{
	if (!MapWidgetCareParicleSystemSync)
	{
		MapWidgetCareParicleSystemSync = new TMap<UUserWidget*, TArray<UParticleSystemWidget*>>();
	}
	if (!MapWidgetCareParicleSystemSync->Contains(Widget))
	{
		MapWidgetCareParicleSystemSync->Add(Widget, *new TArray<UParticleSystemWidget*>());
	}
	auto ArrParticleSystemSyncs = MapWidgetCareParicleSystemSync->Find(Widget);
	if (!ArrParticleSystemSyncs->Contains(ParticleSystemWidget))
	{
		ArrParticleSystemSyncs->Add(ParticleSystemWidget);
	}
}

void UXGUIGraphLibrary::AddToCareParicleSystemAsyncMap(UUserWidget* Widget, UAsyncParticleSystemWidget* AsyncParticleSystemWidget)
{
	if (!MapWidgetCareParicleSystemAsync)
	{
		MapWidgetCareParicleSystemAsync = new TMap<UUserWidget*, TArray<UAsyncParticleSystemWidget*>>();
	}
	if (!MapWidgetCareParicleSystemAsync->Contains(Widget))
	{
		MapWidgetCareParicleSystemAsync->Add(Widget, *new TArray<UAsyncParticleSystemWidget*>());
	}
	auto ArrParticleSystemAsyncs = MapWidgetCareParicleSystemAsync->Find(Widget);
	if (!ArrParticleSystemAsyncs->Contains(AsyncParticleSystemWidget))
	{
		ArrParticleSystemAsyncs->Add(AsyncParticleSystemWidget);
	}
}