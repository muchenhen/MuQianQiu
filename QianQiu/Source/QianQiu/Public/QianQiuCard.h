// 卡面类

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Pawn.h"
#include "QianQiuCard.generated.h"

UCLASS()
class QIANQIU_API AQianQiuCard : public AActor
{
	GENERATED_BODY()

public:
	// Sets default values for this pawn's properties
	AQianQiuCard();

    // UPROPERTY(EditAnywhere)
    // UObject* CardObj = LoadObject<UObject>(nullptr, )
protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

public:	
	// Called every frame
	virtual void Tick(float DeltaTime) override;

	// Called to bind functionality to input

};
