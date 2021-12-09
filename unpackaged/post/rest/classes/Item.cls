global class Item {
    global String label;
    global String name;
    global Boolean expanded;
    global List<Item> items;

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
