<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath }"/>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Spring MVC05</title>
	
	<!-- bootstrap, jQuery -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>

	<script>
		$(document).ready(function() {
			if(${!empty msgType}) {
				$("#messageType").attr("class", "modal-content panel-warning");
				$("#message").css("color", "red");
				$("#message").css("font-weight", "bold");
				$("#message").css("text-align", "center");
				
				$("#myMessage").modal("show");
			} 
		});
	</script>
</head>
<body>
	<div class="container">
		<jsp:include page="../common/header.jsp" />	
		<h2></h2>
		<div class="panel panel-default">
			<div class="panel-heading" style="font-weight:bold; font-size:large;">로그인</div>
			<div class="panel-body">
				<form action="${contextPath}/memLogin.do" method="post">
					<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
					<div class="form-group">
						<label for="memID">아이디</label>
						<input type="text" class="form-control" id="memID" name="memID" maxlength="20" placeholder="아이디를 입력하세요" />
					</div>
					<div class="form-group">
						<label for="memPassword">비밀번호</label>
						<input type="password" class="form-control" id="memPassword" name="memPassword" maxlength="20" onKeyup="passwordCheck()" placeholder="비밀번호를 입력하세요" />
					</div>
					<div class="form-group">
						<button type="submit" class="btn btn-primary btn-lg" onClick="goInsert()">로그인</button>				
					</div>
				</form>	
			</div>
			
			<!-- 실패 메시지(모달창) -->
			<div id="myMessage" class="modal fade" role="dialog">
				<div class="modal-dialog">
			    	<!-- Modal content-->
					<div id="messageType" class="modal-content panel-info">
			  			<div class="modal-header panel-heading">
						    <button type="button" class="close" data-dismiss="modal">&times;</button>
						    <h4 class="modal-title" style="text-align:center;">${msgType}</h4>
						</div>
						<div class="modal-body">
			  				<p id="message">${msg}</p>
						</div>
						<div class="modal-footer">
						   <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
						</div>
				    </div>
				</div>
			</div>
			
			<div class="panel-footer">인프런_스프1탄</div>
		</div>
	</div>
</body>
</html>