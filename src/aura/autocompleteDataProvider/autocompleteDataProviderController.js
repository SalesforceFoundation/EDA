({
    /*******************************************************************************************************
    * @description called by the autocomplete component to retrieve the list of sources that matches
    * the criteria the user has typed in.
    */
    provide: function (component, event, helper) {
        var args = event.getParam('arguments');
        if (args && args.keyword && args.callback) {
            var queryAction = component.get('c.getSuggestions');
            var sObjectType = component.get('v.sObjectType');
            queryAction.setParams({
                term: args.keyword,
                sObjectType: sObjectType
            });
            queryAction.setAbortable();  
            queryAction.setCallback(
                this,
                function (response) {
                    var state = response.getState();
                    if ('SUCCESS' === state) {
                        args.callback(
                            null,
                            args.idDataCallback,
                            response.getReturnValue()
                        );
                    } else if ('ERROR' === state) {
                        var auraErrors = response.getError();
                        var errors = [];
                        if (auraErrors) {
                            for (var error in auraErrors) {
                                if (error.message) {
                                    errors.push(new Error(error.message));
                                }
                            }
                        }
                        args.callback(
                            errors,
                            args.idDataCallback,
                            []
                        );
                    }
                }
            );
            $A.enqueueAction(queryAction);
        } else {
            args.callback(null, []);
        }
    },
})