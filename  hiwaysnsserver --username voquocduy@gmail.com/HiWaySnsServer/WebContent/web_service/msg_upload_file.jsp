<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/config.jsp"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@ page	import ="java.io.*" %>
<%@ page	import ="com.oreilly.servlet.MultipartRequest" %>
<%@ page	import ="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	int		g_max_file_size	= 5 * 1024 * 1024;			// 파일업로드 용량 제한. 5MB

	/*
	 * 사용자 메시지 등록....
	 */
	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[USER MSG UPLOAD MEDIA] Request received!" );
		String	strInputXml;
		String	content_type	= request.getContentType();
		String	media_file = "", file_path;
		File	fdMedia, fdMediaTo;
		//System.out.println( "content_type=" + content_type );
		if ( (content_type != null) && (content_type.indexOf("multipart/form-data") >= 0) )
		{
			int		content_size	= request.getContentLength();

			MultipartRequest	multi	= new MultipartRequest( request, g_path_upload, g_max_file_size, "utf-8", new DefaultFileRenamePolicy() );
			strInputXml	= param.get_input_param( multi.getParameter("xml") );

			//첨부파일 등록, 수정, 삭제.
			media_file	= multi.getFilesystemName( "media" );
			//System.out.println( "media=" + media_file );
			if ( media_file == null )	media_file = "";
		}
		else
		{
			//request.setCharacterEncoding( "utf-8" );
			strInputXml	= param.get_input_param( request.getParameter("xml") );
		}

		//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "active_id", "" },
										{ "user_id", "" },
										{ "message_id", "" },
										{ "media_type", "" }
									};
		int		INDEX_ACTIVE_ID		= 0;
		int		INDEX_USER_ID		= INDEX_ACTIVE_ID + 1;
		int		INDEX_MESSAGE_ID	= INDEX_USER_ID + 1;
		int		INDEX_MEDIA_TYPE	= INDEX_MESSAGE_ID + 1;
	
		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		int		nMessageID		= param.get_param_int( inputList[INDEX_MESSAGE_ID][1] );
		int		nMediaType		= param.get_param_int( inputList[INDEX_MEDIA_TYPE][1] );

		
		/*
		 * 예외조건 검사.
		 */
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
			 * 미디어 파일명 변경.
			 */
			int		file_size = 0;
			String	media_file_to = "", file_path_to = "";
			if ( media_file.length() > 0 )
			{
				//사용자 폴더 검사 및 생성.
				file_path	= g_path_upload + "/" + strUserID;
				File	fd	= new File( file_path );
				if ( fd.exists() == false )	fd.mkdir();
				
				//User ID와 Timestamp를 이용해서 파일이름에서 한글 및 특수문자 처리.
				//파일이름 변경.
				file_path	= g_path_upload + "/" + media_file;
				fdMedia		= new File( file_path );				// 파일 객체생성
				//System.out.println( "name=" + fdMedia.getName() );
				String[]	list_file_info	= fdMedia.getName().split( "[.]" );
				String		file_ext		= list_file_info[list_file_info.length - 1];
				media_file_to	= strUserID + "/" + strUserID + "_" + System.currentTimeMillis() + "." + file_ext;
				file_path_to	= g_path_upload + "/" + media_file_to;
				fdMediaTo	= new File( file_path_to );				// 파일 객체생성
				fdMedia.renameTo( fdMediaTo );
				if ( fdMedia.exists() )	fdMedia.delete();

				//신규 첨부파일 등록 및 수정.
				file_size	= 0;
				if ( media_file_to != null )	file_size = (int)( fdMediaTo.length() );
				file_size	= (file_size / 1024) + 1;
			}
			 
			/*
			 * 응답 메시지 구성.
			 */
			//DB 연결.
			db.db_open();

		 	long	currentTime	= db.getCurrentTimestamp();
	
			//주어진 User ID의 사용자가 존재하는지 검사한다.	
			String	strQuery;
			String	strTableActive1	= "troasis_active";
			String	strTableUserMsg	= "troasis_user_msg";
			
			//메시지의 첨부파일 정보 등록.
			strQuery	= "UPDATE";
			strQuery	= strQuery + " " + strTableUserMsg + " SET";
			strQuery	= strQuery + " type_etc = " + nMediaType + "";
			strQuery	= strQuery + ", link_etc = '" + media_file_to + "'";
			strQuery	= strQuery + ", size_etc = " + file_size + "";
			strQuery	= strQuery + ", time_last_updated = " + currentTime;
			strQuery	= strQuery + " WHERE id = " + nMessageID + "";
			strQuery	= strQuery + " AND log_id = " + strActiveID + "";
			strQuery	= strQuery + " AND flag_deleted = 0";

			db.exec_update( strQuery );
		}
		
		//응답 메시지 정보.
		String[][]	outputList	=	{
										{ "active_id", strActiveID },
										{ "message_id", String.valueOf(nMessageID) }
									};
//		if ( status_code != 0 )	System.out.println( status_msg );
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code><%=status_code%></status_code>
	<status_msg><%=status_msg%></status_msg>
<%
	for ( int i = 0; i < outputList.length; i++ )
	{
%>
	<<%=outputList[i][0]%>><%=outputList[i][1]%></<%=outputList[i][0]%>>
<%
	}
%>
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
		System.out.println( "[USER MSG UPLOAD MEDIA]" + status_msg );
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