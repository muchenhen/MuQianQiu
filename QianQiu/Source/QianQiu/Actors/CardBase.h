// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "MyStructs.h"
#include "GameFramework/Actor.h"
#include "CardBase.generated.h"

UCLASS()
class QIANQIU_API ACardBase : public AActor
{
    GENERATED_BODY()

public:
    // Sets default values for this actor's properties
    ACardBase();

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, meta = (AllowPrivateAccess = "true"))
    UStaticMeshComponent* StaticMesh;
    
protected:
    // Called when the game starts or when spawned
    virtual void BeginPlay() override;

public:
    // Called every frame
    virtual void Tick(float DeltaTime) override;

    void Init(FCardData CardData);
};
