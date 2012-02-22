<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
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
	<title>TrOASIS 운영 및 관리 홈페이지 - 사용자 로그 현황</title>
</head>
<script type="text/javascript">
//<!--
//-->
</script>

<%@ page import	= "java.lang.*" %>
<%@ page import	= "java.lang.String.*" %>
<%@ page import	= "java.lang.Integer.*" %>
<%@ page import	= "java.sql.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.text.SimpleDateFormat" %>
<%@ page import = "java.util.Locale" %>

<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayDbServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />

<%
	//입력정보 수신.
	int		count		= 0;
	int		page_no		= 1;
	int		page_size	= 20;
	int		sort_order	= 0;
	int		search_type	= 0;
	String	search_text	= "";
	
	String	strParam	= "";
	strParam	= param.get_input_param( request.getParameter("page_no") );
	if ( strParam.length() > 0 )	page_no = Integer.parseInt(strParam);
	strParam	= param.get_input_param( request.getParameter("page_size") );
	if ( strParam.length() > 0 )	page_size = Integer.parseInt(strParam);
	strParam	= param.get_input_param( request.getParameter("sort_order") );
	if ( strParam.length() > 0 )	sort_order = Integer.parseInt(strParam);
	strParam	= param.get_input_param( request.getParameter("search_type") );
	if ( strParam.length() > 0 )	search_type = Integer.parseInt(strParam);
	search_text	= param.get_input_param( request.getParameter("search_text") );
%>
<script language="JavaScript" type="text/javascript" src="../common/common.js"></script>
<body>
	<a href="user_log_list.jsp">새로고침</a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="index.jsp">돌아가기</a>
	<br><br>

	<form name="form_main" method="post">
	<table width="950">
		<tr height="1">
			<td colspan="9" align="center">
				<input type="hidden" id="page_no" name="page_no" value="<%=page_no%>" />
				<input type="hidden" id="page_size" name="page_size" value="<%=page_size%>" />
			</td>
		</tr>


		<tr height="20">
			<td colspan="3" align="left">
				<strong>정렬순서:</strong>&nbsp;
				<select class="combo" id="sort_order" name="sort_order" style="width: 160px; color:#000000; background-color:#ffffff;" Onchange="return js_page_refresh();">
					<option value="0" <% if ( sort_order < 1) { %>selected<% } %>>등록순서</option>
					<option value="1" <% if ( sort_order == 1) { %>selected<% } %>>최근 로그 시각순서</option>
					<option value="2" <% if ( sort_order == 2 ) { %>selected<% } %>>User ID</option>
					<option value="3" <% if ( sort_order == 3 ) { %>selected<% } %>>닉네임</option>
				</select>
			</td>

			<td colspan="4" align="left">
				<strong>검색방법:</strong>&nbsp;
				<select class="combo" id="search_type" name="search_type" style="width: 160px; color:#000000; background-color:#ffffff;">
					<option value="0" <% if ( search_type < 1) { %>selected<% } %>>전체(User ID+닉네임)</option>
					<option value="1" <% if ( search_type == 1 ) { %>selected<% } %>>User ID</option>
					<option value="2" <% if ( search_type == 2 ) { %>selected<% } %>>닉네임</option>
				</select>
				&nbsp;&nbsp;
				<label for="search_text">
				<input type="text" name="search_text" id="search_text" value="<%=search_text%>" onFocus="this.value=''" tabindex="2" />
				</label>
				&nbsp;&nbsp;
				<img src="images/btn_search.gif" alt="검색" width="55" height="20" border="0" onclick="return js_page_refresh();" onkeypress="return js_page_refresh();" />
			</td>
		</tr>
		<tr height="10"><td colspan="9"></td></tr>


		<tr height="4"><td colspan="9" background="images/dot.gif"></td></tr>
		<tr><td colspan="9" align="center"><strong>사용자의 로그 현황</strong></td></tr>
		<tr height="4"><td colspan="9" background="images/dot.gif"></td></tr>
		<tr>
			<td width="50" align="center">번호</td>
			<td width="50" align="center">id</td>
			<td width="150" align="center">사용자 ActiveID</td>
			<td width="150" align="center">User ID</td>
			<td width="100" align="center">닉네임</td>
			<td width="200" align="center">로그 시각</td>
			<td width="200" align="center">위도</td>
			<td width="200" align="center">경도</td>
			<td width="200" align="center">속도</td>
		</tr>
		
<%
	try
	{
		//DB 연결.
		db.db_open();

		//데이터베이스에서 사용자 로그 목록의 개수 읽어오기.
		String	query;
		query	= "SELECT COUNT(*) FROM troasis_log";
		//query	= query + " WHERE flag_deleted = 0 ";		
		//query	= query + " WHERE id = log_id";		
		if ( search_text.length() > 0 )
		{
			switch( search_type )
			{
			case 1	:
				query	= query + " WHERE (UPPER(user_id) LIKE UPPER('%" + search_text + "%'))";
				break;
			case 2	:
				query	= query + " WHERE (UPPER(nickname) LIKE UPPER('%" + search_text + "%'))";
				break;
			default	:
				query	= query + " WHERE (UPPER(user_id) LIKE UPPER('%" + search_text + "%'))";
				query	= query + " OR (UPPER(nickname) LIKE UPPER('%" + search_text + "%'))";
				break;
			}
		}
		db.exec_query( query );

		if( db.mDbRs.next() )	count = db.mDbRs.getInt( 1 );

		//데이터베이스에서사용자 로그 목록을 읽어와서 출력한다.
		query	= "SELECT * FROM troasis_log";
		//query	= query + " WHERE flag_deleted = 0 ";
		//query	= query + " WHERE id = log_id";		
		if ( search_text.length() > 0 )
		{
			switch( search_type ) 
			{
			case 1	:
				query	= query + " WHERE (UPPER(user_id) LIKE UPPER('%" + search_text + "%'))";
				break;
			case 2	:
				query	= query + " WHERE (UPPER(nickname) LIKE UPPER('%" + search_text + "%'))";
				break;
			default	:
				query	= query + " WHERE (UPPER(user_id) LIKE UPPER('%" + search_text + "%'))";
				query	= query + " OR (UPPER(nickname) LIKE UPPER('%" + search_text + "%'))";
				break;
			}
		}	
		switch( sort_order )
		{
		case 1	:
			query	= query + " ORDER BY time_log DESC, id DESC ";
			break;
		case 2	:
			query	= query + " ORDER BY user_id ASC, id DESC ";
			break;
		case 3	:
			query	= query + " ORDER BY nickname ASC, id DESC ";
			break;
		default	:
			query	= query + " ORDER BY id DESC ";
			break;
		}
		//이전 페이지 내용 Skip!
		int		index_start	= page_size * (page_no - 1);
		query	= query + "  LIMIT " + index_start + ", " + page_size;
		db.exec_query( query );
		
		//현재 페이지 내용 출력.
		String	dTime_time_log;
		for ( int i = 0; i < page_size && db.mDbRs.next(); i++ )
		{			
			int		no	= count - index_start - i;
			
			int		db_id				= db.mDbRs.getInt( "id" );
			String	db_log_id			= db.mDbRs.getString( "log_id" );
			String	db_user_id			= db.mDbRs.getString( "user_id" );
			String	db_nickname			= db.mDbRs.getString( "nickname" );

			dTime_time_log				= db.getTimestampString ( db.mDbRs.getLong( "time_log" ) );

			int		db_loc_lat			= db.mDbRs.getInt( "loc_lat" );
			int		db_loc_lng			= db.mDbRs.getInt( "loc_lng" );
			int		db_speed			= db.mDbRs.getInt( "speed" );
%>
		<tr height="1"><td colspan="9" background="images/dot.gif"></td></tr>
		<tr>
			<td align="center"><%=no %></td>
			<td align="center"><%=db_id %></td>
			<td align="center"><%=db_log_id %></td>
			<td align="center"><%=db_user_id %></td>
			<td align="left"><%=db_nickname %></td>
			<td align="left"><%=dTime_time_log %></td>
			<td align="left"><%=db_loc_lat %></td>
			<td align="left"><%=db_loc_lng %></td>
			<td align="center"><%=db_speed %>Km/H</td>
		</tr>
<%
		}
	}
	catch( Exception e )
	{
		//완료 메시지.
		out.println( "<br><br>사용자의 로그 현황을 읽어오는 과정에서 오류가 발생 했습니다." );
		System.out.println( e );
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>
		<tr height="4"><td colspan="9" background="images/dot.gif"></td></tr>
		
		<tr height="20"><td colspan="9"></td></tr>
		<tr height="20">
			<td colspan="9" align="center"><%=param.put_page_list(count, page_size, page_no)%></td>
		</tr>
	</table>
	</form>
	
	<br><br>
	<a href="user_log_list.jsp">새로고침</a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="index.jsp">돌아가기</a>
</body>
</html>