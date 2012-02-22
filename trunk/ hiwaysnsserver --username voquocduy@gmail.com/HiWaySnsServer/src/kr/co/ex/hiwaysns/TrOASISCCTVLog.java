package kr.co.ex.hiwaysns;

public class TrOASISCCTVLog {
	private int id;
	private String cctv_id;
	private int changed_type;
	private int changed_number;
	private String updated_time;
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getCctv_id() {
		return cctv_id;
	}
	public void setCctv_id(String cctv_id) {
		this.cctv_id = cctv_id;
	}
	public int getChanged_type() {
		return changed_type;
	}
	public void setChanged_type(int changed_type) {
		this.changed_type = changed_type;
	}
	public String getUpdated_time() {
		return updated_time;
	}
	public void setUpdated_time(String updated_time) {
		this.updated_time = updated_time;
	}
	public int getChanged_number() {
		return changed_number;
	}
	public void setChanged_number(int changed_number) {
		this.changed_number = changed_number;
	}
	
}
