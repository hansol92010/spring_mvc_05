package kr.board.mapper;

import org.apache.ibatis.annotations.Mapper;

import kr.board.entity.AuthVO;
import kr.board.entity.Member;

@Mapper
public interface MemberMapper {
	public Member memCheck(String memID);		// 회원 조회
	public int register(Member member);			// 회원 등록(성공 1, 실패 0)
	public Member memLogin(Member member);		// 로그인
	public int memUpdate(Member member);		// 회원 정보 수정
	public void memProfileUpdate(Member member);	// 사진 등록 
	public void authInsert(AuthVO authVO);		// 권한 등록
	public void authDelete(String memID);		// 권한 삭제
}
