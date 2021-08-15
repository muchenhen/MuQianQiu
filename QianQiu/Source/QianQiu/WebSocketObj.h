// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UObject/NoExportTypes.h"
#include "IWebSocket.h"
#include "slua.h"
#include "WebSocketObj.generated.h"

/**
 * 
 */
UCLASS()
class QIANQIU_API UWebSocketObj : public UObject
{
	GENERATED_BODY()
public:
	UFUNCTION(BlueprintCallable)
		static UWebSocketObj* Create();

public:
	UWebSocketObj();
	~UWebSocketObj();

public:
	void BindLuaCallbackTable(NS_SLUA::lua_State* L, int p);

public:
	UFUNCTION(BlueprintCallable, Category = "Net")
		void Connect(FString Url, FString Protocol);

	UFUNCTION(BlueprintCallable, Category = "Net")
		void Close(int32 Code = 1000, const FString& Reason = "");

	UFUNCTION(BlueprintCallable, Category = "Net")
		void Send(FString Msg);

	void SendBinary(const void* Data, SIZE_T Size);

	UFUNCTION(BlueprintCallable, Category = "Net")
		bool IsConnected();

	UFUNCTION(BlueprintCallable, Category = "Net")
		void ForceAbandon();

protected:
	void DestroySocket();

protected:
	NS_SLUA::LuaVar GetLuaCallback(const char* CallbackName);

protected:
	void OnConnected();
	void OnConnectionError(const FString& Error);
	void OnClosed(int32 StatusCode, const FString& Reason, bool bWasClean);
	void OnMessage(const FString& Message);
	void OnRawMessage(const void* Data, SIZE_T Size, SIZE_T BytesRemaining);

protected:
	TSharedPtr<IWebSocket> Socket;

	NS_SLUA::LuaVar LuaCallbackTable;

	char* RawBuffer;
	SIZE_T CurBufferSize;
	SIZE_T RawStart;

};
