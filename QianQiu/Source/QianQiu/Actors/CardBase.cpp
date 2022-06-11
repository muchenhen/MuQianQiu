// Fill out your copyright notice in the Description page of Project Settings.


#include "CardBase.h"


// Sets default values
ACardBase::ACardBase()
{
    // Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
    PrimaryActorTick.bCanEverTick = true;

    RootComponent = CreateDefaultSubobject<USceneComponent>(TEXT("RootComponent"));

    StaticMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("StaticMesh"));
    AddInstanceComponent(StaticMesh);
    StaticMesh->AttachToComponent(RootComponent, FAttachmentTransformRules::KeepRelativeTransform);
    StaticMesh->SetRelativeScale3D(FVector(1.8, 0.02, 2.4));
    UStaticMesh* Mesh = LoadObject<UStaticMesh>(nullptr, TEXT("StaticMesh'/Engine/BasicShapes/Cube.Cube'"));
    StaticMesh->SetStaticMesh(Mesh);
    UMaterialInstance* Material = LoadObject<UMaterialInstance>(nullptr, TEXT("MaterialInstanceConstant'/Game/Material/MTI_Card.MTI_Card'"));
    StaticMesh->SetMaterial(0, Material->GetMaterial());
    // Init(FCardData());
}

// Called when the game starts or when spawned
void ACardBase::BeginPlay()
{
    Super::BeginPlay();
    
}

// Called every frame
void ACardBase::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void ACardBase::Init(FCardData CardData)
{
    // Texture2D'/Game/Texture/Item/Tex_Item_FengLai.Tex_Item_FengLai'
    FString TexturePath = "/Game/Texture" / CardData.Type / CardData.Texture;
    TexturePath = "Texture2D'" + TexturePath + "." +CardData.Texture+"'";
    UTexture2D* Texture2D = LoadObject<UTexture2D>(nullptr, *TexturePath);
    UMaterial* Material = StaticMesh->GetMaterial(0)->GetMaterial();
    if(Material && Texture2D)
    {
        if(UMaterialInstanceDynamic* InstanceDynamic = UMaterialInstanceDynamic::Create(Material, this))
        {
            InstanceDynamic->SetTextureParameterValue(FName("CardImage"), Texture2D);
            StaticMesh->SetMaterial(0, InstanceDynamic);
        }
    }
}

