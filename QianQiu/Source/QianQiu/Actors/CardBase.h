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
    UPROPERTY(EditAnywhere, Category="Card")
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

    UPROPERTY(EditAnywhere)
    float CardMoveSpeed = 1.0f;

    // Called every frame
    virtual void Tick(float DeltaTime) override;

    void Init(FCardData InCardData);

    void Init(const int& CardID);

    UFUNCTION()
    void OnCardClick(AActor* ClickedActor, FKey ButtonPressed);

    UFUNCTION()
    void PlayCardMoveAnim(const FTransform& Transform);

    UFUNCTION()
    void Move();
public:
    UPROPERTY()
    bool bMoving = false;

    UPROPERTY()
    FTransform EndTransform;

#if WITH_EDITOR

#if WITH_EDITORONLY_DATA
    UPROPERTY(EditAnywhere, BlueprintReadWrite, DisplayName = "CardDataTable",  Category="Card")
    UDataTable* CardDataTable;
#endif
    UFUNCTION(CallInEditor, Category="Card")
    void Init();
#endif
};
