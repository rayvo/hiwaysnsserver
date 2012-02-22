<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ page import="java.lang.*"%>
<%@ page import="java.lang.String.*"%>
<%@ page import="java.lang.Integer.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Locale"%>
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import="kr.co.ex.hiwaysns.*"%>
<%@	page import="java.util.*"%>
<%@ page import="java.text.*"%>
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
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>    
	<title>공지사항 메시지 등록</title>
</head>
<script type="text/javascript">
//<!--
function js_user_input()
{
	var frm_input = document.q;
	if ( frm_input.title.value == "")
	{
		alert( "제목이 입력되지 않았습니다." );
		frm_input.title.focus();
		return( false );
	}
	if ( frm_input.conten.value == "" )
	{
		alert( " 입력되지 않았습니다." );
		frm_input.vms_data.focus();
		return( false );
	}
	return( true );
	

	function	js_calendar_refresh()
	{
		var frm_input	= document.form_main;
		var	n_year_sel		= frm_input.n_year_sel.value;
		var	n_month_sel		= frm_input.n_month_sel.value;
		var	n_date_sel		= frm_input.n_date_sel.value;
		var	n_hour_sel		= frm_input.n_hour_sel.value;
		var	obj_param	=   "n_year_sel=" + n_year_sel
							+ "&n_month_sel=" + n_month_sel
							+ "&n_date_sel=" + n_date_sel
							+ "&n_hour_sel=" + n_hour_sel;
		self.location.href	= location.pathname + "?" + obj_param;
		return ( true );
	}

}
//-->
</script> 

<%
	//오늘 날짜 구하기.
	Calendar	ctoday	= Calendar.getInstance();
	int		n_year_today	= ctoday.get(Calendar.YEAR);
	int		n_month_today	= ctoday.get(Calendar.MONTH);
	int		n_date_today	= ctoday.get(Calendar.DATE);
	int		n_hour_today	= ctoday.get(Calendar.HOUR_OF_DAY);

	//입력인자 수신.
	int		n_year_sel = 0, n_month_sel = 0, n_date_sel = 0;
	int		n_hour_sel	= 0;
	int		i;

	if ( request.getParameter("n_year_sel") != null )
		n_year_sel	= Integer.parseInt( request.getParameter("n_year_sel") );
	if ( request.getParameter("n_month_sel") != null )
		n_month_sel	= Integer.parseInt( request.getParameter("n_month_sel") );
	if ( request.getParameter("n_date_sel") != null )
		n_date_sel	= Integer.parseInt( request.getParameter("n_date_sel") );
	if ( request.getParameter("n_hour_sel") != null )
		n_hour_sel	= Integer.parseInt( request.getParameter("n_hour_sel") );

	//입력이 없는 경우, 오늘 날짜.
	if ( n_year_sel < 1 || n_month_sel < 1 )
	{
		n_year_sel	= n_year_today;
		n_month_sel	= ctoday.get(Calendar.MONTH) + 1;
	}
	if ( n_date_sel < 1 )	n_date_sel = n_date_today;
	if ( n_hour_sel < 1 )	n_hour_sel = n_hour_today;
%>

<body>
	<table cellpadding="0" cellspacing="0" border="0" width="1050">
		<!-- 	(시작) 헤더.	-->
		<%@ include file="../admin/common_header.jsp"%>
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
			<%@ include file="../admin/common_left_menu.jsp"%>
			<!-- 	(끝) 운영자 메누.	-->

		<%
			}
			else
			{
				//관리자 메뉴 표현.
		%>
			<!-- 	(시작) 관리자 메뉴.	-->
			<%@ include file="../admin/common_left_menu_admin.jsp"%>
			<!-- 	(끝) 관리자 메누.	-->
		<%
			}
		%>
			<!-- 	(끝) 메뉴영역.	-->

			<td width="40"></td>

			<!-- 	(시작) 작업영역.	-->
			<td width="850" valign="top" align="center">
<%
	String	userID		= loginManager.getUserID( session.getId() );
	String	userName	= LoginManager.mUserName;
%>
		<form name="q" action="np.jsp" method="post" onsubmit="return js_user_input();">
		<div id="msg_submit">
		<b>공지 사항 관리자 메시지</b><br/><br/><br/>
		클라이언트 화면 한줄 게시  : <input type="text" id="title" name="title"></input><br/><br/>
		
		게시여부： <select name="is_popup">
				<option value="yes" selected="selected">게시함</option>
				<option value="no">게시하지 않음</option>
				</select><br/><br/><br/>
		유효기간:
				<select class="combo" id="n_year_sel" name="n_year_sel" style="width: 60px; color:#000000; background-color:#ffffff;">
				<% for ( i = n_year_today - 20; i <= n_year_today + 1; i++ ) { %>
				<option value="n_year_sel" <% if ( n_year_sel == i  ) { %>selected<% } %>><%=i%></option>
				<% } %>
				</select>
				년 &nbsp;&nbsp;&nbsp;
							
				<select class="combo" id="n_month_sel" name="n_month_sel" style="width: 40px; color:#000000; background-color:#ffffff;">
				<% for ( i = 1; i <= 12; i++ ) { %>
				<option value="n_month_sel" <% if ( n_month_sel == i  ) { %>selected<% } %>><%=i%></option>
				<% } %>
				</select>
				월 &nbsp;&nbsp;&nbsp;
					
				<select class="combo" id="n_date_sel" name="n_date_sel" style="width: 40px; color:#000000; background-color:#ffffff;">
				<% for ( i = 1; i <= 31; i++ ) { %>
				<option value="n_date_sel" <% if ( n_date_sel == i  ) { %>selected<% } %>><%=i%></option>
				<% } %>
				</select>
				일 &nbsp;&nbsp;&nbsp;
							
				<select class="combo" id="n_hour_sel" name="n_hour_sel" onchange="return js_calendar_refresh()" style="width: 40px; color:#000000; background-color:#ffffff;">
				<% for ( i = 0; i <= 23; i++ ) { %>
				<option value="n_hour_sel" <% if ( n_hour_sel == i  ) { %>selected<% } %>><%=i%></option>
				<% } %>
				</select>
				시 &nbsp;&nbsp;&nbsp;<br/><br/><br/>
		
		본문 : <br/><textarea id="content" name="content" cols="43"></textarea><br/><br/>
		<input type="submit" value="등록하기" />
		</div><br/>
		
	</form>

			</td>
			<!-- 	(끝) 작업영역.	-->
		</tr>
		
		<!-- 	(시작) Footer.	-->
		<%@ include file="../admin/common_footer.jsp"%>
		<!-- 	(끝) Footer.	-->
	</table>
</body>
</html>
