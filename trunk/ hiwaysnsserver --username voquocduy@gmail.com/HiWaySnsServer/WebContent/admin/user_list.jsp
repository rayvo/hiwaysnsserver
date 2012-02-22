<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
<% LoginManager loginManager = LoginManager.getInstance(); %>
<%
	if( loginManager.isLogin(session.getId()) == false 	//시스템 관리자가 로그인 중이 아니라면
		|| loginManager.mRole < 1 )
	{
		response.sendRedirect("../admin/index.jsp");
		if ( true )	return;
	}
%>
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
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>TrOASIS 신규 운영자 인증</title>
</head>
<script language="JavaScript" type="text/javascript" src="../common/common.js"></script>
<script type="text/javascript">
//<!--
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
				<form id="form_main" name="form_main" method="post" action="../admin/login_process.jsp" onsubmit="return js_login_user();">
				<table align="left" border="0" cellpadding="0" cellspacing="0">
					<!--	(1) 자료 전달 영역		-->
					<tr>
						<td>
							<input type="hidden" id="page_no" name="page_no" value="<%=page_no%>" />
							<input type="hidden" id="page_size" name="page_size" value="<%=page_size%>" />
						</td>
					</tr>
				
					<!--	(2) 사용자 목록				-->
					<tr height="20"><td></td></tr>
					<tr>
						<td align="right" valign="bottom">
							<table align="center" border="0" cellpadding="0" cellspacing="0">

								<tr height="20">
									<td colspan="2" align="left">
										<strong>정렬:</strong>&nbsp;
										<select class="combo" id="sort_order" name="sort_order" style="width: 120px; color:#000000; background-color:#ffffff;" Onchange="return js_page_refresh();">
											<option value="0" <% if ( sort_order < 1) { %>selected<% } %>>User ID</option>
											<option value="1" <% if ( sort_order == 1) { %>selected<% } %>>이름</option>
										</select>
									</td>
						
									<td colspan="2" align="left">
										<strong>검색:</strong>&nbsp;
										<select class="combo" id="search_type" name="search_type" style="width: 140px; color:#000000; background-color:#ffffff;">
											<option value="0" <% if ( search_type < 1) { %>selected<% } %>>전체(User ID+이름)</option>
											<option value="1" <% if ( search_type == 1 ) { %>selected<% } %>>User ID</option>
											<option value="2" <% if ( search_type == 2 ) { %>selected<% } %>>이름</option>
										</select>
										<label for="search_text">
										<input type="text" name="search_text" id="search_text" width="10" value="<%=search_text%>" onFocus="this.value=''" tabindex="2" />
										</label>
										<img src="images/btn_search.gif" alt="검색" width="55" height="20" border="0" onclick="return js_page_refresh();" onkeypress="return js_page_refresh();" />
									</td>
								</tr>
								<tr height="10"><td colspan="5"></td></tr>



								<tr>
									<td colspan="5" height="40" align="center" bgcolor="#dbdbdb">
										<font style="font-size:11pt; color:#ff5900; line-height:22px">사용자 목록</font>
									</td>
								</tr>
								<tr><td colspan="5" height="5"></td></tr>
								<tr>
									<td align="center">운영자 ID</td>
									<td align="center">이름</td>
									<td align="center">권한</td>
									<td align="center">연락처</td>
									<td align="center">인증상태</td>
								</tr>
								<tr><td colspan="5" height="5"></td></tr>
								<tr>
									<td colspan="5" height="5" bgcolor="#dbdbdb"></td>
								</tr>
								<tr><td colspan="5" height="5"></td></tr>

<%
	try
	{
		//DB 연결.
		db.db_open();

		//데이터베이스에서 Active 사용자 목록의 개수 읽어오기.
		String	query;
		query	= "SELECT COUNT(*) FROM troasis_admin_users";
		//query	= query + " WHERE flag_deleted = 0 ";		
		if ( search_text.length() > 0 )
		{
			switch( search_type )
			{
			case 1	:
				query	= query + " WHERE (UPPER(user_id) LIKE UPPER('%" + search_text + "%'))";
				break;
			case 2	:
				query	= query + " WHERE (UPPER(user_name) LIKE UPPER('%" + search_text + "%'))";
				break;
			default	:
				query	= query + " WHERE (UPPER(user_id) LIKE UPPER('%" + search_text + "%'))";
				query	= query + " OR (UPPER(user_name) LIKE UPPER('%" + search_text + "%'))";
				break;
			}
		}
		db.exec_query( query );

		if( db.mDbRs.next() )	count = db.mDbRs.getInt( 1 );

		//데이터베이스에서 Active 사용자 목록을 읽어와서 출력한다.
		query	= "SELECT * FROM troasis_admin_users";
		//query	= query + " WHERE flag_deleted = 0 ";	
		if ( search_text.length() > 0 )
		{
			switch( search_type )
			{
			case 1	:
				query	= query + " WHERE (UPPER(user_id) LIKE UPPER('%" + search_text + "%'))";
				break;
			case 2	:
				query	= query + " WHERE (UPPER(user_name) LIKE UPPER('%" + search_text + "%'))";
				break;
			default	:
				query	= query + " WHERE (UPPER(user_id) LIKE UPPER('%" + search_text + "%'))";
				query	= query + " OR (UPPER(user_name) LIKE UPPER('%" + search_text + "%'))";
				break;
			}
		}	
		switch( sort_order )
		{
		case 1	:
			query	= query + " ORDER BY user_name ASC, user_id ASC";
			break;
		default	:
			query	= query + " ORDER BY user_id ASC ";
			break;
		}
		db.exec_query( query );

		int		count_leading	= (page_no - 1) * page_size;
		for ( int i = 0; i < count_leading && db.mDbRs.next(); i++ )
		{
			if ( i < count_leading )	continue;
		}
		
		String		user_approved	= "";
		String		user_role		= "";
		for ( int i = 0; i < page_size && db.mDbRs.next(); i++ )
		{
			String	db_user_id			= db.mDbRs.getString( "user_id" );
			String	db_user_name		= db.mDbRs.getString( "user_name" );
			String	db_user_mobile		= db.mDbRs.getString( "mobile" );
			int		db_user_approved	= db.mDbRs.getInt( "approved" );
			user_approved	= "<a href='../admin/user_approval_process.jsp?user_id=" + db_user_id + "'>인증대기</a>";
			if ( db_user_approved > 0 )
				user_approved	= "<a href='../admin/user_unapproval_process.jsp?user_id=" + db_user_id + "'>인증완료</a>";

			int		db_user_role	= db.mDbRs.getInt( "role" );
			user_role	= "운영자";
			if ( db_user_role > 0 )	user_role = "관리자";
			if ( i > 0 )
			{
%>
								<tr><td colspan="5" height="1" bgcolor="#dbdbdb"></td></tr>
<%
			}
%>
								<tr>
									<td align="center"><%=db_user_id %></td>
									<td align="center"><%=db_user_name %></td>
									<td align="center"><%=user_role %></td>
									<td align="center"><%=db_user_mobile %></td>
									<td align="center"><%=user_approved %></td>
								</tr>
<%
		}
	}
	catch( Exception e )
	{
		//완료 메시지.
		out.println( "<br><br>운영자 목록을 읽어오는 과정에서 오류가 발생 했습니다." );
		System.out.println( e );
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>

								<tr><td colspan="5" height="5"></td></tr>
								<tr>
									<td colspan="5" height="5" bgcolor="#dbdbdb"></td>
								</tr>
								<tr><td colspan="5" height="5"></td></tr>

								<tr height="20"><td colspan="5"></td></tr>
								<tr height="20">
									<td colspan="5" align="center"><%=param.put_page_list(count, page_size, page_no)%></td>
								</tr>

								<tr height="1">
									<td width="170"></td>
									<td width="170"></td>
									<td width="170"></td>
									<td width="160"></td>
									<td width="170"></td>
								</tr>
							</table>
						</td>
					</tr>
				
					<!--	(3) 테이블 형식			-->
					<tr>
						<td width="860"></td>
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