package XuanQu.downjoy.model;

/**
 * @author banshuai
 * 
 */
public class SessionIdResponse {
	private String memberId;
	private String username;
	private String nickname;
	private String gender;
	private String level;
	private String avatar_url;
	private String created_date;
	private String token;
	private String error_code;
	private String error_msg;

	public SessionIdResponse(String memberId, String username, String nickname,
			String gender, String level, String avatar_url,
			String created_date, String token, String error_code,
			String error_msg) {
		super();
		this.memberId = memberId;
		this.username = username;
		this.nickname = nickname;
		this.gender = gender;
		this.level = level;
		this.avatar_url = avatar_url;
		this.created_date = created_date;
		this.token = token;
		this.error_code = error_code;
		this.error_msg = error_msg;
	}

	public String getMemberId() {
		return memberId;
	}

	public void setMemberId(String memberId) {
		this.memberId = memberId;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getNickname() {
		return nickname;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	public String getLevel() {
		return level;
	}

	public void setLevel(String level) {
		this.level = level;
	}

	public String getAvatar_url() {
		return avatar_url;
	}

	public void setAvatar_url(String avatar_url) {
		this.avatar_url = avatar_url;
	}

	public String getCreated_date() {
		return created_date;
	}

	public void setCreated_date(String created_date) {
		this.created_date = created_date;
	}

	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}

	public String getError_code() {
		return error_code;
	}

	public void setError_code(String error_code) {
		this.error_code = error_code;
	}

	public String getError_msg() {
		return error_msg;
	}

	public void setError_msg(String error_msg) {
		this.error_msg = error_msg;
	}

}
