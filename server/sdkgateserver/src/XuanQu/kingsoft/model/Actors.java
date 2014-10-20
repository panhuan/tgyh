package XuanQu.kingsoft.model;

public class Actors {
	private short id;
	private String name;
	private int level;
	public short getId() {
		return id;
	}
	public void setId(short id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getLevel() {
		return level;
	}
	public void setLevel(int level) {
		this.level = level;
	}
	public Actors(short id, String name, int level) {
		super();
		this.id = id;
		this.name = name;
		this.level = level;
	}
	public Actors() {
		super();
		// TODO Auto-generated constructor stub
	}
	
}
