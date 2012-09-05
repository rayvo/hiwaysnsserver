package kr.co.ex.hiwaysns;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import kr.co.ex.hiwaysns.lib.Job;

public class Encrypter implements Job {
	static Cipher m_encrypter;

	static Cipher m_decrypter;

	public Encrypter() {
		// TODO Auto-generated constructor stub
	}

	public static String encrypt(String cctvId, String input) throws NoSuchAlgorithmException,
			NoSuchPaddingException, InvalidKeyException,
			IllegalBlockSizeException, BadPaddingException, UnsupportedEncodingException {

		String key = "TNM" + padding(cctvId) + "KTICT";
		AesEcb ae = new AesEcb(key);

		// input = "ABCDEFG HIGKLMSOP 한글입니다  123456789::";
		System.out.println("input: " + input);
		byte[] plain = input.getBytes();

		byte[] en = ae.encrypt(plain);
		System.out.println("en: " + en);

		String en64 = Base64Coder.encodeLines(en);
		System.out.println("en64: " + en64);

		/*byte[] de64 = Base64Coder.decodeLines(en64);
		System.out.println("de64: " + de64);

		byte[] de = ae.decrypt(de64);
		System.out.println("de: " + de);

		System.out.println("input: " + new String(de));*/

		return en64;
	}
	
	private static String padding(String cctvId) {
		int numZeroAdded = 8 - cctvId.length();
		for (int i = 0; i<numZeroAdded; i++){
			cctvId = "0" + cctvId;
		}
		return cctvId;
	}

	@Override
	public void execute(JobExecutionContext context)
			throws JobExecutionException {
		System.err.println("Hello!  Encrypter is executing.");

	}

}
