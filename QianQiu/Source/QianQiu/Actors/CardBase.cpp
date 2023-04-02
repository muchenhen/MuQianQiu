// Fill out your copyright notice in the Description page of Project Settings.

#include "CardBase.h"

#include "Kismet/GameplayStatics.h"
#include "QianQiu/Managers/DataManager.h"

DEFINE_LOG_CATEGORY(LogCardBase);

// Sets default values
ACardBase::ACardBase()
{
    // Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
    PrimaryActorTick.bCanEverTick = true;

    RootComponent = CreateDefaultSubobject<USceneComponent>(TEXT("RootComponent"));

    StaticMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("StaticMesh"));
    AddInstanceComponent(StaticMesh);
    StaticMesh->AttachToComponent(RootComponent, FAttachmentTransformRules::KeepRelativeTransform);
    UStaticMesh* Mesh = LoadObject<UStaticMesh>(nullptr, TEXT("StaticMesh'/Game/Model/FBX_Card.FBX_Card'"));
    StaticMesh->SetStaticMesh(Mesh);
    UMaterialInstance* Material = LoadObject<UMaterialInstance>(nullptr, TEXT("MaterialInstanceConstant'/Game/Material/MTI_Card.MTI_Card'"));
    StaticMesh->SetMaterial(0, Material->GetMaterial());
    // Init(FCardData());
}

// Called when the game starts or when spawned
void ACardBase::BeginPlay()
{
    Super::BeginPlay();
    OnClicked.AddDynamic(this, &ACardBase::OnCardClick);
    OnReleased.AddDynamic(this, &ACardBase::OnCardRelease);
    // OnBeginCursorOver.AddDynamic(this, &ACardBase::OnCardBeginCursorOver);
    // OnEndCursorOver.AddDynamic(this, &ACardBase::OnCardEndCursorOver);
}

// Called every frame
void ACardBase::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    // if (MoveState != EMoveState::Stop)
    // {
    Move();
    // }
}

void ACardBase::Init(FCardData InCardData)
{
    CardData = InCardData;
    ID = CardData.CardID;
    FString TexturePath = "/Game/Texture" / InCardData.Type / InCardData.Texture;
    TexturePath = "Texture2D'" + TexturePath + "." + InCardData.Texture + "'";
    UTexture2D* Texture2D = LoadObject<UTexture2D>(nullptr, *TexturePath);
    UMaterial* Material = StaticMesh->GetMaterial(0)->GetMaterial();
    if (Material && Texture2D)
    {
        if (UMaterialInstanceDynamic* InstanceDynamic = UMaterialInstanceDynamic::Create(Material, this))
        {
            InstanceDynamic->SetTextureParameterValue(FName("CardImage"), Texture2D);
            StaticMesh->SetMaterial(0, InstanceDynamic);
        }
    }
}

void ACardBase::Init(const int& CardID)
{
    CardData = UDataManager::GetCardData(CardID);
    Init(CardData);
}

#if WITH_EDITOR
void ACardBase::Init()
{
    const FName RowID = FName(*FString::FromInt(ID));
    const FString ContextString = TEXT("FCardData::FindCardData");
    if (IsValid(CardDataTable))
    {
        const FCardData* Data = CardDataTable->FindRow<FCardData>(RowID, ContextString);
        Init(*Data);
    }
    else
    {
        CardDataTable = LoadObject<UDataTable>(nullptr, UTF8_TO_TCHAR("DataTable'/Game/Table/TB_Cards.TB_Cards'"));
        const FCardData* Data = CardDataTable->FindRow<FCardData>(RowID, ContextString);
        Init(*Data);
    }
}
#endif

void ACardBase::PlayCardMoveAnim(const FTransform& Transform, EMoveState InMoveState)
{
    EndTransform = Transform;
    MoveState = InMoveState;
}

void ACardBase::Move()
{
    // 完全移动到目标位置
    if (MoveState == EMoveState::Stop)
    {
        // 玩家的牌移动结束
        if (CardBelongType == ECardBelongType::PlayerA || CardBelongType == ECardBelongType::PlayerB)
        {
            if (OnInitAllCardsMoveEnd.IsBound())
            {
                OnInitAllCardsMoveEnd.Execute();
                OnInitAllCardsMoveEnd.Unbind();
            }
        }

        // 公共卡池的牌移动结束
        if (CardBelongType == ECardBelongType::PublicShow)
        {
            if (OnInitPublicCardsDealEnd.IsBound())
            {
                OnInitPublicCardsDealEnd.Execute();
                OnInitPublicCardsDealEnd.Unbind();
            }
        }
    }
    else if (MoveState == EMoveState::MoveTransform)
    {
        FTransform CurrentTransform = GetActorTransform();
        const FVector CurrentLocation = CurrentTransform.GetLocation();
        const FVector EndLocation = EndTransform.GetLocation();
        const FVector NewLocation = FMath::VInterpTo(CurrentLocation, EndLocation, GetWorld()->GetDeltaSeconds(), CardMoveSpeed);

        const FVector CurrentRotation = CurrentTransform.GetRotation().Euler();
        const FVector EndRotation = EndTransform.GetRotation().Euler();
        const FVector NewRotation = FMath::VInterpTo(CurrentRotation, EndRotation, GetWorld()->GetDeltaSeconds(), CardMoveSpeed);
        CurrentTransform.SetLocation(NewLocation);
        CurrentTransform.SetRotation(FQuat::MakeFromEuler(NewRotation));
        SetActorTransform(CurrentTransform);
        if (NewLocation.Equals(EndLocation, 0.05f) && NewRotation.Equals(EndRotation, 0.05f))
        {
            MoveState = EMoveState::Stop;
        }
    }
    else if (MoveState == EMoveState::MoveTransition)
    {
        FTransform CurrentTransform = GetActorTransform();
        const FVector CurrentLocation = CurrentTransform.GetLocation();
        const FVector EndLocation = EndTransform.GetLocation();
        const FVector NewLocation = FMath::VInterpTo(CurrentLocation, EndLocation, GetWorld()->GetDeltaSeconds(), CardMoveSpeed);
        CurrentTransform.SetLocation(NewLocation);
        SetActorTransform(CurrentTransform);
        if (NewLocation.Equals(EndLocation, 0.05f))
        {
            MoveState = EMoveState::Stop;
        }
    }
    else if (MoveState == EMoveState::MoveRotation)
    {
        FTransform CurrentTransform = GetActorTransform();
        const FVector CurrentRotation = CurrentTransform.GetRotation().Euler();
        const FVector EndRotation = EndTransform.GetRotation().Euler();
        const FVector NewRotation = FMath::VInterpTo(CurrentRotation, EndRotation, GetWorld()->GetDeltaSeconds(), CardMoveSpeed);
        CurrentTransform.SetRotation(FQuat::MakeFromEuler(NewRotation));
        SetActorTransform(CurrentTransform);
        if (NewRotation.Equals(EndRotation, 0.05f))
        {
            MoveState = EMoveState::Stop;
        }
    }
}

void ACardBase::SetFixedTransform(const FTransform& Transform)
{
    FixedTransform = Transform;
}

void ACardBase::BindAllCardInitMoveEnd(UGameManager* GameManager)
{
    // OnInitAllCardsMoveEnd.BindUFunction(GameManager, "OnInitAllCardMoveEndCall");
}

void ACardBase::SetCardBelongType(ECardBelongType InCardBelongType)
{
    CardBelongType = InCardBelongType;
}

void ACardBase::OnCardClick(AActor* ClickedActor, FKey ButtonPressed)
{
    UE_LOG(LogCardBase, Display, TEXT("Current Choose Card ：%s"), *CardData.Name);
    CardData.Dump();
    const FString CardBelongTypeName = UEnum::GetValueAsString<ECardBelongType>(CardBelongType);
    UE_LOG(LogCardBase, Display, TEXT("CardBelongType ：%s"), *CardBelongTypeName);
    if (bChoose)
    {
        bChoose = false;
    }
    else
    {
        bChoose = true;
        OnPlayerChooseCard.Broadcast(this);
    }
}

void ACardBase::OnCardRelease(AActor* Actor, FKey Key)
{
    UE_LOG(LogCardBase, Display, TEXT("OnCardRelease"));
}

void ACardBase::OnCardBeginCursorOver(AActor* Actor)
{
    FTransform Transform = GetTransform();
    FVector Translation = Transform.GetTranslation();
    Translation.Z += 20;
    Transform.SetTranslation(Translation);
    PlayCardMoveAnim(Transform, EMoveState::MoveTransition);
}

void ACardBase::OnCardEndCursorOver(AActor* Actor)
{
    FTransform Transform = GetTransform();
    FVector Translation = Transform.GetTranslation();
    Translation.Z -= 20;
    Transform.SetTranslation(Translation);
    PlayCardMoveAnim(Transform, EMoveState::MoveTransition);
}
