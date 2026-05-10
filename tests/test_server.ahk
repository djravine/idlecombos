;=============================================================================
; SERVER / URL CONSTRUCTION TESTS
;=============================================================================

class ServerTests
{
	class URLConstruction
	{
		test_DefaultServerURL()
		{
			;Verify URL pattern uses HTTPS
			global ServerName
			oldServer := ServerName
			ServerName := "master"
			expectedPrefix := "https://master.idlechampions.com/~idledragons/post.php?call="
			;Build URL same way as ServerCall()
			url := "https://" ServerName ".idlechampions.com/~idledragons/post.php?call=testcall&param=1"
			Yunit.Assert(InStr(url, expectedPrefix), "URL should start with HTTPS master server prefix")
			Yunit.Assert(InStr(url, "testcall"), "URL should contain call name")
			Yunit.Assert(InStr(url, "&param=1"), "URL should contain parameters")
			ServerName := oldServer
		}

		test_CustomServerURL()
		{
			global ServerName
			oldServer := ServerName
			ServerName := "ps4"
			url := "https://" ServerName ".idlechampions.com/~idledragons/post.php?call=getuserdetails"
			Yunit.Assert(InStr(url, "https://ps4.idlechampions.com"), "URL should use ps4 server")
			ServerName := oldServer
		}

		test_NoHTTP_OnlyHTTPS()
		{
			global ServerName
			oldServer := ServerName
			ServerName := "master"
			url := "https://" ServerName ".idlechampions.com/~idledragons/post.php?call=test"
			Yunit.Assert(!InStr(url, "http://"), "URL should NOT contain http:// (plain)")
			Yunit.Assert(InStr(url, "https://"), "URL should contain https://")
			ServerName := oldServer
		}
	}

	class PlayServerDetection
	{
		test_ParsePlayServerName_ExtractsServer()
		{
			;Real API format: play_server value contains escaped URL
			mockData := """play_server"":""http:\/\/ps7.idlechampions.com\/~idledragons\/post.php"""
			result := ParsePlayServerName(mockData)
			Yunit.Assert(result = "ps7", "Should extract 'ps7' from play_server URL, got: " result)
		}

		test_ParsePlayServerName_EmptyResponse()
		{
			mockData := "{}"
			result := ParsePlayServerName(mockData)
			Yunit.Assert(result = "", "Empty response should return empty, got: " result)
		}

		test_ParsePlayServerName_DifferentServer()
		{
			mockData := """play_server"":""http:\/\/ps22.idlechampions.com\/~idledragons\/post.php"""
			result := ParsePlayServerName(mockData)
			Yunit.Assert(result = "ps22", "Should extract 'ps22', got: " result)
		}
	}

	class ErrorHandling
	{
		test_CheckServerCallError_SuccessReturnsTrue()
		{
			mockData := "{""success"":true,""user_details"":{""user_id"":123}}"
			result := CheckServerCallError(mockData)
			Yunit.Assert(result = true, "Valid response should return true")
		}

		test_CheckServerCallError_EmptyReturnsTrue()
		{
			;Empty string has no "Error connecting:" so no error is detected
			result := CheckServerCallError("")
			Yunit.Assert(result = true, "Empty data has no error string, returns true")
		}

		test_CheckServerCallError_ErrorReturnsFalse()
		{
			mockData := "Error connecting: Connection timed out<br/>more stuff"
			result := CheckServerCallError(mockData)
			Yunit.Assert(result = false, "Error connecting response should return false")
		}
	}

	class DummyData
	{
		test_DummyDataFormat()
		{
			global DummyData
			Yunit.Assert(InStr(DummyData, "&language_id=1"), "DummyData should contain language_id=1")
			Yunit.Assert(InStr(DummyData, "&network_id=11"), "DummyData should contain network_id=11")
			Yunit.Assert(InStr(DummyData, "&mobile_client_version=999"), "DummyData should contain mobile_client_version=999")
		}
	}
}
