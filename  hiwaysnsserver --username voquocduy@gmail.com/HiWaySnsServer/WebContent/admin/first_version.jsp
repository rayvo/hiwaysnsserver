<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer"
	scope="page" />
<jsp:useBean id="param"
	class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc"
	scope="page" />
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import="java.io.*"%>
<%@	page import="java.util.*"%>
<%@	page import="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>


<%
	LoginManager loginManager = LoginManager.getInstance();
%>
<%
	if (loginManager.isLogin(session.getId()) == false) //세션 아이디가 로그인 중이 아니라면
	{
		response.sendRedirect("../admin/index.jsp");
		if (true)
			return;
	}
%>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title>최초 버전 등록</title>
</head>
<script type="text/javascript">
//<!--
function js_user_input()
{
	var frm_input = document.q;
	if ( frm_input.ver_name.value == "")
	{
		alert( "버전 이름이 입력되지 않았습니다." );
		frm_input.ver_name.focus();
		return( false );
	}
	if ( frm_input.ver_code.value == "" )
	{
		alert( "버전 코드가 입력되지 않았습니다." );
		frm_input.ver_code.focus();
		return( false );
	}
	if ( frm_input.client_type.value == "" )
	{
		alert( "안드로이드인지 아이폰인지 선택하여 주세요." );
		frm_input.is_Android_data.focus();
		return( false );
	}
	if ( frm_input.deployed_data.value == "" )
	{
		alert( "업데이트 날짜가 입력되지 않았습니다." );
		frm_input.deployed_data.focus();
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
				if (loginManager.mRole < 1) {
					//운영자 메뉴 표현.
			%>
			<!-- 	(시작) 운영자 메뉴.	-->
			<%@ include file="../admin/common_left_menu.jsp"%>
			<!-- 	(끝) 운영자 메누.	-->

			<%
				} else {
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
					String userID = loginManager.getUserID(session.getId());
					String userName = LoginManager.mUserName;
				%>



				<form name="q" action="first_version_insert.jsp" method="post"
					onsubmit="return js_user_input();">
					<div id="first_version_submit">
						<b>새로운 버전 업데이트</b><br />
						<br />						
						<br /> 버전 코드 : <input type="text" id="ver_code" name="ver_code"></input><br />
						<br /> 버전 이름 : <input type="text" id="ver_name" name="ver_name"></input><br />
						<br />
						<p>
							사용자 플레폼 타입： <select name="client_type">
								<option value="Android" selected="selected">Android</option>
								<option value="iPhone">iPhone</option>
							</select>
						</p>
						버전 업데이트 날짜: <input type="text" id="deployed_date" name="deployed_date"> (Example: yyyy-mm-dd)</input><br />
						<br /> <input type="submit" value="업데이트 하기"/>
					</div>
					<br />
				</form></td>
			<!-- 	(끝) 작업영역.	-->
		</tr>

		<!-- 	(시작) Footer.	-->
		<%@ include file="../admin/common_footer.jsp"%>
		<!-- 	(끝) Footer.	-->
	</table>
</body>
</html>


