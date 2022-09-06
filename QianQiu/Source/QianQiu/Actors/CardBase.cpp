// Fill out your copyright notice in the Description page of Project Settings.

#include "CardBase.h"

#include "QianQiu/Managers/DataManager.h"

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
    // OnClicked.AddDynamic(this, &ACardBase::OnCardClick);
}

// Called every frame
void ACardBase::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void ACardBase::Init(FCardData InCardData)
{
    // Texture2D'/Game/Texture/Item/Tex_Item_FengLai.Tex_Item_FengLai'
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
    if(IsValid(CardDataTable))
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

// void ACardBase::OnCardClick(AActor* ClickedActor, FKey ButtonPressed)
// {
//     UE_LOG(LogTemp, Display, TEXT("Current Choose Card ："));
// }
