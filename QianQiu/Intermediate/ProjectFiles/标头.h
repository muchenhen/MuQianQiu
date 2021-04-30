#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "AsyncParticleWidget.h"
#include "ParticleWidget.h"
#include "TimerManager.h"
#include "Animation/WidgetAnimation.h"
#include "UserWidget.h"
#include "Image.h"

#include "XGUIGraphLibrary.generated.h"

class UWidgetAnimation;

UCLASS()
class XGAME_API UXGUIGraphLibrary : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()
public:
	/* dispatch an event to lua */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionSendCommand(UWidget* Widget, FString CommandName);

	/* dispatch an event to lua with parameter of integer type */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionSendCommandWithInt(UWidget* Widget, FString CommandName, int32 ParamInt);

	/* dispatch an event to lua with parameter of string type */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionSendCommandWithString(UWidget* Widget, FString CommandName, FString ParamStr);

	/* play a ui particle system asyncly */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionPlayParticleSystem(UAsyncParticleSystemWidget* Widget, bool Reset);

	/* stop a ui particle system asyncly */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionStopParticleSystem(UAsyncParticleSystemWidget* Widget);

	/* play a ui particle system syncly */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionPlayParticleSystemSync(UParticleSystemWidget* Widget, bool Reset);

	/* stop a ui particle system syncly */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionStopParticleSystemSync(UParticleSystemWidget* Widget);

	/* play a ui particle system asyncly and bind a function at the end of particle system */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionPlayParticleSystemAndBindFinished(UUserWidget* Widget, UAsyncParticleSystemWidget* ParticleSystemWidget, bool Reset, FName OnFinishHandlerName);

	/* unbind a function from the end of particle system asyncly */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionParticleSystemUnbindFinished(UUserWidget* Widget, UAsyncParticleSystemWidget* ParticleSystemWidget, FName OnFinishHandlerName);

	/* play a ui particle system syncly and bind a function at the end of particle system */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionPlayParticleSystemAndBindFinishedSync(UUserWidget* Widget, UParticleSystemWidget* ParticleSystemSyncWidget, bool Reset, FName OnFinishHandlerName);

	/* unbind a function from the end of particle system syncly */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionParticleSystemUnbindFinishedSync(UUserWidget* Widget, UParticleSystemWidget* ParticleSystemSyncWidget, FName OnFinishHandlerName);

	/* play a ui particle animation */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionPlayUIAnimation(UUserWidget* Widget, UWidgetAnimation* UIAnimation, float StartAtTime = 0.0f, int32 NumberOfLoops = 1, EUMGSequencePlayMode::Type PlayMode = EUMGSequencePlayMode::Forward, float PlaybackSpeed = 1.0f, bool bRestoreState = false);

	/* stop a ui particle animation */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionStopUIAnimation(UUserWidget* Widget, UWidgetAnimation* UIAnimation);

	/* set a texture for image */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionSetImage(UImage* UIImage, UTexture2D* Texture2D);

	/* enable a widget */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionEnableWidget(UWidget* Widget);

	/* disable a widget */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionDisableWidget(UWidget* Widget);

	/* set the visibility of a widget */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionSetVisible(UWidget* Widget, ESlateVisibility Visibility);

	/* set the visibility of some widgets */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionSetWidgetsVisible(TArray<UWidget*> Widgets, ESlateVisibility Visibility);

	/* bind a function at the start of animation by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionBindToAnimationStarted(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnStartHandlerName);

	/* bind a function at the end of animation by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionBindToAnimationFinished(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnFinishHandlerName);

	/* unbind a function at the start of animation by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionUnbindToAnimationStarted(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnStartHandlerName);

	/* unbind a function at the end of animation by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionUnbindToAnimationFinished(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnFinishHandlerName);

	/* bind a function at the start of animations by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionBindToAnimationsStarted(UUserWidget* Widget, TArray<UWidgetAnimation*> UIAnimations, FName OnStartHandlerName);

	/* bind a function at the end of animations by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionBindToAnimationsFinished(UUserWidget* Widget, TArray<UWidgetAnimation*> UIAnimations, FName OnFinishHandlerName);

	/* unbind a function at the start of animations by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionUnbindToAnimationsStarted(UUserWidget* Widget, TArray<UWidgetAnimation*> UIAnimations, FName OnStartHandlerName);

	/* unbind a function at the end of animations by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionUnbindToAnimationsFinished(UUserWidget* Widget, TArray<UWidgetAnimation*> UIAnimations, FName OnFinishHandlerName);

	/* play a animation and bind a function at the start of the animation by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionPlayAnimationAndBindStarted(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnStartHandlerName, float StartAtTime = 0.0f, int32 NumberOfLoops = 1, EUMGSequencePlayMode::Type PlayMode = EUMGSequencePlayMode::Forward, float PlaybackSpeed = 1.0f, bool bRestoreState = false);

	/* play a animation and bind a function at the end of the animation by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionPlayAnimationAndBindFinished(UUserWidget* Widget, UWidgetAnimation* UIAnimation, FName OnFinishHandlerName, float StartAtTime = 0.0f, int32 NumberOfLoops = 1, EUMGSequencePlayMode::Type PlayMode = EUMGSequencePlayMode::Forward, float PlaybackSpeed = 1.0f, bool bRestoreState = false);

	/* play a animation but just only tracks you refer those will play */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionFilterPlayAnimationInclude(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> EnableObjs, float StartAtTime = 0.0f, int32 NumberOfLoops = 1, EUMGSequencePlayMode::Type PlayMode = EUMGSequencePlayMode::Forward, float PlaybackSpeed = 1.0f, bool bRestoreState = false);

	/* play a animation but just only tracks not in your exclude those will play */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionFilterPlayAnimationExclude(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> DisableObjs, float StartAtTime = 0.0f, int32 NumberOfLoops = 1, EUMGSequencePlayMode::Type PlayMode = EUMGSequencePlayMode::Forward, float PlaybackSpeed = 1.0f, bool bRestoreState = false);

	/* play a animation but just only tracks you refer those will play, then bind a function at the start of the animation by function name  */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionFilterPlayAnimationIncludeAndBindStarted(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> EnableObjs, FName OnStartHandlerName, float StartAtTime = 0.0f, int32 NumberOfLoops = 1, EUMGSequencePlayMode::Type PlayMode = EUMGSequencePlayMode::Forward, float PlaybackSpeed = 1.0f, bool bRestoreState = false);

	/* play a animation but just only tracks not in your exclude those will play, then bind a function at the start of the animation by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionFilterPlayAnimationExcludeAndBindStarted(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> DisableObjs, FName OnStartHandlerName, float StartAtTime = 0.0f, int32 NumberOfLoops = 1, EUMGSequencePlayMode::Type PlayMode = EUMGSequencePlayMode::Forward, float PlaybackSpeed = 1.0f, bool bRestoreState = false);

	/* play a animation but just only tracks you refer those will play, then bind a function at the start of the animation by function name  */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionFilterPlayAnimationIncludeAndBindFinished(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> EnableObjs, FName OnFinishHandlerName, float StartAtTime = 0.0f, int32 NumberOfLoops = 1, EUMGSequencePlayMode::Type PlayMode = EUMGSequencePlayMode::Forward, float PlaybackSpeed = 1.0f, bool bRestoreState = false);

	/* play a animation but just only tracks not in your exclude those will play, then bind a function at the start of the animation by function name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionFilterPlayAnimationExcludeAndBindFinished(UUserWidget* Widget, UWidgetAnimation* UIAnimation, TArray<FString> DisableObjs, FName OnFinishHandlerName, float StartAtTime = 0.0f, int32 NumberOfLoops = 1, EUMGSequencePlayMode::Type PlayMode = EUMGSequencePlayMode::Forward, float PlaybackSpeed = 1.0f, bool bRestoreState = false);

	/* find target widget by widget name */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static UWidget* ActionFindWidget(UUserWidget* Widget, FString WidgetName);

	/* get target widget position */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static FVector2D ActionGetWidgetPos(UWidget* Widget);

	/* get target widget angle */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static float ActionGetWidgetAngel(UWidget* Widget);

	/* get target widget slot offsets */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static FMargin ActionGetWidgetSlotOffsets(UWidget* Widget);

	/* set target widget position */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionSetWidgetPos(UWidget* Widget, FVector2D Pos);

	/* set target widget angle */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionSetWidgetAngel(UWidget* Widget, float Angel);

	/* set target widget slot offsets */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionSetWidgetSlotOffsets(UWidget* Widget, FMargin InOffset);

	/* transfer target local position to world position */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static FVector2D ActionCoordLocalToAbsolute(UWidget* Widget, FVector2D Coord);

	/* transfer target world position to local position */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static FVector2D ActionCoordAbsoluteToLocal(UWidget* Widget, FVector2D Coord);

	/* delay function */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static FTimerHandle ActionDelayFunction(UUserWidget* Widget, float InRate, FName OnHandlerName, float DelayTime, bool Loop = false);

	/* remove delay function */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionRemoveDelayFunction(UUserWidget* Widget, FTimerHandle TimerHandler);

	/* play an 2d sound */
	UFUNCTION(BlueprintCallable, Category = "XGUIGraphUtility")
		static void ActionPlaySound(FString EventName);








	/* unbind all related handler from widget */
	UFUNCTION(BlueprintCallable)
		static void UnbindAllHandlerFromWidget(UUserWidget* Widget);
private:
	UFUNCTION()
		static void SendCommand(UWidget* Widget, TArray<FLuaBPVar>& ParamList);

	UFUNCTION()
		static void AddToCareAnimationMap(UUserWidget* Widget, UWidgetAnimation* Animation);

	UFUNCTION()
		static void AddToCareParicleSystemSyncMap(UUserWidget* Widget, UParticleSystemWidget* ParticleSystemWidget);

	UFUNCTION()
		static void AddToCareParicleSystemAsyncMap(UUserWidget* Widget, UAsyncParticleSystemWidget* AsyncParticleSystemWidget);
private:
	static TMap<UUserWidget*, TArray<UWidgetAnimation*>>* MapWidgetCareAnimations;
	static TMap<UUserWidget*, TArray<UParticleSystemWidget*>>* MapWidgetCareParicleSystemSync;
	static TMap<UUserWidget*, TArray<UAsyncParticleSystemWidget*>>* MapWidgetCareParicleSystemAsync;
};