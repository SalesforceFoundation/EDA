public virtual with sharing class LookupResult implements Comparable {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;

    /*Optional*/
    @AuraEnabled
    public String alternativeText;
    @AuraEnabled
    public String icon;
    @AuraEnabled
    public String imageUrl;
    @AuraEnabled
    public String meta;

    public LookupResult(LookupResult result) {
        this.label = result.label;
        this.value = result.value;
        this.alternativeText = result.alternativeText;
        this.icon = result.icon;
        this.imageUrl = result.imageUrl;
        this.meta = result.meta;
    }

    public LookupResult(String label, String value) {
        this.label = label;
        this.value = value;
    }

    public LookupResult(String label, String value, String icon, String imageUrl, String altText, String meta) {
        this.label = label;
        this.value = value;
        this.icon = icon;
        this.imageUrl = imageUrl;
        this.alternativeText = altText;
        this.meta = meta;
    }

    public LookupResult(SObject obj) {
        obj.getSObjectType().getDescribe().getLabel();
        this.value = obj.Id;
    }

    @AuraEnabled
    public String getInitials() {
        if (!String.isEmpty(this.label)) {
            List<String> firstLetters = new List<String>();
            for (String name : this.label.split(' ')) {
                firstLetters.add(name.substring(0, 1));
            }
            return String.join(firstLetters, '');
        }
        return '';
    }

    public String getLabelLower() {
        return this.label.toLowerCase();
    }

    public Integer compareTo(Object compareMe) {
        LookupResult compareResult = (LookupResult) compareMe;
        return this.getLabelLower().compareTo(compareResult.getLabelLower());
    }

    public Boolean equals(LookupResult lookupResult) {
        return this.label = lookupResult.label && this.value = lookupResult.value &&
        this.alternativeText = lookupResult.alternativeText && this.icon = lookupResult.icon &&
        this.imageUrl = lookupResult.imageUrl && this.meta = lookupResult.meta;
    }
}
