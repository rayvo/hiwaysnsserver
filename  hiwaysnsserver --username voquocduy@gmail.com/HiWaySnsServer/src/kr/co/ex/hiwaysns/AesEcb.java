package kr.co.ex.hiwaysns;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;

import java.security.Key;

import java.security.NoSuchAlgorithmException;

import javax.crypto.BadPaddingException;

import javax.crypto.Cipher;

import javax.crypto.IllegalBlockSizeException;

import javax.crypto.NoSuchPaddingException;

import javax.crypto.spec.SecretKeySpec;

public class AesEcb

{

	private byte[] sessionKey = new byte[]{1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6};

	private final String transformation = "AES/ECB/PKCS5Padding";

	// private final String transformation = "AES/ECB/NoPadding";

	private final Key keySpec;

	private final Cipher cipherEncrypt;

	private final Cipher cipherDecrypt;
	
	

	public AesEcb(String key) throws NoSuchAlgorithmException, NoSuchPaddingException,
			InvalidKeyException, UnsupportedEncodingException

	{

		 //sessionKey = { 25 , 109 , 105 , 115 , 25 , 25 , 111 , 117 , 104 , 97 , 110 , 103 , 101 , 37 , 110 , 97 };

		//sessionKey = AesEcb.hex2byte("f4150d4a1ac5708c29e437749045a39a");
		byte[] tmp = AesEcb.padByte(key.getBytes());
		//sessionKey = key.getBytes("UTF-16");
		///sessionKey = AesEcb.hex2byte(key);
		// sessionKey = AesEcb.hex2byte("f4150d4a1ac5708c29e437749045a39a");
				
		for(int i=0; i < 16; i++) {
			sessionKey[i] = tmp[i];
		}		

		keySpec = new SecretKeySpec(sessionKey, "AES");

		cipherEncrypt = Cipher.getInstance(transformation);

		cipherEncrypt.init(Cipher.ENCRYPT_MODE, keySpec);

		cipherDecrypt = Cipher.getInstance(transformation);

		cipherDecrypt.init(Cipher.DECRYPT_MODE, keySpec);

	}

	public byte[] encrypt(byte[] plain) throws IllegalBlockSizeException,
			BadPaddingException

	{

		byte[] encrypt = cipherEncrypt.doFinal(plain);

		// byte[] encrypt = cipher.doFinal( AesEcb.padByte( plain ) );

		System.out.println("(" + encrypt.length + ")" + "암호 : "
				+ AesEcb.toHexString(encrypt));

		return encrypt;

	}

	public byte[] decrypt(byte[] encrypt) throws IllegalBlockSizeException,
			BadPaddingException

	{

		byte[] decrypt = cipherDecrypt.doFinal(encrypt);

		System.out.println("(" + decrypt.length + ")" + "복호 : "
				+ AesEcb.toHexString(decrypt));

		return decrypt;

	}

	public static byte[] hex2byte(String hex) throws IllegalArgumentException

	{

		if (hex.length() % 2 != 0)

		{

			throw new IllegalArgumentException();

		}

		char[] arr = hex.toCharArray();

		byte[] b = new byte[hex.length() / 2];

		for (int i = 0, j = 0, l = hex.length(); i < l; i++, j++)

		{

			String swap = "" + arr[i++] + arr[i];

			int byteint = Integer.parseInt(swap, 16) & 0xFF;

			b[j] = new Integer(byteint).byteValue();

		}

		return b;

	}

	public static String toHexString(byte[] bytes)

	{

		if (bytes == null)

		{

			return null;

		}

		StringBuffer result = new StringBuffer();

		for (byte b : bytes)

		{

			result.append(Integer.toString((b & 0xF0) >> 4, 16));

			result.append(Integer.toString(b & 0x0F, 16));

		}

		return result.toString();

	}

	public static byte[] padByte(byte[] src)

	{

		int size = 16;

		int x = src.length % size;

		int padLength = size - x;

		byte[] dest = new byte[src.length + padLength];

		System.arraycopy(src, 0, dest, 0, src.length);

		return dest;

	}
}