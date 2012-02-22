<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@	page import ="kr.co.ex.hiwaysns.lib.*"%>
<%@ include file="../common/config.jsp"%>
<%@	page import ="java.util.*"%>
<%@	page import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>
<%@ page import="java.lang.*"%>
<%@ page import="java.lang.String.*"%>
<%@ page import="java.lang.Integer.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Locale"%>
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import="kr.co.ex.hiwaysns.*"%>
<%@ page import="java.text.*"%>
<%@	page import ="kr.co.ex.hiwaysns.lib.*"	%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page"/>
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />

<%

String sql;
String rtn_xml;

rtn_xml = "";

try{

	
	//int user = request.getParameter("userid");
	
	db.db_open();
	
	String	strQuery;
	String	strTroasisLog	= "troasis_log";

	strQuery = "SELECT count(*)";
	strQuery = strQuery + " FROM " + strTroasisLog;
	//strQuery = strQuery + " WHERE log_id = " +user; 
	db.exec_query( strQuery );
	
	out.println("<?xml version='1.0' encoding='ISO-8859-1'?>");
	out.println("<user>");

	
	while(db.mDbRs.next())
	{

		out.println("<userpath>");
		//out.println("<userpath><lat>"+ rs.getFloat("loc_lat") + " </lat></userpath>");
		//out.println("<userpath><lng>"+ rs.getFloat("loc_lng") + " </lng></userpath>");
		out.println("<lat>" + (double)(db.mDbRs.getInt("loc_lat"))/1000000.00 + " </lat>");
		out.println("<lng>" + (double)(db.mDbRs.getInt("loc_lng"))/1000000.00 +  "</lng>");
		out.println("<speeds>"+db.mDbRs.getInt("speed")+"</speeds>");
		out.println("</userpath>");		
	
	}	
	out.println("</user>");
}
catch(ClassNotFoundException cne){
	
}catch(SQLException se){
}
%>
