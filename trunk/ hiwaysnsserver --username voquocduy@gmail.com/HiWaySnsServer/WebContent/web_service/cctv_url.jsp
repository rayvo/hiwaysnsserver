<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/config.jsp"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	/*
	 * 회원 목록 제공....
	 */
	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[CCTV URL] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String	strInputXml	= param.get_input_param( request.getParameter("xml") );

		//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "active_id", "" },
										{ "user_id", "" },
										{ "cctv_id", "" },
									};
		int		INDEX_ACTIVE_ID		= 0;
		int		INDEX_USER_ID		= INDEX_ACTIVE_ID + 1;
		int		INDEX_CCTV_ID		= INDEX_USER_ID + 1;
	
		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		
		/*
		 * 예외조건 검사.
		 */
		String	cctv_id	= inputList[INDEX_CCTV_ID][1];
		long	cctv_timestamp	= 0;
		String	url_mp4 = "", url_img	= "";
		String	url_mov_android = "", url_mov_iphone = "", url_img_all	= "";

	
		//(1) User ID가 unique 하지 않은 경우.
		String	strUserID	= inputList[INDEX_USER_ID][1];
		String	strActiveID	= inputList[INDEX_ACTIVE_ID][1];
		
		if ( db.isValidActiveID(strUserID, strActiveID) == false )
		{
			status_code	= db.status_code;
			status_msg	= db.status_msg;
		}
		else
		{
			/*
			 * 응답 메시지 구성.
			 */
			//DB 연결.
			db.db_open();
	
			String	strQuery;
			String	strTableActive	= "troasis_active";
			String	strTableCctv	= "MGMT_CCTV";
			
			/*
			 * CCTV URL 수집.
			 */
			//주어진 CCTV ID에 해당하는 URL 목록 검색.
			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableCctv;
			strQuery	= strQuery + " WHERE CCTV_ID = '" +  cctv_id + "'";
			db.exec_query( strQuery );
			
			while ( db.mDbRs.next() )
			{
				cctv_timestamp	= db.mDbRs.getLong( "cctv_timestamp" );
				url_mp4			= db.mDbRs.getString( "FILEURL_MP4" );
				url_img			= db.mDbRs.getString( "FILEURL_IMG" );
				
				//URL 구성.
				StringTokenizer	split		= null;
				int				count_split	= 0;
				String			strPath		= "";
				
				url_mov_android	= "";
				url_mov_iphone	= "";
				split		= new StringTokenizer( url_mp4, "@/" );
				count_split	= split.countTokens();
				//System.out.println( "count_split=" + count_split );
				if ( count_split >= 2 )
				{
					strPath		= split.nextToken();
					/*
					url_mov_android	= "rtsp://exmobile.hscdn.com:554/exvod/mp4:/";
					url_mov_iphone	= "http://exmobile.hscdn.com:1935/exvod/mp4:/";
					*/
					//url_mov_android	= "rtsp://" + strPath + ":554/exvod/mp4:/";			//2010년 추석이후의 방식.
					url_mov_android	= "http://" + strPath + ":8080";						//2011년 설이후의 방식.
					url_mov_iphone	= "http://" + strPath + ":1935/exvod/mp4:/";
					for( int i = 1; i < count_split; i++ )
					{
						strPath		= split.nextToken();
						url_mov_android	= url_mov_android + "/" + strPath;
						url_mov_iphone	= url_mov_iphone + "/" + strPath;
					}
				}
				
				url_img_all	= "";
				split		= new StringTokenizer( url_img, "@/" );
				count_split	= split.countTokens();
				if ( count_split >= 2 )
				{
					strPath		= split.nextToken();
					//url_img_all		= "http://exmobile4.hscdn.com:8080";
					url_img_all		= "http://" + strPath + ":8080";
					for( int i = 1; i < count_split; i++ )
					{
						strPath		= split.nextToken();
						url_img_all	= url_img_all + "/" + strPath;
					}
				}
			}
		}
		
		//응답 메시지 정보.
		String[][]	outputList	=	{
										{ "active_id", strActiveID }
									};
//		if ( status_code != 0 )	System.out.println( status_msg );
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code><%=status_code%></status_code>
	<status_msg><%=status_msg%></status_msg>
	<active_id><%=strActiveID%></active_id>
	<cctv_id><%=cctv_id%></cctv_id>
	<cctv_timestamp><%=cctv_timestamp%></cctv_timestamp>
	<url_mov_android><%=url_mov_android%></url_mov_android>
	<url_mov_iphone><%=url_mov_iphone%></url_mov_iphone>
	<url_img_all><%=url_img_all%></url_img_all>
</troasis>
<%
		//트랜잭션 Commit.
		db.tran_commit();
	}
	catch( Exception e )
	{
		//트랜잭션 Rollback.
		db.tran_rollback();
		
		//오류 메시지 출력.
		status_msg	= e.toString();
		System.out.println( "[CCTV URL]" + status_msg );
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code>2</status_code>
	<status_msg><%=status_msg%></status_msg>
</troasis>
<%
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>