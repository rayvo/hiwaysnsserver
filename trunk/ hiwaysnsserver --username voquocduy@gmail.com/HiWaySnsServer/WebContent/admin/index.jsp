<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>

<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer"scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<% LoginManager loginManager = LoginManager.getInstance(); %>
<%
	if( loginManager.isLogin(session.getId()) )		//세션 아이디가 로그인 중이면
	{
		response.sendRedirect("../admin/index_login.jsp");
	}
	else											//그렇지 않으면 로그인 할 수 있도록
	{
		response.sendRedirect("../admin/index_logout.jsp");
	}
%>
