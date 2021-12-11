public class Item {
    public String label;
    public String name;
    public Boolean expanded;
    public List<Item> items;

    public Item(String label, String name, Boolean expanded) {
        this.label = label;
        this.name = name;
        this.expanded = expanded;
        this.items = new List<Item>();
    }

    public Item(String label, String name) {
        this.label = label;
        this.name = name;
        this.expanded = false;
        this.items = new List<Item>();
    }
}
