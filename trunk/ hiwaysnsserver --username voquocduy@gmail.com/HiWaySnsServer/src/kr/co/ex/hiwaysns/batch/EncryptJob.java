package kr.co.ex.hiwaysns.batch;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;

import kr.co.ex.hiwaysns.Encrypter;
import kr.co.ex.hiwaysns.HiWayDbServer;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EncryptJob implements Job {

	private static Logger _log = LoggerFactory.getLogger(EncryptJob.class);

	public EncryptJob() {
	}

	//private final String DBServer = "180.148.181.88";

	private final String DBServer = "127.0.0.1";

	private static String HOST = "http://cctvsec.ktict.co.kr/";

	private String cctvTable = "national_cctv";

	public void execute(JobExecutionContext context)
			throws JobExecutionException {

		boolean flag = true;
		_log.info("CCTV URLs Encryption is executing at " + new Date());

		HiWayDbServer db = null;
		List<String> cctvList = new ArrayList<String>();
		try {
			db = new HiWayDbServer(DBServer);
			db.db_open();

			String strSelectQuery = "SELECT cctv_id FROM " + cctvTable;
			db.exec_query(strSelectQuery);
			while (db.mDbRs.next()) {
				String cctv_id = db.mDbRs.getString("cctv_id");
				cctvList.add(cctv_id);
			}
			db.tran_commit();
		} catch (Exception e) {
			flag = false;
			db.tran_rollback();
			System.out.println(e.toString());
		} finally {
			try {
				db.db_close();
			} catch (Exception e) {

			} finally {
			}
		}

		// Update new encrypted URL to database
		for (int i = 0; i < cctvList.size(); i++) {
			String cctv_id = cctvList.get(i);
			String encryptedText;
			try {
				db.db_open();
				encryptedText = Encrypter.encrypt(cctv_id);
				String encryptedURL = HOST + cctv_id + "/" + encryptedText;

				String strUpdateQuery = " UPDATE " + cctvTable
						+ " SET cctv_url ='" + encryptedURL + "'"
						+ " WHERE cctv_id='" + cctv_id + "'";

				db.exec_update(strUpdateQuery);
				db.db_close();

			} catch (InvalidKeyException e) {
				flag = false;
				e.printStackTrace();
			} catch (NoSuchAlgorithmException e) {
				flag = false;
				e.printStackTrace();
			} catch (NoSuchPaddingException e) {
				flag = false;
				e.printStackTrace();
			} catch (IllegalBlockSizeException e) {
				flag = false;
				e.printStackTrace();
			} catch (BadPaddingException e) {
				flag = false;
				e.printStackTrace();
			} catch (UnsupportedEncodingException e) {
				flag = false;
				e.printStackTrace();
			} catch (Exception e) {
				flag = false;
				e.printStackTrace();
			} finally {
				try {
					db.db_close();
				} catch (Exception e) {
				} finally {
				}
			}
		}
		if (flag) {
			_log.info("123 CCTV URLs have been successfully encrypted at "
					+ new Date());
		} else {
			_log.info("456 CCTV URLs Encryption encountered error at " + new Date());
		}

	}

}
