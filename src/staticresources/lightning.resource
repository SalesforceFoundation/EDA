$Lightning = {
	use : function(applicationTag, callback, lightningEndPointURI, authToken) {
		if (this._applicationTag && this._applicationTag !== applicationTag) {
			throw new Error("$Lightning.use() already invoked with application: " + this._applicationTag);
		}

		if (!this._applicationTag) {
			this._applicationTag = applicationTag;
			this._pendingReadyRequests = [];
			this._ready = false;

			var parts = applicationTag.split(":");
			var url = (lightningEndPointURI || "") + "/" + parts[0] + "/" + parts[1] + ".app?aura.format=JSON&aura.formatAdapter=LIGHTNING_OUT";

			var xhr = new XMLHttpRequest();		
			
			xhr.onreadystatechange = function() {
				if (xhr.readyState == 4 && xhr.status == 200) {
					var config = JSON.parse(xhr.responseText);
					var auraInitConfig = config.auraInitConfig;
					
					$Lightning.addScripts(config.scripts, function() {
						$A.initConfig(auraInitConfig, true);
						
						$Lightning.lightningLoaded();
					});
					
					var styles = config.styles;
					for (var n = 0; n < styles.length; n++) {
						$Lightning.addStyle(styles[n]);
					}
				}
			};

			xhr.open("GET", url, true);
			
			if (authToken) {
				xhr.withCredentials = true;
				xhr.setRequestHeader("Authorization", authToken);
			}
			
			xhr.send();
		}

		this.ready(function() {
			// Request labels
			$A.enqueueAction($A.get("c.aura://ComponentController.loadLabels"));
		});

		if (callback) {
			this.ready(callback);
		}
	},

	ready : function(callback) {
		if (this._ready) {
			$A.run(callback);
		} else {
			this._pendingReadyRequests.push(callback);
		}
	},

	createComponent : function(type, attributes, locator, callback) {
		// Check to see if we know about the component - enforce aura:dependency
		// is used to avoid silent performance killer
		var unknownComponent;
		try {
			unknownComponent = $A.componentService.getDef(type) === undefined;
		} catch (e) {
			if ("Unknown component: markup://" + type === e.message) {
				unknownComponent = true;
			} else {
				throw e;
			}
		}

		if (unknownComponent) {
			throw new Error("No component definiton for " + type + " in the client registry - add <aura:dependency resource=\"" + type + "\"/> to "
					+ this._applicationTag + ".");
		} else {
			$A.run(function() {
				var config = {
					componentDef : "markup://" + type,
					attributes : {
						values : attributes
					}
				};

				$A.createComponent(type, attributes, function(component, status, statusMessage) {
					var error = null;

					var stringLocator = $A.util.isString(locator);
					var hostEl = stringLocator ? document.getElementById(locator) : locator;

					if (!hostEl) {
						error = "Invalid locator specified - "
								+ (stringLocator ? "no element found in the DOM with id=" + locator : "locator element not provided");
					} else if (status !== "SUCCESS") {
						error = statusMessage;
					}

					if (error) {
						throw new Error(error);
					}

					$A.render(component, hostEl);
					$A.afterRender(component);

					if (callback) {
						callback(component);
					}
				});
			});
		}
	},

	addScripts : function(urls, onload) {
		var url = urls[0];
		urls = urls.slice(1);

		var script = document.createElement("SCRIPT");
		script.type = "text/javascript";
		script.src = url;

		if (urls.length > 0) {
			var that = this;
			script.onload = function() {
				that.addScripts(urls, onload);
			};
		} else {
			script.onload = onload;
		}

		var head = document.getElementsByTagName("HEAD")[0];
		head.appendChild(script);
	},

	addStyle : function(url) {
		var link = document.createElement("LINK");
		link.href = url;
		link.type = "text/css";
		link.rel = "stylesheet";

		var head = document.getElementsByTagName("HEAD")[0];
		head.appendChild(link);
	},

	lightningLoaded : function() {
		this._ready = true;

		// DCHASMAN TODO Add auraErrorMessage UI - figure out a better way to
		// handle this!
		if (!document.getElementById("auraErrorMessage")) {
			var div = document.createElement("DIV");
			div.id = "auraErrorMessage";
			document.body.appendChild(div);
		}

		var that = this;
		for (var n = 0; n < that._pendingReadyRequests.length; n++) {
			that._pendingReadyRequests[n]();
		}
	}
};
