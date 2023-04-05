// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "MuStructs.h"
#include "../Public/MuStructs.h"
#include "GameFramework/Actor.h"
#include "CardBase.generated.h"

DECLARE_LOG_CATEGORY_EXTERN(LogCardBase, Log, All);

DECLARE_DELEGATE(FOnInitAllCardsMoveEnd)
DECLARE_DELEGATE(FOnInitPublicCardsDealEnd) // 公共卡池发牌结束 牌的所有移动结束

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnPlayerChooseCard, ACardBase*, CardActor);

class UGameManager;

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

    UFUNCTION()
    void OnCardClick(AActor* ClickedActor, FKey ButtonPressed);

    UFUNCTION()
    void OnCardRelease(AActor* Actor, FKey Key);
    
public:
    UPROPERTY(EditAnywhere)
    int ID = 201;

    UPROPERTY(EditAnywhere)
    float CardMoveSpeed = 1.0f;

    UPROPERTY()
    bool bInitAllCardMoveEnd = false;
    
    UPROPERTY()
    bool bChoose = false;

    // 卡片所属类型
    UPROPERTY()
    ECardBelongType CardBelongType = ECardBelongType::PublicShow;

    FOnInitAllCardsMoveEnd OnInitAllCardsMoveEnd;

    FOnInitPublicCardsDealEnd OnInitPublicCardsDealEnd;
    
    // Called every frame
    virtual void Tick(float DeltaTime) override;

    void Init(FCardData InCardData);

    void Init(const int& CardID);
    
    UFUNCTION()
    void OnCardBeginCursorOver(AActor* Actor);

    UFUNCTION()
    void OnCardEndCursorOver(AActor* Actor);
    
    UFUNCTION()
    void PlayCardMoveAnim(const FTransform& Transform, EMoveState InMoveState);

    UFUNCTION()
    void Move();

    UFUNCTION()
    void SetFixedTransform(const FTransform& Transform);

    UFUNCTION()
    void BindAllCardInitMoveEnd(UGameManager* GameManager);

    UFUNCTION()
    void SetCardBelongType(ECardBelongType InCardBelongType);

    UFUNCTION()
    void SetCardChoosing(bool bInChoose);
public:
    UPROPERTY()
    EMoveState MoveState = EMoveState::Stop;
    
    UPROPERTY()
    FTransform EndTransform;

    UPROPERTY()
    FTransform FixedTransform;

    UPROPERTY(BlueprintAssignable)
    FOnPlayerChooseCard OnPlayerChooseCard;

#if WITH_EDITOR

#if WITH_EDITORONLY_DATA
    UPROPERTY(EditAnywhere, BlueprintReadWrite, DisplayName = "CardDataTable",  Category="Card")
    UDataTable* CardDataTable;
#endif
    UFUNCTION(CallInEditor, Category="Card")
    void Init();
#endif
};
