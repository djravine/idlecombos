;=============================================================================
; DPAPI CREDENTIAL ENCRYPTION TESTS
; Tests for DPAPIEncrypt, DPAPIDecrypt, IsEncryptedHash
; Note: These tests require Windows (DPAPI is a Windows API).
;=============================================================================

class DPAPITests
{
	;=========================================================================
	; Environment probe: DPAPI requires 32-bit AHK + interactive Windows session.
	; Tests that call CryptProtectData skip gracefully when unavailable.
	;=========================================================================

	_CanEncrypt() {
		probe := DPAPIEncrypt("probe")
		return (probe != "" && SubStr(probe, 1, 6) = "DPAPI:")
	}

	;=========================================================================
	; Round-trip: encrypt then decrypt returns original value
	;=========================================================================

	test_RoundTrip_SimpleHash()
	{
		if (!DPAPITests._CanEncrypt())
			return ; DPAPI unavailable in this environment — skip
		original := "abcdef1234567890abcdef1234567890"
		encrypted := DPAPIEncrypt(original)
		Yunit.Assert(encrypted != "", "Encryption should not return empty")
		Yunit.Assert(encrypted != original, "Encrypted value should differ from plaintext")
		decrypted := DPAPIDecrypt(encrypted)
		Yunit.Assert(decrypted = original, "Decrypted should match original, got: " decrypted)
	}

	test_RoundTrip_LongHash()
	{
		if (!DPAPITests._CanEncrypt())
			return
		original := "e5a4f1c2d3b4a5e6f7c8d9b0a1e2f3c4d5a6b7e8f9c0d1a2b3e4f5c6d7a8b9"
		encrypted := DPAPIEncrypt(original)
		decrypted := DPAPIDecrypt(encrypted)
		Yunit.Assert(decrypted = original, "Long hash should survive round-trip")
	}

	test_RoundTrip_SpecialChars()
	{
		if (!DPAPITests._CanEncrypt())
			return
		original := "hash+with/special=chars&more"
		encrypted := DPAPIEncrypt(original)
		decrypted := DPAPIDecrypt(encrypted)
		Yunit.Assert(decrypted = original, "Special chars should survive round-trip")
	}

	;=========================================================================
	; Encrypt output format
	;=========================================================================

	test_Encrypt_HasDPAPIPrefix()
	{
		if (!DPAPITests._CanEncrypt())
			return
		encrypted := DPAPIEncrypt("testhash123")
		Yunit.Assert(SubStr(encrypted, 1, 6) = "DPAPI:", "Encrypted value should start with DPAPI: prefix")
	}

	test_Encrypt_HexAfterPrefix()
	{
		if (!DPAPITests._CanEncrypt())
			return
		encrypted := DPAPIEncrypt("testhash123")
		hexPart := SubStr(encrypted, 7)
		; Verify hex part contains only hex characters
		Yunit.Assert(RegExMatch(hexPart, "^[0-9A-F]+$"), "After prefix should be uppercase hex, got: " SubStr(hexPart, 1, 20))
	}

	;=========================================================================
	; Passthrough for empty/zero values
	;=========================================================================

	test_Encrypt_EmptyString_Passthrough()
	{
		Yunit.Assert(DPAPIEncrypt("") = "", "Empty string should pass through")
	}

	test_Encrypt_Zero_Passthrough()
	{
		Yunit.Assert(DPAPIEncrypt("0") = "0", "Zero string should pass through")
	}

	test_Encrypt_NumericZero_Passthrough()
	{
		Yunit.Assert(DPAPIEncrypt(0) = 0, "Numeric zero should pass through")
	}

	test_Decrypt_EmptyString_Passthrough()
	{
		Yunit.Assert(DPAPIDecrypt("") = "", "Empty string should pass through")
	}

	test_Decrypt_Zero_Passthrough()
	{
		Yunit.Assert(DPAPIDecrypt("0") = "0", "Zero string should pass through")
	}

	;=========================================================================
	; Migration: plaintext passes through decrypt unchanged
	;=========================================================================

	test_Decrypt_Plaintext_Passthrough()
	{
		; A plaintext hash (no DPAPI: prefix) should be returned as-is
		plainHash := "abcdef1234567890"
		Yunit.Assert(DPAPIDecrypt(plainHash) = plainHash, "Plaintext hash should pass through unchanged")
	}

	test_Decrypt_PlaintextLongHash_Passthrough()
	{
		plainHash := "e5a4f1c2d3b4a5e6f7c8d9b0a1e2f3c4"
		Yunit.Assert(DPAPIDecrypt(plainHash) = plainHash, "Plaintext long hash should pass through unchanged")
	}

	;=========================================================================
	; Invalid encrypted data returns empty
	;=========================================================================

	test_Decrypt_InvalidHex_ReturnsEmpty()
	{
		; "DPAPI:" prefix but garbage hex data — should fail gracefully
		Yunit.Assert(DPAPIDecrypt("DPAPI:ZZZZ") = "", "Invalid hex should return empty")
	}

	test_Decrypt_TruncatedData_ReturnsEmpty()
	{
		; "DPAPI:" prefix with too-short data
		Yunit.Assert(DPAPIDecrypt("DPAPI:AB") = "", "Truncated data should return empty")
	}

	test_Decrypt_OddLengthHex_ReturnsEmpty()
	{
		Yunit.Assert(DPAPIDecrypt("DPAPI:ABC") = "", "Odd-length hex should return empty")
	}

	;=========================================================================
	; IsEncryptedHash helper
	;=========================================================================

	test_IsEncrypted_WithPrefix()
	{
		Yunit.Assert(IsEncryptedHash("DPAPI:AABBCC") = true, "DPAPI: prefix should be detected")
	}

	test_IsEncrypted_WithoutPrefix()
	{
		Yunit.Assert(IsEncryptedHash("abcdef123") = false, "Plaintext should not be detected as encrypted")
	}

	test_IsEncrypted_Empty()
	{
		Yunit.Assert(IsEncryptedHash("") = false, "Empty string should not be detected as encrypted")
	}
}
