<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>데이터베이스 초기화</title>
	<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
</head>

<%@ page import	= "java.lang.*" %>
<%@ page import	= "java.lang.String.*" %>
<%@ page import	= "java.lang.Integer.*" %>
<%@ page import	= "java.sql.*" %>

<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<% request.setCharacterEncoding( "utf-8" ); %>

<body topmargin='20' leftmargin='20'>
<%
	out.println( "CCTV 데이터베이스 테이블 초기화!<br><br>" );


class DbData
{
	///* 내부 개발용.
	protected	String		db_jdbc_driver	= "jdbc:oracle:thin:@localhost:1521:XE";
	protected	String		db_user			= "hr";
	protected	String		db_passwd		= "cube3audi";
	//*/
	/* 개발서버 용.
	protected	String		driver ="oracle.jdbc.driver.OracleDriver";
	protected	String		url ="jdbc:oracle:thin:@10.1.10.50:1521:TESTDB";
	protected	String		db_user			= "menupan";
	protected	String		db_passwd		= "menupan123";
	*/
	/* 서비스 용.
	protected	String		driver ="oracle.jdbc.driver.OracleDriver";
	protected	String		url ="jdbc:oracle:thin:@10.1.110.242:1521:ITIS";
	protected	String		db_user			= "menupan";
	protected	String		db_passwd		= "menupan123";
	*/

	protected	Connection			db_conn		= null;
	protected	Statement			db_stmt		= null;

	/**
	 * Constructors
	 */
	public DbData()
	{
		db_conn			= null;
		db_stmt			= null;
	}

	/**
	 * Getters.
	 */
	public	Connection	getDb_conn() { return db_conn; }
	public	Statement	getDb_stmt() { return db_stmt; }


	/**
	 * Operations.
	 */
	/**
	 * connectDB - Make connection to database.
	 * public.
	 */
	public	boolean	connectDB()
	{
		if ( db_stmt != null )	return true;

		try
		{
			Class.forName( "oracle.jdbc.driver.OracleDriver" );

			// 커넥션 가져오기
			//(1) 내부 개발용
			db_conn		= DriverManager.getConnection( db_jdbc_driver, db_user, db_passwd );
			//(2) 서비스용
			// JEUS JNDI-Configuration  : jdbc/itisDS
		    //db_conn	= JConnectionManager.openConnection("jdbc/menupanDS");
			//(3) 테스트 서비스용.
			// 개발시 아래 사용 후 운영시 JConnectionManager.openConnection();로 변경하길 권장
			//db_conn	= JDriverConnectionManager.getConnection( driver,  url,  db_user,  db_passwd) ;

			db_conn.setAutoCommit( false );

			db_stmt		= db_conn.createStatement();
		}
		catch( Exception ex )
		{
			System.out.println( ex );
			disconnectDB();
		};

		return ( db_stmt != null )? true : false;
	}

	/**
	 * disconnectDB - Make disconnection to database.
	 * public.
	 */
	public	boolean	disconnectDB()
	{
		if ( db_conn == null && db_stmt == null )	return true;

		if ( db_stmt != null )	try { db_stmt.close(); } catch(SQLException ex) { };
		db_stmt	= null;

		if ( db_conn != null )	try { db_conn.close(); } catch(SQLException ex) { };
		db_conn	= null;

		return true;
	}


	/**
	 * beginTransction - Start a transaction.
	 * public.
	 */
	public	void	beginTransction()
	{
	}

	/**
	 * commitTransction - Commit the transaction.
	 * public.
	 */
	public	void	commitTransction()
	{
		if ( db_conn == null )	return;
		try
		{
			db_conn.commit();
		}
		catch( SQLException ex )
		{
			System.out.println( ex );
		};
	}

	/**
	 * rollbackTransction - Rollback the transaction.
	 * public.
	 */
	public	void	rollbackTransction()
	{
		if ( db_conn == null )	return;
		try
		{
			db_conn.rollback();
		}
		catch( SQLException ex )
		{
			System.out.println( ex );
		};
	}
}










	//DB 생성.
	DbData	db	= new DbData();

	//DB 연결.
	db.connectDB();

	
	
	
	
	String	query;
	
	//(0) CCTV URL 목록  테이블
	//(0-1) MGMT_CCTV
	try
	{
		query	= "DROP TABLE MGMT_CCTV";
		db.getDb_stmt().executeUpdate( query );
	}
	catch ( SQLException ex )
	{
		out.println( "<br>[MGMT_CCTV-DROP] " + ex + "<br>" );
	}

	try
	{
		query	= "CREATE TABLE MGMT_CCTV(";
		//query	= query + "CCTV_ID           CHAR(12)          NOT NUL";
		query	= query + "CCTV_ID           CHAR(12)          NULL";
		query	= query + ", CAMERA_NO         NUMBER(5)             NULL";
		query	= query + ", HQ_CODE           VARCHAR2(5)           NULL";
		query	= query + ", BRANCH_CODE       VARCHAR2(5)           NULL";
		query	= query + ", ROUTE_CODE        VARCHAR2(5)           NULL";
		query	= query + ", LOCATION          VARCHAR2(10)          NULL";
		query	= query + ", CAMERA_AREA       VARCHAR2(100)         NULL";
		query	= query + ", ENC_URL           VARCHAR2(100)         NULL";
		query	= query + ", REG_DATE          DATE                  NULL";
		query	= query + ", TRANS_WMS_PORT    NUMBER(10)            NULL";
		query	= query + ", ROAD_ID           VARCHAR2(5)           NULL";
		query	= query + ", ROAD_NAME         VARCHAR2(100)         NULL";
		query	= query + ", MILEPOST          NUMBER(7, 2)          NULL";
		query	= query + ", BOUND             VARCHAR2(30)          NULL";
		query	= query + ", LAT               NUMBER(12, 8)         NULL";
		query	= query + ", LNG               NUMBER(12, 8)         NULL";
		query	= query + ", FILEURL_WMV       VARCHAR2(100)         NULL";
		query	= query + ", FILEURL_MP4       VARCHAR2(100)         NULL";
		query	= query + ", FILEURL_IMG       VARCHAR2(100)         NULL";
		query	= query + ", STAT              CHAR(1)               NULL";
		query	= query + ", ALIVE             CHAR(1)               NULL";
		query	= query + ", LINK_ID_S         VARCHAR2(10)          NULL";
		query	= query + ", LINK_ID_E         NVARCHAR2(10)         NULL";
		query	= query + ", PRIMARY KEY(CCTV_ID) ";
		/*
		*/
		query	= query + " ) ";
		//System.out.println( "query=" + query );
		db.getDb_stmt().executeUpdate( query );
		out.println( "<br>테이블 생성 --> MGMT_CCTV." );
	}
	catch ( SQLException ex )
	{
		out.println( "<br>[MGMT_CCTV] " + ex + "<br>" );
		
		//Rollback the transaction.
		db.rollbackTransction();

		//DB 연결 해제.
		db.disconnectDB();
	}

	//(0-2) CCTV URL 정보
	String	strENCData	= "admin";
	try
	{
		query	= "INSERT INTO MGMT_CCTV(CCTV_ID, ROAD_NAME, FILEURL_WMV, REG_DATE) VALUES( 'cctv00000001', '경부고속도로', '/cctv001/wmv/ch00000001_20101014.102246.592.wmv', sysdate )";
		System.out.println( "query=" + query );
		db.getDb_stmt().executeUpdate( query );

		query	= "INSERT INTO MGMT_CCTV(CCTV_ID, ROAD_NAME, FILEURL_WMV, REG_DATE) VALUES( 'cctv00000002', '영동고속도로', '/cctv002/wmv/ch00000001_20101014.102246.592.wmv', sysdate )";
		System.out.println( "query=" + query );
		db.getDb_stmt().executeUpdate( query );
	}
	catch ( SQLException ex )
	{
		out.println( "<br>[MGMT_CCTV] " + ex + "<br>" );
		
		//Rollback the transaction.
		db.rollbackTransction();

		//DB 연결 해제.
		db.disconnectDB();
	}


	
	

	//Commit the transaction.
	db.commitTransction();

	//DB 연결 해제.
	db.disconnectDB();
%>
	<br><br>
	<a href="oracle_setup_db_main.jsp">돌아가기</a>
</body>
</html>