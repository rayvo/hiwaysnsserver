<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/list_server_db.jsp"%>
<%@	page import="kr.co.ex.hiwaysns.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<% LoginManager loginManager = LoginManager.getInstance(); %>


<%@	page import="java.io.*"%>
<%@	page import="java.util.*"%>
<%@	page import="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>
<%@	page import="java.util.Calendar"%>
<%@	page import="java.text.SimpleDateFormat"%>

<%
	if( loginManager.isLogin(session.getId()) == false 	//시스템 관리자가 로그인 중이 아니라면
		|| loginManager.mRole < 1 )
	{
		response.sendRedirect("../admin/index.jsp");
		if ( true )	return;
	}
%>
<html>
<head>
<title>Encrypting URL for National CCTV</title>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
</head>

<%@ page import="java.lang.*"%>
<%@ page import="java.lang.String.*"%>
<%@ page import="java.lang.Integer.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@page import="kr.co.ex.hiwaysns.Encrypter"%>

<body topmargin='20' leftmargin='20'>


<%
	request.setCharacterEncoding("utf-8");
	String	cctv_id = request.getParameter("cctv_id");
	String	corname = request.getParameter("corname");
	String	svcname = request.getParameter("svcname");
	String	datetime = request.getParameter("datetime");
	String encrypted = Encrypter.encrypt(cctv_id, corname + "," + svcname + "," + cctv_id + "," + datetime);
	
	response.sendRedirect("../admin/cctv_url_encrypt.jsp?encoded_string=" + encrypted + "&cctv_id=" + cctv_id);
	
%>

</body>
</html>



