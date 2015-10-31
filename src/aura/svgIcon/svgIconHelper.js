({
  renderIcon: function(component) {
    var prefix = "slds-";
    var svgns = "http://www.w3.org/2000/svg";
    var xlinkns = "http://www.w3.org/1999/xlink";
    var size = component.get("v.size");
    var name = component.get("v.name");
    var classname = component.get("v.class");
    var category = component.get("v.category");

    var containerClassName = [
        prefix+"icon__container",
        prefix+"icon-"+category+"-"+name,
        classname
        ].join(' ');
    var iconClassName = prefix+"icon "+prefix+"icon--" + size;
    component.set("v.containerClass", containerClassName);

    var svgroot = document.createElementNS(svgns, "svg");
    svgroot.setAttribute("aria-hidden", "true");
    svgroot.setAttribute("class", iconClassName);
    svgroot.setAttribute("name", name);
    
    var svgPath = component.get("v.svgPath");
    var namespace = "";
    //This would work with any class. We are just using the one with the shortest name.
    var gettingnamespace = sforce.connection.query("SELECT NamespacePrefix FROM ApexClass where Name = 'REL_Utils' LIMIT 1"); 
    var getname = gettingnamespace.getArray("records");
    if(getname.length > 0 && getname[0] && getname[0].NamespacePrefix && getname[0].NamespacePrefix.length > 0) { 
		namespace = getname[0].NamespacePrefix + "__";
		svgPath = svgPath.replace('/resource/', '/resource/' + namespace);
		console.log("svgPath after manipulation: " + svgPath);
	}
    component.set("v.svgPath", svgPath);
    
    // Add an "href" attribute (using the "xlink" namespace)
    var shape = document.createElementNS(svgns, "use");
    shape.setAttributeNS(xlinkns, "href", svgPath);
    svgroot.appendChild(shape);

    var container = component.find("container").getElement();
    container.insertBefore(svgroot, container.firstChild);
  }
})