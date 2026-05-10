;=============================================================================
; MOCK SERVER CALL TESTS (P3-27)
;=============================================================================

class MockServerTests
{
	class SetAndClear
	{
		test_SetMockServerCall_EnablesFlag()
		{
			ClearMockServerCall()
			SetMockServerCall("{""success"":1}")
			Yunit.Assert(MockServerCallEnabled = true, "SetMockServerCall should set MockServerCallEnabled to true")
		}

		test_SetMockServerCall_StoresResponse()
		{
			ClearMockServerCall()
			SetMockServerCall("{""success"":1,""data"":""test""}")
			Yunit.Assert(MockServerCallResponse = "{""success"":1,""data"":""test""}", "SetMockServerCall should store the response string")
		}

		test_ClearMockServerCall_DisablesFlag()
		{
			SetMockServerCall("{""ok"":1}")
			ClearMockServerCall()
			Yunit.Assert(MockServerCallEnabled = false, "ClearMockServerCall should set MockServerCallEnabled to false")
		}

		test_ClearMockServerCall_ClearsResponse()
		{
			SetMockServerCall("{""ok"":1}")
			ClearMockServerCall()
			Yunit.Assert(MockServerCallResponse = "", "ClearMockServerCall should clear MockServerCallResponse")
		}

		test_DefaultState_MockDisabled()
		{
			ClearMockServerCall()
			Yunit.Assert(MockServerCallEnabled = false, "MockServerCallEnabled should be false after ClearMockServerCall")
			Yunit.Assert(MockServerCallResponse = "", "MockServerCallResponse should be empty after ClearMockServerCall")
		}

		test_SetMockServerCall_EmptyResponse()
		{
			ClearMockServerCall()
			SetMockServerCall("")
			Yunit.Assert(MockServerCallEnabled = true, "SetMockServerCall with empty response should still enable mock")
			Yunit.Assert(MockServerCallResponse = "", "Empty response should be stored as empty string")
			ClearMockServerCall()
		}
	}
}
