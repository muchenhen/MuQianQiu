// Fill out your copyright notice in the Description page of Project Settings.


#include "QianQiuManager.h"

#include "GameFramework/Character.h"
#include "Kismet/GameplayStatics.h"

// Sets default values
AQianQiuManager::AQianQiuManager()
{
 	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

}

// Called when the game starts or when spawned
void AQianQiuManager::BeginPlay()
{
	Super::BeginPlay();
	
}

// Called every frame
void AQianQiuManager::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

}

void AQianQiuManager::LoadMap()
{
    const FLatentActionInfo LatentActionInfo;
    UGameplayStatics::LoadStreamLevel(this, FName(*MapName), true, true, LatentActionInfo);
}

