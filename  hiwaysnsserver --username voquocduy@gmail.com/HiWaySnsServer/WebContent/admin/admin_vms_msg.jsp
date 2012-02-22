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
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>    
	<title>VMS 관리자 메시지 등록</title>
</head>
<script type="text/javascript">
//<!--
function js_user_input()
{
	var frm_input = document.q;
	if ( frm_input.vms_id.value == "")
	{
		alert( "VMS ID가 입력되지 않았습니다." );
		frm_input.vms_id.focus();
		return( false );
	}
	if ( frm_input.vms_data.value == "" )
	{
		alert( "VMS 메시지가 입력되지 않았습니다." );
		frm_input.vms_data.focus();
		return( false );
	}
	return( true );
}
//-->
</script> 
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
			<td width="860" valign="top" align="center">
<%
	String	userID		= loginManager.getUserID( session.getId() );
	String	userName	= LoginManager.mUserName;
%>
	<form name="q" action="admin_vms_msg_process.jsp" method="post" onsubmit="return js_user_input();">
	<div id="msg_submit">
		<b>VMS 관리자 메시지</b><br/><br/><br/>
		VMS_ID  : <input type="text" id="vms_id" name="vms_id"></input><br/><br/>
		Message : <br/><textarea id="vms_data" name="vms_data" cols="43"></textarea><br/><br/>
		<input type="submit"/>
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
