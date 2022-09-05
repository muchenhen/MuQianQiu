// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "MuStructs.h"
#include "GameFramework/Actor.h"
#include "CardBase.generated.h"

UCLASS()
class QIANQIU_API ACardBase : public AActor
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere)
    FString LuaScript = TEXT("Actor/CardBase");

    UPROPERTY(EditAnywhere)
    FCardData CardData = FCardData();

public:
    // Sets default values for this actor's properties
    ACardBase();

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, meta = (AllowPrivateAccess = "true"))
    UStaticMeshComponent* StaticMesh;

protected:
    // Called when the game starts or when spawned
    virtual void BeginPlay() override;

public:
    UPROPERTY(EditAnywhere)
    int ID = 201;

    // Called every frame
    virtual void Tick(float DeltaTime) override;

    void Init(FCardData InCardData);

    void Init(const int& CardID);

    // UFUNCTION()
    // void OnCardClick(AActor* ClickedActor, FKey ButtonPressed);

#if WITH_EDITOR
    UFUNCTION(CallInEditor)
    void Init();
#endif
};
