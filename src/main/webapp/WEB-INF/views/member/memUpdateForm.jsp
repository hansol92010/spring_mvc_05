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
		
		function passwordCheck() {
			var memPassword1 = $("#memPassword1").val();
			var memPassword2 = $("#memPassword2").val();
			
			if(memPassword1 != memPassword2) {
				$("#passMessage").html("비밀번호가 일치하지 않습니다");
			} else {
				$("#passMessage").html("");
				$("#memPassword").val(memPassword1);
			}
		}
		
		function goUpdate() {
			var memAge = $("#memAge").val();
			if(memAge == null || memAge == "" || memAge === 0) {
				alert("나이를 입력하세요");
				return false;
			}
			document.frm.submit();	// 전송
		}
	
	</script>
</head>
<body>
	<div class="container">
		<jsp:include page="../common/header.jsp" />
		<h2></h2>
		<div class="panel panel-default">
			<div class="panel-heading" style="font-weight:bold; font-size:large;">회원정보수정</div>
			<div class="panel-body">
			 	<form action="${contextPath}/memUpdate.do" name="frm" method="post">
					<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
					<div class="form-group">
						<label for="memID">아이디</label>
						<input type="text" class="form-control" id="memID" name="memID" value="${member.memID}" readonly />
					</div>
					<div class="form-group">
						<label for="memPassword">비밀번호</label>
						<input type="password" class="form-control" id="memPassword1" name="memPassword1" maxlength="20" onKeyup="passwordCheck()" placeholder="비밀번호를 입력하세요" />
						<input type="hidden" id="memPassword" name="memPassword" value="" />
					</div>
					<div class="form-group">
						<label for="memPassword">비밀번호 확인</label>
						<input type="password" class="form-control" id="memPassword2" name="memPassword2" maxlength="20" onKeyup="passwordCheck()" placeholder="비밀번호를 확인하세요" />
					</div>
					<div class="form-group">
						<label for="memName">이름</label>
						<input type="text" class="form-control" id="memName" name="memName" maxlength="20" value="${member.memName}" placeholder="이름을 입력하세요" />
					</div>
					<div class="form-group">
						<label for="memAge">나이</label>
						<input type="number" class="form-control" id="memAge" name="memAge" maxlength="20" value="${member.memAge}" placeholder="나이를 입력하세요" />
					</div>
					<div class="form-group">
						<label for="memEmail">이메일</label>
						<input type="text" class="form-control" id="memEmail" name="memEmail" maxlength="20" value="${member.memEmail}" placeholder="이메일을 입력하세요" />
					</div>
					<div class="form-group" >
						<label for="memGender">성별</label>
						<div style="border:1px solid #dddddd; text-align: center; margin:0 auto;" data-toggle="buttons">
							<!-- 기존 성별이 '남자'로 체크된 경우 -->
							<label class="btn btn-primary <c:if test="${member.memGender eq '남자'}" >active</c:if>">
								<input type="radio" autocomplete="off" id="memGender" name="memGender" value="남자" 
								<c:if test="${member.memGender eq '남자'}" >checked</c:if> />남자
							</label>
							<!-- 기존 성별이 '여자'로 체크된 경우 -->
							<label class="btn btn-primary <c:if test="${member.memGender eq '여자'}" >active</c:if>">
								<input type="radio" autocomplete="off" id="memGender" name="memGender" value="여자" 
								<c:if test="${member.memGender eq '여자'}" >checked</c:if>/>여자
							</label>
						</div>
					</div>					
					<!-- 권한 체크 박스 -->
					<div class="form-group">
						<label>사용자 권한</label>
						<div class="form-control" style="border:1px solid #dddddd; text-align: center; margin:0 auto;" >
							<label class="checkbox-inline">
								<input type="checkbox" name="authList[0].auth" value="ROLE_USER"	
									<c:forEach var="authVO" items="${member.authList}">
										<c:if test="${authVO.auth eq 'ROLE_USER'}">checked</c:if>
									</c:forEach>
								/> ROLE_USER
							</label>
							<label class="checkbox-inline">
								<input type="checkbox" name="authList[1].auth" value="ROLE_MANAGER" 
									<c:forEach var="authVO" items="${member.authList}">
										<c:if test="${authVO.auth eq 'ROLE_MANAGER'}">checked</c:if>
									</c:forEach>
								/> ROLE_MANAGER
							</label>
							<label class="checkbox-inline">
								<input type="checkbox" name="authList[2].auth" value="ROLE_ADMIN"
									<c:forEach var="authVO" items="${member.authList}">
										<c:if test="${authVO.auth eq 'ROLE_ADMIN'}">checked</c:if>
									</c:forEach>
								/> ROLE_ADMIN								
							</label>
						</div>
					</div>
					<div class="form-group">
						<span id="passMessage" style="color:red;"></span>
						<button type="button" class="btn btn-success btn-default pull-right" onClick="goUpdate()">수정</button>				
					</div>
				</form>	
			</div>
		  
			<!-- 실패 메시지(모달창) -->
			<div id="myMessage" class="modal fade" role="dialog">
			  	<div class="modal-dialog">
`					<!-- Modal content-->
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