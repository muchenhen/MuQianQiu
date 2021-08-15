#include "WebSocketObj.h"
#include "WebSocketsModule.h"

UWebSocketObj* UWebSocketObj::Create()
{
	UWebSocketObj* Obj = NewObject<UWebSocketObj>();
	return Obj;
}

UWebSocketObj::UWebSocketObj()
{
	RawBuffer = nullptr;
	CurBufferSize = 0;
	RawStart = 0;
}

UWebSocketObj::~UWebSocketObj()
{
	if (RawBuffer)
	{
		delete[] RawBuffer;
	}
}

void UWebSocketObj::BindLuaCallbackTable(NS_SLUA::lua_State* L, int p)
{
	LuaCallbackTable = NS_SLUA::LuaVar(L, p);
}

void UWebSocketObj::Connect(FString Url, FString Protocol)
{
	Socket = FWebSocketsModule::Get().CreateWebSocket(Url, Protocol);
	Socket->OnConnected().AddUObject(this, &UWebSocketObj::OnConnected);
	Socket->OnConnectionError().AddUObject(this, &UWebSocketObj::OnConnectionError);
	Socket->OnClosed().AddUObject(this, &UWebSocketObj::OnClosed);
	Socket->OnMessage().AddUObject(this, &UWebSocketObj::OnMessage);
	Socket->OnRawMessage().AddUObject(this, &UWebSocketObj::OnRawMessage);
	Socket->Connect();
}

void UWebSocketObj::Close(int32 Code, const FString& Reason)
{
	if (Socket.IsValid())
	{
		Socket->Close(Code, Reason);
	}
}

void UWebSocketObj::Send(FString Msg)
{
	Socket->Send(Msg);
}

void UWebSocketObj::SendBinary(const void* Data, SIZE_T Size)
{
	Socket->Send(Data, Size, true);
}

bool UWebSocketObj::IsConnected()
{
	return Socket.IsValid() && Socket->IsConnected();
}

void UWebSocketObj::ForceAbandon()
{
	if (Socket.IsValid())
	{
		Socket->Close();
		DestroySocket();
	}
}

void UWebSocketObj::DestroySocket()
{
	if (Socket.IsValid())
	{
		Socket->OnConnected().Clear();
		Socket->OnConnectionError().Clear();
		Socket->OnClosed().Clear();
		Socket->OnMessage().Clear();
		Socket->OnRawMessage().Clear();
		Socket.Reset();
	}
}

NS_SLUA::LuaVar UWebSocketObj::GetLuaCallback(const char* CallbackName)
{
	if (LuaCallbackTable.isValid() && LuaCallbackTable.isTable())
	{
		NS_SLUA::lua_State* L = LuaCallbackTable.getState();
		LuaCallbackTable.push();
		lua_getfield(L, -1, CallbackName);
		NS_SLUA::LuaVar Res = NS_SLUA::LuaVar(L, -1);
		lua_pop(L, 2);
		return Res;
	}
	return NS_SLUA::LuaVar();
}

void UWebSocketObj::OnConnected()
{
	NS_SLUA::LuaVar LuaCallback = GetLuaCallback("OnConnected");
	if (LuaCallback.isValid())
	{
		LuaCallback.call();
	}
	//OnConnectedEvent.Broadcast();
}

void UWebSocketObj::OnConnectionError(const FString& Error)
{
	NS_SLUA::LuaVar LuaCallback = GetLuaCallback("OnConnectionError");
	if (LuaCallback.isValid())
	{
		LuaCallback.call(Error);
	}
	//OnConnectionErrorEvent.Broadcast(Error);
}

void UWebSocketObj::OnClosed(int32 StatusCode, const FString& Reason, bool bWasClean)
{
	DestroySocket();

	NS_SLUA::LuaVar LuaCallback = GetLuaCallback("OnClosed");
	if (LuaCallback.isValid())
	{
		LuaCallback.call(StatusCode, Reason, bWasClean);
	}
	//OnClosedEvent.Broadcast(StatusCode, Reason, bWasClean);
}

void UWebSocketObj::OnMessage(const FString& Message)
{
	NS_SLUA::LuaVar LuaCallback = GetLuaCallback("OnMessage");
	if (LuaCallback.isValid())
	{
		LuaCallback.call(Message);
	}
	//OnMessageEvent.Broadcast(Message);
}

void UWebSocketObj::OnRawMessage(const void* Data, SIZE_T Size, SIZE_T BytesRemaining)
{
	NS_SLUA::LuaVar LuaCallback = GetLuaCallback("OnRawMessage");
	if (LuaCallback.isValid())
	{
		if (BytesRemaining <= 0)
		{
			if (RawStart == 0)
			{
				NS_SLUA::lua_State* L = LuaCallback.getState();
				LuaCallback.push();
				lua_pushlstring(L, (const char*)Data, Size);
				lua_call(L, 1, 0);
			}
			else
			{
				memcpy(&RawBuffer[RawStart], Data, Size);
				SIZE_T TotalSize = RawStart + Size;
				RawStart = 0;
				NS_SLUA::lua_State* L = LuaCallback.getState();
				LuaCallback.push();
				lua_pushlstring(L, RawBuffer, TotalSize);
				lua_call(L, 1, 0);
			}
		}
		else
		{
			if (RawStart == 0)
			{
				SIZE_T TotalSize = RawStart + Size + BytesRemaining;
				if (CurBufferSize < TotalSize)
				{
					if (RawBuffer)
					{
						delete[] RawBuffer;
					}
					RawBuffer = new char[TotalSize];
				}
				memset(RawBuffer, 0, CurBufferSize);
			}
			memcpy(&RawBuffer[RawStart], Data, Size);
			RawStart += Size;
		}
	}
	//OnRawMessageEvent.Broadcast(Data, Size, BytesRemaining);
}
