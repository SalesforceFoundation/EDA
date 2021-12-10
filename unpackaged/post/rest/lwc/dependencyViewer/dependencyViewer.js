import { LightningElement, track } from "lwc";
import getDependencyStructure from "@salesforce/apex/DependencyApi.doGet";

export default class DependencyViewer extends LightningElement {
    dependencyJson;
    loaded = false;

    connectedCallback() {
        getDependencyStructure()
            .then((result) => {
                this.loaded = true;
                let resultJSON = JSON.parse(result);
                console.log(resultJSON);
                this.dependencyJson = resultJSON;
            })
            .catch((error) => {
                console.log("Error: " + error.body.message);
            });
    }
}
