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
    // Add an "href" attribute (using the "xlink" namespace)
    var shape = document.createElementNS(svgns, "use");
    shape.setAttributeNS(xlinkns, "href", svgPath);
    svgroot.appendChild(shape);

    var container = component.find("container").getElement();
    container.insertBefore(svgroot, container.firstChild);
  }
})