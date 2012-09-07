package kr.co.ex.hiwaysns;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;

public class Encrypter {
	static Cipher m_encrypter;

	static Cipher m_decrypter;

	public Encrypter() {
		// TODO Auto-generated constructor stub
	}
	
	private static String CORNAME = "excenter";
	private static String SVCNAME = "troasis";

	
	public static String encrypt(String cctvId)
			throws NoSuchAlgorithmException, NoSuchPaddingException,
			InvalidKeyException, IllegalBlockSizeException,
			BadPaddingException, UnsupportedEncodingException {

		String key = "TNM" + padding(cctvId) + "KTICT";
		AesEcb ae = new AesEcb(key);
				
		DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date date = new Date();
		String currentTime = dateFormat.format(date);
		
	
		String input = CORNAME + "," + SVCNAME + "," + cctvId + "," + currentTime;
		
		//System.out.println("input: " + input);
		byte[] plain = input.getBytes();

		byte[] en = ae.encrypt(plain);
		//System.out.println("en: " + en);

		String en64 = Base64Coder.encodeLines(en);
		//System.out.println("en64: " + en64);

		
		  byte[] de64 = Base64Coder.decodeLines(en64);
		  //System.out.println("de64: " + de64);
		  
		  byte[] de = ae.decrypt(de64); 
		  //System.out.println("de: " + de);
		  
		  //System.out.println("input: " + new String(de));
		 

		return en64;
	}

	public static String encrypt(String cctvId, String input)	throws NoSuchAlgorithmException, NoSuchPaddingException,InvalidKeyException, IllegalBlockSizeException,
			BadPaddingException, UnsupportedEncodingException {

		String key = "TNM" + padding(cctvId) + "KTICT";
		AesEcb ae = new AesEcb(key);

		// input = "ABCDEFG HIGKLMSOP 한글입니다  123456789::";
		System.out.println("input: " + input);
		byte[] plain = input.getBytes();

		byte[] en = ae.encrypt(plain);
		System.out.println("en: " + en);

		String en64 = Base64Coder.encodeLines(en);
		System.out.println("en64: " + en64);

		/*
		 * byte[] de64 = Base64Coder.decodeLines(en64);
		 * System.out.println("de64: " + de64);
		 * 
		 * byte[] de = ae.decrypt(de64); System.out.println("de: " + de);
		 * 
		 * System.out.println("input: " + new String(de));
		 */

		return en64;
	}

	private static String padding(String cctvId) {
		int numZeroAdded = 8 - cctvId.length();
		for (int i = 0; i < numZeroAdded; i++) {
			cctvId = "0" + cctvId;
		}
		return cctvId;
	}

}
