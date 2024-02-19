package kr.board.entity;

import java.util.List;

import lombok.Data;

@Data
public class Member {
	private int memIdx;				// 회원 번호
	private String memID;			// 회원 아이디
	private String memPassword;		// 회원 비밀번호
	private String memName;			// 회원 이름
	private int memAge;				// 회원 나이
	private String memGender;		// 회원 성별
	private String memEmail;		// 회원 이메일
	private String memProfile;		// 회원 사진
	private List<AuthVO> authList;	// 회원에게 부여된 권한(총 3가지)
}
