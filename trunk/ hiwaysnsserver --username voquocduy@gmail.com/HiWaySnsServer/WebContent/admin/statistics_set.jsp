<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/list_server_db.jsp"  %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.*"	%>
<%@	page	import = "java.util.*" %>
<%@ page	import = "java.text.*" %>
<% LoginManager loginManager = LoginManager.getInstance(); %>
<%
	if( loginManager.isLogin(session.getId()) == false )	//세션 아이디가 로그인 중이 아니라면
	{
		response.sendRedirect("../admin/index.jsp");
		if ( true )	return;
	}
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>TrOASIS 운영 및 관리 홈페이지</title>
</head>
<script type="text/javascript">
//<!--
	//데이터를 Excel 파일로 내려받기.
	function	js_export_data( url_target )
	{
		var frm_input	= document.form_main;
		frm_input.action	= url_target;
		frm_input.target	= "_blank";
		frm_input.submit();
		return( true );
	}
//-->
</script>
<body>
	<table cellpadding="0" cellspacing="0" border="0" width="1050">
		<!-- 	(시작) 헤더.	-->
		<%@ include file="../admin/common_header.jsp"  %>
		<!-- 	(끝) 헤더.	-->
		
		<tr height="600">
			<!-- 	(시작) 메뉴영역.	-->
		<%
			//System.out.println( "loginManager.mRole=" + loginManager.mRole );
			if ( loginManager.mRole < 1 )
			{
				//운영자 메뉴 표현.
		%>
			<!-- 	(시작) 운영자 메뉴.	-->
			<%@ include file="../admin/common_left_menu.jsp"  %>
			<!-- 	(끝) 운영자 메누.	-->

		<%
			}
			else
			{
				//관리자 메뉴 표현.
		%>
			<!-- 	(시작) 관리자 메뉴.	-->
			<%@ include file="../admin/common_left_menu_admin.jsp"  %>
			<!-- 	(끝) 관리자 메누.	-->
		<%
			}
		%>
			<!-- 	(끝) 메뉴영역.	-->

			<td width="40"></td>

			<!-- 	(시작) 작업영역.	-->
			<td width="860" valign="top" align="center">
				<form name="form_main" method="post">
				<table cellpadding="0" cellspacing="0" border="0" width="100%">
					<tr height="10"><td colspan="10"></td></tr>
					<tr>
						<td colspan="10" height="40" align="center" bgcolor="#dbdbdb">
							<font style="font-size:11pt; color:#ff5900; line-height:22px">Set별  이용현황</font>
						</td>
					</tr>
					<tr><td colspan="10" height="5"></td></tr>
					<tr>
						<td align="center"><strong>Set DB 서버</strong></td>
						<td align="center"><strong>접속자 수(명)</strong></td>
						<td align="center"><strong>로그인 수(회)</strong></td>
						<td align="center"><strong>등록 메시지 수(개)</strong></td>
						<td align="center">(1)문자 메시지</td>
						<td align="center">(2)사진 메시지</td>
						<td align="center">(3)음성 메시지</td>
						<td align="center">(4)동영상 메시지 </td>
						<td align="center">(5)사용자 교통정보</td>
						<td align="center"><strong>서비스 방문수(회)</strong></td>
					</tr>
					<tr><td colspan="10" height="5"></td></tr>
					<tr><td colspan="10" height="5" bgcolor="#dbdbdb"></td></tr>
					<tr><td colspan="10" height="5"></td></tr>

<%
	NumberFormat	nf	= NumberFormat.getNumberInstance();

	int[]		list_user			= new int[10];
	int[]		list_login			= new int[10];
	int[]		list_message		= new int[10];
	int[]		list_msg_text		= new int[10];
	int[]		list_msg_picture	= new int[10];
	int[]		list_msg_audio		= new int[10];
	int[]		list_msg_video		= new int[10];
	int[]		list_msg_traffic	= new int[10];
	int[]		list_page_view		= new int[10];

	String[]	list_str_user			= new String[10];
	String[]	list_str_login			= new String[10];
	String[]	list_str_message		= new String[10];
	String[]	list_str_msg_text		= new String[10];
	String[]	list_str_msg_picture	= new String[10];
	String[]	list_str_msg_audio		= new String[10];
	String[]	list_str_msg_video		= new String[10];
	String[]	list_str_msg_traffic	= new String[10];
	String[]	list_str_page_view		= new String[10];

	
	int			sum_user			= 0;
	int			sum_login			= 0;
	int			sum_message			= 0;
	int			sum_msg_text		= 0;
	int			sum_msg_picture		= 0;
	int			sum_msg_audio		= 0;
	int			sum_msg_video		= 0;
	int			sum_msg_traffic		= 0;
	int			sum_page_view		= 0;

	for ( int i = 0; i < mServerListDB.length; i++ )
	{
		HiWayDbServer		db	= new HiWayDbServer( mServerListDB[i] );		
		try
		{
			//DB 연결.
			db.db_open();
	
			String	query;
			list_user[i]			= 0;
			list_login[i]			= 0;
			list_message[i]			= 0;
			list_msg_text[i]		= 0;
			list_msg_picture[i]		= 0;
			list_msg_audio[i]		= 0;
			list_msg_video[i]		= 0;
			list_msg_traffic[i]		= 0;
			list_page_view[i]		= 0;

			//데이터베이스에서 Active 사용자 목록의 개수 읽어오기.
			query	= "SELECT COUNT(DISTINCT user_id), COUNT(user_id)  FROM troasis_active";
			//query	= query + " WHERE flag_deleted = 0 ";		
			db.exec_query( query );
			if( db.mDbRs.next() )
			{
				list_user[i]	= db.mDbRs.getInt( 1 );
				list_login[i]	= db.mDbRs.getInt( 2 );
			}
			
			//데이터베이스에서 등록된 메시지 개수 읽어오기.
			query	= "SELECT COUNT(*)  FROM troasis_user_msg";
			//query	= query + " WHERE flag_deleted = 0 ";		
			db.exec_query( query );
			if( db.mDbRs.next() )
			{
				list_message[i]		= db.mDbRs.getInt( 1 );
			}

			//데이터베이스에서 등록된 메시지(문자) 개수 읽어오기.
			query	= "SELECT COUNT(*)  FROM troasis_user_msg";
			query	= query + " WHERE type_level_2 = " + TrOasisConstants.TYPE_2_USER_SNS;		
			query	= query + " AND type_etc = " + TrOasisConstants.TYPE_ETC_NONE;		
			db.exec_query( query );
			if( db.mDbRs.next() )
			{
				list_msg_text[i]		= db.mDbRs.getInt( 1 );
			}
			//데이터베이스에서 등록된 메시지(사진) 개수 읽어오기.
			query	= "SELECT COUNT(*)  FROM troasis_user_msg";
			query	= query + " WHERE type_level_2 = " + TrOasisConstants.TYPE_2_USER_SNS;		
			query	= query + " AND type_etc = " + TrOasisConstants.TYPE_ETC_PICTURE;		
			db.exec_query( query );
			if( db.mDbRs.next() )
			{
				list_msg_picture[i]		= db.mDbRs.getInt( 1 );
			}
			//데이터베이스에서 등록된 메시지(음성) 개수 읽어오기.
			query	= "SELECT COUNT(*)  FROM troasis_user_msg";
			query	= query + " WHERE type_level_2 = " + TrOasisConstants.TYPE_2_USER_SNS;		
			query	= query + " AND type_etc = " + TrOasisConstants.TYPE_ETC_VOICE;		
			db.exec_query( query );
			if( db.mDbRs.next() )
			{
				list_msg_audio[i]		= db.mDbRs.getInt( 1 );
			}
			//데이터베이스에서 등록된 메시지(동영상) 개수 읽어오기.
			query	= "SELECT COUNT(*)  FROM troasis_user_msg";
			query	= query + " WHERE type_level_2 = " + TrOasisConstants.TYPE_2_USER_SNS;		
			query	= query + " AND type_etc = " + TrOasisConstants.TYPE_ETC_MOTION;		
			db.exec_query( query );
			if( db.mDbRs.next() )
			{
				list_msg_video[i]		= db.mDbRs.getInt( 1 );
			}
			//데이터베이스에서 등록된 메시지(사용자 교통정보) 개수 읽어오기.
			query	= "SELECT COUNT(*)  FROM troasis_user_msg";
			query	= query + " WHERE type_level_2 <> " + TrOasisConstants.TYPE_2_USER_SNS;		
			db.exec_query( query );
			if( db.mDbRs.next() )
			{
				list_msg_traffic[i]		= db.mDbRs.getInt( 1 );
			}

			//데이터베이스에서 등록된 Page View 읽어오기.
			query	= "SELECT COUNT(*)  FROM troasis_log";
			//query	= query + " WHERE flag_deleted = 0 ";		
			db.exec_query( query );
			if( db.mDbRs.next() )
			{
				list_page_view[i]	= db.mDbRs.getInt( 1 );
			}

			list_str_user[i]			= nf.format( list_user[i] );
			list_str_login[i]			= nf.format( list_login[i] );
			list_str_message[i]			= nf.format( list_message[i] );
			list_str_msg_text[i]		= nf.format( list_msg_text[i] );
			list_str_msg_picture[i]		= nf.format( list_msg_picture[i] );
			list_str_msg_audio[i]		= nf.format( list_msg_audio[i] );
			list_str_msg_video[i]		= nf.format( list_msg_video[i] );
			list_str_msg_traffic[i]		= nf.format( list_msg_traffic[i] );
			list_str_page_view[i]		= nf.format( list_page_view[i] );

			//통계처리.
			sum_user			= sum_user + list_user[i];
			sum_login			= sum_login + list_login[i];
			sum_message			= sum_message + list_message[i];
			sum_msg_text		= sum_msg_text + list_msg_text[i];
			sum_msg_picture		= sum_msg_picture + list_msg_picture[i];
			sum_msg_audio		= sum_msg_audio + list_msg_audio[i];
			sum_msg_video		= sum_msg_video + list_msg_video[i];
			sum_msg_traffic		= sum_msg_traffic + list_msg_traffic[i];
			sum_page_view		= sum_page_view + list_page_view[i];

			if ( i > 0 )
			{
%>
					<tr><td colspan="10" height="2"></td></tr>
					<tr><td colspan="10" height="1" bgcolor="#dbdbdb"></td></tr>
					<tr><td colspan="10" height="2"></td></tr>
<%
			}
%>
					<tr>
						<td align="center"><strong><%=mServerListDB[i] %></strong></td>
						<td align="center"><strong><%=list_str_user[i] %></strong></td>
						<td align="center"><strong><%=list_str_login[i] %></strong></td>
						<td align="center"><strong><%=list_str_message[i] %></strong></td>
						<td align="center"><%=list_str_msg_text[i] %></td>
						<td align="center"><%=list_str_msg_picture[i] %></td>
						<td align="center"><%=list_str_msg_audio[i] %></td>
						<td align="center"><%=list_str_msg_video[i] %></td>
						<td align="center"><%=list_str_msg_traffic[i] %></td>
						<td align="center"><strong><%=list_str_page_view[i] %></strong></td>
					</tr>
<%
		}
		catch( Exception e )
		{
			//완료 메시지.
			out.println( "<br><br>["+ mServerListDB[i] + "] 사용자 이용현황을 읽어오는 과정에서 오류가 발생 했습니다." );
			System.out.println( e );
		}
		finally
		{
			//DB 연결 닫기.
			db.db_close();
		}
	}

	String	str_sum_user			= nf.format( sum_user );
	String	str_sum_login			= nf.format( sum_login );
	String	str_sum_message			= nf.format( sum_message );
	String	str_sum_msg_text		= nf.format( sum_msg_text );
	String	str_sum_msg_picture		= nf.format( sum_msg_picture );
	String	str_sum_msg_audio		= nf.format( sum_msg_audio );
	String	str_sum_msg_video		= nf.format( sum_msg_video );
	String	str_sum_msg_traffic		= nf.format( sum_msg_traffic );
	String	str_sum_page_view		= nf.format( sum_page_view );
%>
					<!-- 
					<tr><td colspan="10" height="2"></td></tr>
					<tr><td colspan="10" height="1" bgcolor="#dbdbdb"></td></tr>
					<tr><td colspan="10" height="2"></td></tr>
					 -->
					<tr><td colspan="10" height="5"></td></tr>
					<tr><td colspan="10" height="5" bgcolor="#dbdbdb"></td></tr>
					<tr><td colspan="10" height="5"></td></tr>
					<tr>
						<td align="center"><strong>합계</strong></td>
						<td align="center"><strong><%=str_sum_user %></strong></td>
						<td align="center"><strong><%=str_sum_login %></strong></td>
						<td align="center"><strong><%=str_sum_message %></strong></td>
						<td align="center"><strong><%=str_sum_msg_text %></strong></td>
						<td align="center"><strong><%=str_sum_msg_picture %></strong></td>
						<td align="center"><strong><%=str_sum_msg_audio %></strong></td>
						<td align="center"><strong><%=str_sum_msg_video %></strong></td>
						<td align="center"><strong><%=str_sum_msg_traffic %></strong></td>
						<td align="center"><strong><%=str_sum_page_view %></strong></td>
					</tr>


					<tr><td colspan="10" height="5"></td></tr>
					<tr><td colspan="10" height="5" bgcolor="#dbdbdb"></td></tr>
					<tr><td colspan="10" height="5"></td></tr>
					
					<tr height="10"><td colspan="10"></td></tr>
					<tr>
						<td colspan="10" height="40" align="right">
							<input type="button" id="excel" name="excel" value="Excel 파일로 내려받기" onclick="js_export_data('statistics_set_excel.jsp');" onkeypress="js_export_data('statistics_set_excel.jsp');">
						</td>
					</tr>
					
					<tr>
						<td width="100"></td>
						<td width="90"></td>
						<td width="90"></td>
						<td width="90"></td>
						<td width="80"></td>
						<td width="80"></td>
						<td width="80"></td>
						<td width="80"></td>
						<td width="80"></td>
						<td width="90"></td>
					</tr>
				</table>
				</form>
			</td>
			<!-- 	(끝) 작업영역.	-->
		</tr>
		
		<!-- 	(시작) Footer.	-->
		<%@ include file="../admin/common_footer.jsp"  %>
		<!-- 	(끝) Footer.	-->
	</table>
</body>
</html>