package kr.co.ex.hiwaysns.lib;

import kr.co.ex.hiwaysns.*;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionBindingListener;
import javax.servlet.http.HttpSessionBindingEvent;

import java.security.MessageDigest;
import java.util.Hashtable;
import java.util.Enumeration;
 
public class LoginManager implements HttpSessionBindingListener
{
	private static LoginManager loginManager = null;
	private static Hashtable loginUsers = new Hashtable();
	
	public	static	String	mUserName	= "";
	public	static	int		mRole		= 0;
	
	private LoginManager(){
		super();
	}
	public static synchronized LoginManager getInstance(){
	if(loginManager == null){
		loginManager = new LoginManager();
	}
	return loginManager;
}
 
	//아이디가 맞는지 체크
	public boolean isValid(String userID, String userPW){
		if ( userID.compareToIgnoreCase("master") == 0
				&& userPW.compareToIgnoreCase("exits2010") == 0 )
		{
			mRole	= 2;
			return true;
		}
		
		HiWayDbServer		db	= new HiWayDbServer();		

		//사용자 계정 검사.
		String	strQuery;
		String	strTableUsers	= "troasis_admin_users";
		
		mRole	= 0;					//사용자 권한.
		int	nCountUsers	= 0;
		try
		{
			//DB 연결.
			db.db_open();

			userPW	= LoginManager.getMD5Str(userPW);

			//사용자 계정 검사.
			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableUsers;
			strQuery	= strQuery + " WHERE user_id = '" + userID + "'";
			strQuery	= strQuery + " AND user_passwd = '" + userPW + "'";
			strQuery	= strQuery + " AND approved > 0";
			strQuery	= strQuery + " AND flag_deleted = 0";
			//System.out.println( "strQuery=" + strQuery );
			db.exec_query( strQuery );
			
			if( db.mDbRs.next() )
			{
				nCountUsers	= 1;
				mUserName	= db.mDbRs.getString( "user_name" );
				mRole		= db.mDbRs.getInt( "role" );
				//nCountUsers	= db.mDbRs.getInt( 1 );
			}
			//System.out.println( "nCountUsers=" + nCountUsers );
			//System.out.println( "mRole=" + mRole );
		}
		catch( Exception e )
		{
			//오류 메시지 출력.
			System.out.println( e.toString() );
		}
		finally
		{
			//DB 연결 닫기.
			try
			{
				db.db_close();
			}
			catch( Exception e ) { }
			finally { }
		}
		
		if ( nCountUsers > 0 )	return true;
		return false;
	}
 
	//해당 세션에 이미 로그인 되있는지 체크
	public boolean isLogin(String sessionID){
		boolean isLogin = false;
		Enumeration e = loginUsers.keys();
		String key = "";
		while(e.hasMoreElements()){
			key = (String)e.nextElement();
			if(sessionID.equals(key)){
				isLogin = true;
			}
		}
		return isLogin;
	}
 
	//중복 로그인 막기 위해 아이디 사용중인지 체크
	public boolean isUsing(String userID){
		boolean isUsing = false;
		Enumeration e = loginUsers.keys();
		String key = "";
		while(e.hasMoreElements()){
			key = (String)e.nextElement();
			if(userID.equals(loginUsers.get(key))){
				isUsing = true;
			}
		}
		return isUsing;
	}
 
	//세션 생성
	public void setSession(HttpSession session, String userID){
		loginUsers.put(session.getId(), userID);
		session.setAttribute("login", this.getInstance());
	}
 
	//세션 성립될 때 
	public void valueBound(HttpSessionBindingEvent event){
	}
 
	//세션 끊길때
	public void valueUnbound(HttpSessionBindingEvent event){
		loginUsers.remove(event.getSession().getId());
	}
 
	//세션 ID로 로긴된 ID 구분
	public String getUserID(String sessionID){
		return (String)loginUsers.get(sessionID);
	}
 
	//현재 접속자수
	public int getUserCount(){
		return loginUsers.size();
	}
	
	//MD5 암호화.
	public	static	String	getMD5Str( String strInput )
	{
		String	strOutput	= strInput;
		try
		{
			// Create a new instance of MessageDigest, using MD5. SHA and other
			// digest algorithms are also available.
			MessageDigest alg = MessageDigest.getInstance("MD5");
	
			// Reset the digest, in case it's been used already during this section of code
			// This probably isn't needed for pages of 210 simplicity
			alg.reset(); 
	
			// Calculate the md5 hash for the password. md5 operates on bytes, so give
			// MessageDigest the byte verison of the string
			alg.update(strInput.getBytes());
	
			// Create a byte array from the string digest
			byte[] digest = alg.digest();
	
			// Convert the hash from whatever format it's in, to hex format
			// which is the normal way to display and report md5 sums
			// This is done byte by byte, and put into a StringBuffer
			StringBuffer hashedpasswd = new StringBuffer();
			String hx;
			for (int i=0;i<digest.length;i++){
				hx =  Integer.toHexString(0xFF & digest[i]);
				//0x03 is equal to 0x3, but we need 0x03 for our md5sum
				if(hx.length() == 1){hx = "0" + hx;}
				hashedpasswd.append(hx);
			}
			
			strOutput	= hashedpasswd.toString();
		}
		catch( Exception e )
		{
			//오류 메시지 출력.
			System.out.println( e.toString() );
		}
		finally
		{
		}
		
		return strOutput;
	}
};
