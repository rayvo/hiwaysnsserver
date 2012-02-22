<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/list_server_db.jsp"  %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page	import = "kr.co.ex.hiwaysns.lib.*"	%>
<%@	page	import = "kr.co.ex.hiwaysns.*"	%>
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
	function	js_calendar_refresh()
	{
		var frm_input	= document.form_main;
		var	n_year_sel	= frm_input.n_year_sel.value;
		var	n_month_sel	= frm_input.n_month_sel.value;
		var	n_date_sel	= frm_input.n_date_sel.value;
		var	obj_param	= "n_year_sel=" + n_year_sel
							+ "&n_month_sel=" + n_month_sel
							+ "&n_date_sel=" + n_date_sel;
		self.location.href	= location.pathname + "?" + obj_param;
		return ( true );
	}
	
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
<%
	//오늘 날짜 구하기.
	Calendar	ctoday	= Calendar.getInstance();
	int		n_year_today	= ctoday.get(Calendar.YEAR);
	int		n_month_today	= ctoday.get(Calendar.MONTH);
	int		n_date_today	= ctoday.get(Calendar.DATE);

	//입력인자 수신.
	int		n_year_sel = 0, n_month_sel = 0, n_date_sel = 0;
	int		i;

	if ( request.getParameter("n_year_sel") != null )
		n_year_sel	= Integer.parseInt( request.getParameter("n_year_sel") );
	if ( request.getParameter("n_month_sel") != null )
		n_month_sel	= Integer.parseInt( request.getParameter("n_month_sel") );
	if ( request.getParameter("n_date_sel") != null )
		n_date_sel	= Integer.parseInt( request.getParameter("n_date_sel") );

	//입력이 없는 경우, 오늘 날짜.
	if ( n_year_sel < 1 || n_month_sel < 1 )
	{
		n_year_sel	= n_year_today;
		n_month_sel	= ctoday.get(Calendar.MONTH) + 1;
	}
	if ( n_date_sel < 1 )	n_date_sel = n_date_today;
%>
			<td width="860" valign="top" align="center">
				<form name="form_main" method="post">
				<table cellpadding="0" cellspacing="0" border="0" width="100%">
					<tr height="10"><td colspan="10"></td></tr>
					<tr>
						<td colspan="10" height="40" align="left" bgcolor="#dbdbdb">
							일별 이용현황을 확인하려는 최근날짜를 선택하세요: &nbsp;&nbsp;&nbsp;
							<select class="combo" id="n_year_sel" name="n_year_sel" style="width: 60px; color:#000000; background-color:#ffffff;">
							<% for ( i = n_year_today - 20; i <= n_year_today + 1; i++ ) { %>
								<option value="<%=i%>" <% if ( n_year_sel == i  ) { %>selected<% } %>><%=i%></option>
							<% } %>
							</select>
							년 &nbsp;&nbsp;&nbsp;
							
							<select class="combo" id="n_month_sel" name="n_month_sel" style="width: 40px; color:#000000; background-color:#ffffff;">
							<% for ( i = 1; i <= 12; i++ ) { %>
								<option value="<%=i%>" <% if ( n_month_sel == i  ) { %>selected<% } %>><%=i%></option>
							<% } %>
							</select>
							월 &nbsp;&nbsp;&nbsp;
							
							<select class="combo" id="n_date_sel" name="n_date_sel" onchange="return js_calendar_refresh()" style="width: 40px; color:#000000; background-color:#ffffff;">
							<% for ( i = 1; i <= 31; i++ ) { %>
								<option value="<%=i%>" <% if ( n_date_sel == i  ) { %>selected<% } %>><%=i%></option>
							<% } %>
							</select>
							일 &nbsp;&nbsp;&nbsp;
						</td>
					</tr>

					<tr height="10"><td colspan="10"></td></tr>
					<tr>
						<td colspan="10" height="40" align="center" bgcolor="#dbdbdb">
							<font style="font-size:11pt; color:#ff5900; line-height:22px">일별  이용현황</font>
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
	//숫자 형식. 
	NumberFormat	nf	= NumberFormat.getNumberInstance();

	//통계 데이터.
	int			nSizeStatistics	= 31;
	int			nCountDB		= 10;

	String[]	sum_date			= new String[nSizeStatistics];
	int[]		sum_user			= new int[nSizeStatistics];
	int[]		sum_login			= new int[nSizeStatistics];
	int[]		sum_message			= new int[nSizeStatistics];
	int[]		sum_msg_text		= new int[nSizeStatistics];
	int[]		sum_msg_picture		= new int[nSizeStatistics];
	int[]		sum_msg_audio		= new int[nSizeStatistics];
	int[]		sum_msg_video		= new int[nSizeStatistics];
	int[]		sum_msg_traffic		= new int[nSizeStatistics];
	int[]		sum_page_view		= new int[nSizeStatistics];
	
	//시간대별 날짜 정보 구하기.
	Calendar	calDate	= Calendar.getInstance();
	calDate.set(n_year_sel, n_month_sel - 1, n_date_sel, 0, 0, 0);

	long	nTimeInSecToday		= 0;
	calDate.add( Calendar.DATE, 1 );
	long	nTimeInSecTomorrow	= calDate.getTimeInMillis() / 1000;
	for ( i = 0; i < nSizeStatistics; i++ )
	{
		calDate.add( Calendar.DATE, -1 );
		nTimeInSecToday	= calDate.getTimeInMillis() / 1000;

		SimpleDateFormat formatter = new SimpleDateFormat( "yyyy년 MM월 dd일", Locale.KOREA );
		sum_date[i]	=  formatter.format ( nTimeInSecToday * 1000 );
		
		//각 DB로부터 데이터 수집.
		int[]	list_user			= new int[nCountDB];
		int[]	list_login			= new int[nCountDB];
		int[]	list_message		= new int[nCountDB];
		int[]	list_msg_text		= new int[nCountDB];
		int[]	list_msg_picture	= new int[nCountDB];
		int[]	list_msg_audio		= new int[nCountDB];
		int[]	list_msg_video		= new int[nCountDB];
		int[]	list_msg_traffic	= new int[nCountDB];
		int[]	list_page_view		= new int[nCountDB];

		String	query;
		for ( int j = 0; j < mServerListDB.length; j++ )
		{
			list_user[j]		= 0;
			list_login[j]		= 0;
			list_message[j]		= 0;
			list_msg_text[j]	= 0;
			list_msg_picture[j]	= 0;
			list_msg_audio[j]	= 0;
			list_msg_video[j]	= 0;
			list_msg_traffic[j]	= 0;
			list_page_view[j]	= 0;

			HiWayDbServer		db	= new HiWayDbServer( mServerListDB[j] );		
			try
			{
				//DB 연결.
				db.db_open();
				
				//데이터베이스에서 Active 사용자 목록의 개수 읽어오기.
				query	= "SELECT COUNT(DISTINCT user_id), COUNT(user_id)  FROM troasis_active";
				//query	= query + " WHERE flag_deleted = 0 ";		
				query	= query + " WHERE time_log_last >= " + nTimeInSecToday;		
				query	= query + " AND time_log_last < " + nTimeInSecTomorrow;	
				//System.out.println( "[query]=" + query );
				db.exec_query( query );
				if( db.mDbRs.next() )
				{
					list_user[j]	= db.mDbRs.getInt( 1 );
					list_login[j]	= db.mDbRs.getInt( 2 );
				}
				
				//데이터베이스에서 등록된 메시지 개수 읽어오기.
				query	= "SELECT COUNT(*)  FROM troasis_user_msg";
				//query	= query + " WHERE flag_deleted = 0 ";		
				query	= query + " WHERE time_log >= " + nTimeInSecToday;		
				query	= query + " AND time_log < " + nTimeInSecTomorrow;	
				//System.out.println( "[query]=" + query );
				db.exec_query( query );
				if( db.mDbRs.next() )
				{
					list_message[j]		= db.mDbRs.getInt( 1 );
				}

				//데이터베이스에서 등록된 메시지(문자) 개수 읽어오기.
				query	= "SELECT COUNT(*)  FROM troasis_user_msg";
				query	= query + " WHERE time_log >= " + nTimeInSecToday;		
				query	= query + " AND time_log < " + nTimeInSecTomorrow;	
				query	= query + " AND type_level_2 = " + TrOasisConstants.TYPE_2_USER_SNS;		
				query	= query + " AND type_etc = " + TrOasisConstants.TYPE_ETC_NONE;		
				db.exec_query( query );
				if( db.mDbRs.next() )
				{
					list_msg_text[j]		= db.mDbRs.getInt( 1 );
				}
				//데이터베이스에서 등록된 메시지(사진) 개수 읽어오기.
				query	= "SELECT COUNT(*)  FROM troasis_user_msg";
				query	= query + " WHERE time_log >= " + nTimeInSecToday;		
				query	= query + " AND time_log < " + nTimeInSecTomorrow;	
				query	= query + " AND type_level_2 = " + TrOasisConstants.TYPE_2_USER_SNS;		
				query	= query + " AND type_etc = " + TrOasisConstants.TYPE_ETC_PICTURE;		
				db.exec_query( query );
				if( db.mDbRs.next() )
				{
					list_msg_picture[j]		= db.mDbRs.getInt( 1 );
				}
				//데이터베이스에서 등록된 메시지(음성) 개수 읽어오기.
				query	= "SELECT COUNT(*)  FROM troasis_user_msg";
				query	= query + " WHERE time_log >= " + nTimeInSecToday;		
				query	= query + " AND time_log < " + nTimeInSecTomorrow;	
				query	= query + " AND type_level_2 = " + TrOasisConstants.TYPE_2_USER_SNS;		
				query	= query + " AND type_etc = " + TrOasisConstants.TYPE_ETC_VOICE;		
				db.exec_query( query );
				if( db.mDbRs.next() )
				{
					list_msg_audio[j]		= db.mDbRs.getInt( 1 );
				}
				//데이터베이스에서 등록된 메시지(동영상) 개수 읽어오기.
				query	= "SELECT COUNT(*)  FROM troasis_user_msg";
				query	= query + " WHERE time_log >= " + nTimeInSecToday;		
				query	= query + " AND time_log < " + nTimeInSecTomorrow;	
				query	= query + " AND type_level_2 = " + TrOasisConstants.TYPE_2_USER_SNS;		
				query	= query + " AND type_etc = " + TrOasisConstants.TYPE_ETC_MOTION;		
				db.exec_query( query );
				if( db.mDbRs.next() )
				{
					list_msg_video[j]		= db.mDbRs.getInt( 1 );
				}
				//데이터베이스에서 등록된 메시지(사용자 교통정보) 개수 읽어오기.
				query	= "SELECT COUNT(*)  FROM troasis_user_msg";
				query	= query + " WHERE time_log >= " + nTimeInSecToday;		
				query	= query + " AND time_log < " + nTimeInSecTomorrow;	
				query	= query + " AND type_level_2 <> " + TrOasisConstants.TYPE_2_USER_SNS;		
				db.exec_query( query );
				if( db.mDbRs.next() )
				{
					list_msg_traffic[j]		= db.mDbRs.getInt( 1 );
				}

				//데이터베이스에서 등록된 Page View 읽어오기.
				query	= "SELECT COUNT(*)  FROM troasis_log";
				//query	= query + " WHERE flag_deleted = 0 ";		
				query	= query + " WHERE time_log >= " + nTimeInSecToday;		
				query	= query + " AND time_log < " + nTimeInSecTomorrow;	
				//System.out.println( "[query]=" + query );
				db.exec_query( query );
				if( db.mDbRs.next() )
				{
					list_page_view[j]	= db.mDbRs.getInt( 1 );
				}

				//통계처리.
				sum_user[i]			= sum_user[i] + list_user[j];
				sum_login[i]		= sum_login[i] + list_login[j];
				sum_message[i]		= sum_message[i] + list_message[j];
				sum_msg_text[i]		= sum_msg_text[i] + list_msg_text[j];
				sum_msg_picture[i]	= sum_msg_picture[i] + list_msg_picture[j];
				sum_msg_audio[i]	= sum_msg_audio[i] + list_msg_audio[j];
				sum_msg_video[i]	= sum_msg_video[i] + list_msg_video[j];
				sum_msg_traffic[i]	= sum_msg_traffic[i] + list_msg_traffic[j];
				sum_page_view[i]	= sum_page_view[i] + list_page_view[j];
			}
			catch( Exception e )
			{
				//완료 메시지.
				out.println( "<br><br>["+ mServerListDB[j] + "] 사용자 통계를 구하는 과정에서 오류가 발생 했습니다." );
				System.out.println( e );
			}
			finally
			{
				//DB 연결 닫기.
				db.db_close();
			}
		}
		
		//Timestamp 변경.
		nTimeInSecTomorrow	= nTimeInSecToday;
	
		//출력 데이터 생성.
		String	str_sum_user			= nf.format( sum_user[i] );
		String	str_sum_login			= nf.format( sum_login[i] );
		String	str_sum_message			= nf.format( sum_message[i] );
		String	str_sum_msg_text		= nf.format( sum_msg_text[i] );
		String	str_sum_msg_picture		= nf.format( sum_msg_picture[i] );
		String	str_sum_msg_audio		= nf.format( sum_msg_audio[i] );
		String	str_sum_msg_video		= nf.format( sum_msg_video[i] );
		String	str_sum_msg_traffic		= nf.format( sum_msg_traffic[i] );
		String	str_sum_page_view		= nf.format( sum_page_view[i] );
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
						<td align="center"><strong><%=sum_date[i] %></strong></td>
						<td align="center"><strong><%=str_sum_user %></strong></td>
						<td align="center"><strong><%=str_sum_login %></strong></td>
						<td align="center"><strong><%=str_sum_message %></strong></td>
						<td align="center"><%=str_sum_msg_text %></td>
						<td align="center"><%=str_sum_msg_picture %></td>
						<td align="center"><%=str_sum_msg_audio %></td>
						<td align="center"><%=str_sum_msg_video %></td>
						<td align="center"><%=str_sum_msg_traffic %></td>
						<td align="center"><strong><%=str_sum_page_view %></strong></td>
					</tr>
<%
	}
%>

					<tr><td colspan="10" height="5"></td></tr>
					<tr><td colspan="10" height="5" bgcolor="#dbdbdb"></td></tr>
					<tr><td colspan="10" height="5"></td></tr>
					
					<tr height="10"><td colspan="10"></td></tr>
					<tr>
						<td colspan="10" height="40" align="right">
							<input type="button" id="excel" name="excel" value="Excel 파일로 내려받기" onclick="js_export_data('statistics_dayly_excel.jsp');" onkeypress="js_export_data('statistics_dayly_excel.jsp');">
						</td>
					</tr>
					
					<tr>
						<td width="140"></td>
						<td width="80"></td>
						<td width="80"></td>
						<td width="80"></td>
						<td width="80"></td>
						<td width="80"></td>
						<td width="80"></td>
						<td width="80"></td>
						<td width="80"></td>
						<td width="80"></td>
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