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
	<title>Troasis Data 전송</title>
</head>
<script type="text/javascript">
//<!--
function js_user_input()
{
	var frm_input = document.q;
	if ( frm_input.user.value == "")
	{
		alert( "사용자 아이디가 입력되지 않았습니다." );
		frm_input.user.focus();
		return( false );
	}
	if ( frm_input.user_key.value == "" )
	{
		alert( "사용자 키가 입력되지 않았습니다." );
		frm_input.user_key.focus();
		return( false );
	}
	return( true );
}

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


		<tr height="600" align="center">


			<td width="40" align="center"></td>

			<!-- 	(시작) 작업영역.	-->
			<td width="860" valign="top" align="center">
<%
	String	userID		= loginManager.getUserID( session.getId() );
	String	userName	= LoginManager.mUserName;
%>
	<form name="q" action="test.jsp" method="post" onsubmit="return js_user_input();">
	<div id="msg_submit">
		<b>공지 사항 관리자 메시지</b><br/><br/><br/>
		클라이언트 화면 한줄 게시  : <input type="text" id="user" name="user"></input><br/><br/>
		<p>
		게시여부： <select name="client_type">
				<option value="Android" selected="selected">게시안함</option>
				<option value="iPhone">게시</option>
				</select>
		</p>
		게시 기간 :
					<tr><td colspan="10" height="40" align="left" >
					 <select
						class="combo" id="n_year_sel" name="n_year_sel"
						style="width: 60px; color: #000000; background-color: #ffffff;">
							<% for ( i = n_year_today - 20; i <= n_year_today + 1; i++ ) { 

%>
							<option value="<%=i%>"
								<% if ( n_year_sel == i  ) { %>selected<% } %>><%=i%></option>
							<% } %>
					</select> 년 &nbsp;&nbsp;&nbsp; <select class="combo" id="n_month_sel"
						name="n_month_sel"
						style="width: 40px; color: #000000; background-color: #ffffff;">
							<% for ( i = 1; i <= 12; i++ ) { %>
							<option value="<%=i%>"
								<% if ( n_month_sel == i  ) { %>selected<% } %>><%=i%></option>
							<% } %>
					</select> 월 &nbsp;&nbsp;&nbsp; <select class="combo" id="n_date_sel"
						name="n_date_sel"
						style="width: 40px; color: #000000; background-color: #ffffff;">
							<% for ( i = 1; i <= 31; i++ ) { %>
							<option value="<%=i%>"
								<% if ( n_date_sel == i  ) { %>selected<% } %>><%=i%></option>
							<% } %>
					</select> 일  까지 &nbsp;&nbsp;&nbsp; 
				</tr><br/><br/><br/><br/><br/>
							
				본문 : <br/><textarea id="vms_data" name="vms_data" cols="43"></textarea><br/><br/>
		
	</div><br/><br/>
	</form>
	<input type="submit" value="추가하기" /><br/><br/><br/>
			</td>
			<!-- 	(끝) 작업영역.	-->
		</tr>
		
		<!-- 	(시작) Footer.	-->
		<%@ include file="../admin/common_footer.jsp"%>
		<!-- 	(끝) Footer.	-->
	</table>
	
</body>
</html>
