heda_lex_locators = {
    "mailing_address": "//*[contains(@placeholder,'{}')]",
    "object_dd": "//h1[contains(@class,'slds-page-header__title')]/a/div[contains(@class,'triggerLinkTextAndIconWrapper')][.//lightning-primitive-icon]",
    "record": {
        "button": "//div[@class='actionsContainer']/button[@title='{}']",
        "datepicker": "//div[contains(@class,'uiDatePickerGrid')]/table[@class='calGrid']//span[text()='{}']",
        "edit_button": '//*[@title="{}"]',
        "list": "//div[contains(@class,'forcePageBlockSectionRow')]/div[contains(@class,'forcePageBlockItem')]/div[contains(@class,'slds-p-vertical_xx-small')]/div[@class='slds-form-element__control']/div[.//span[text()='{}']][//div[contains(@class,'uiMenu')]//a[@class='select']]",
        "dropdown": "//div[@class='select-options']/ul[@class='scrollable']/li[@class='uiMenuItem uiRadioMenuItem']/a[contains(text(),'{}')]",
        "related": {
            "button": "//article[contains(@class, 'forceRelatedListCardDesktop')][.//img][.//span[@title='{}']]//a[@title='{}']",
            "check_occurence": '//h2/a/span[@title="{}"]/following-sibling::span[text()=" ({})"]',
            "drop-down": '//div[contains(@class, "slds-card")]/header[.//span[@title="{}"]]/parent::*/div/div/div/a[contains(@class, "slds-button")]',
            "title": '//div[contains(@class, "slds-card")]/header[.//span[@title="{}"]]',
        },
    },
    "object": {
        "radio_button": "//div[contains(@class,'changeRecordTypeRightColumn')]/div/label[@class='slds-radio']/div[.//span[text()='{}']]/preceding::div[1]/span[@class='slds-radio--faux']",
    },
    "heda_settings": {
        "affiliations_tab": "//a[contains(text(),'Affiliations')]",
        "affiliations_role_checkbox": "(//label[@class='slds-checkbox'])//input[@class='copy-start-date uiInput uiInputCheckbox uiInput--default uiInput--checkbox']",
        "affiliation_mappings_tab": "//a[contains(text(), 'Affiliation Mappings')]",
        "create_walkin_advising_event_button": "//div[@id='main']//button[contains(text(), 'New Walk-In')]",
        "duration": "//div[.//span[text()='Duration'] and contains(@class, 'slds-form-element') ]//select//option[@value='60']",
    },
    "contact": {
        "new_button": "//a[@title='New']//div[@title='New']",
        "first_name": "//input[contains(@class,'firstName')]",
        "last_name":  "//input[contains(@class,'lastName')]",
        "save_button": "//button[@title='Save']",
        "program_enrollment_new_button": "//span[text()='Program Enrollments']/following::a[@title='New']",
    },

    "new_account": "//span[@title='New Account']",
    "new_account_next_button": "//button[@class='slds-button slds-button--neutral uiButton--default uiButton--brand uiButton']//span[@class=' label bBody']",
    "new_account_name": "//input[@class='input uiInput uiInputText uiInput--default uiInput--input']",
    "new_account_save_button": "(//button[@class='slds-button slds-button--neutral uiButton--default uiButton--brand uiButton forceActionButton']//span[contains(text(), 'Save')])[2]",
    "academic_program": "//span[contains(text(), 'Academic Program')]",
    "new_program_enrollment_save_button": "//div[@class='modal-footer slds-modal__footer']//button[@title='Save']",
    "affiliated_accounts_count": "//span[text()='Affiliated Accounts']/following-sibling::span[contains(@title, '(1)')]",
    "program_enrollments_count": "//span[text()='Program Enrollments']/following-sibling::span[contains(@title, '(1)')]",
    "programenrollment_account": "//div[@class='autocompleteWrapper slds-grow']//input[@class=' default input uiInput uiInputTextForAutocomplete uiInput--default uiInput--input uiInput uiAutocomplete uiInput--default uiInput--lookup']",
    "list_of_departments": "//button[@class='slds-button slds-button--neutral uiButton--default uiButton--brand uiButton']//span[@class=' label bBody']",
    "tab": "//div[@class='uiTabBar']/ul[@class='tabs__nav']/li[contains(@class,'uiTabItem')]/a[@class='tabHeader']/span[contains(text(), '{}')]",
    "desktop_rendered": "css: div.desktop.container.oneOne.oneAppLayoutHost[data-aura-rendered-by]",
    "loading_box": "css: div.auraLoadingBox.oneLoadingBox",
    "spinner": "css: div.slds-spinner",
    "affiliations_tab": "//a[contains(text(),'Affiliations')]",
    "locating_delete_dropdown": '//tbody//a[text()= "{}"]/../../following-sibling::td/span//div/a/lightning-icon',
    "related_name": '//tbody/tr/td/a[contains(@class,"forceOutputLookup")]',
    "rel_loc_dd": "//tbody/tr[{}]/td[4]//lightning-primitive-icon",
    "delete_icon": '//span[contains(text() ,"{}")]/following::span[. = "{}"]/following-sibling::a/child::span[@class = "deleteIcon"]',
    "aff_list": '//div[@role="tablist"]/following::div[@class = "container forceRelatedListSingleContainer"][7]/article/div[@class="slds-card__body"]/div/div/div/div/div/div/div/table/tbody/tr/td[1]',
    "aff_status": '//table[contains(@class,"forceRecordLayout")]/tbody/tr[.//th/div/a[contains(@class,"textUnderline")]][.//td/a[@title="{}"]]/td[3]',
    "aff_id": '//table[contains(@class,"forceRecordLayout")]/tbody/tr[.//th/div/a[contains(@class,"textUnderline")]][.//td/a[@title="{}"]]/th//a',
    "click_aff_id": '//table[contains(@class,"forceRecordLayout")]/tbody/tr/th/div/a[text()="{}"]',
    "check_status": '//div[contains(@class, "forcePageBlockItem")][.//span[text()="{}"]]//following-sibling::div[.//span[contains(@class, "test-id__field-value")]]/span[.//span[text()="{}"]]',
    "check_field": '//div[contains(@class, "forcePageBlockItem")][.//span[text()="{}"]]//following-sibling::div[.//span[contains(@class, "test-id__field-value")]]/span/div//a[text()="{}"]',
    "account_list": '//tbody/tr/th[.//span[contains(@class, "slds-grid")]]/descendant::a[text()="{}"]',
    "dd_options": '//*[@id="p3"]/option[text()="{}"]',
    "related_list_items": '//div[@class = "forceRelatedListContainer"][.//a[contains(@class, "slds-card")]]//span[text() = "{}"]/ancestor::div[contains(@class, "slds-card")]/following-sibling::div[contains(@class, "slds-card")][.//div[contains(@class, "outputLookupContainer")]]//a[text()="{}"]',
    "header_field_value": '//li[contains(@class, "slds-page-header__detail")][.//p[contains(@class, "slds-text-heading--label")][@title="{}"]]//*[text()="{}"]',
    "header_datepicker": '//li[contains(@class, "slds-page-header__detail")][.//p[contains(@class, "slds-text-heading--label")][@title="{}"]]//*[@class="uiOutputDate"]',
    "affiliated_contacts": '//div[@class = "forceRelatedListContainer"][.//a[contains(@class, "slds-card")]]//span[text() = "{}"]/ancestor::div[contains(@class, "slds-card")]/following-sibling::div[contains(@class, "slds-card")]//tbody//td/span[text()="{}"]/../following-sibling::td/span[text()="{}"]',
    "detail_page": {
        "address": '//h3[contains(@class, "slds-section__title")][.//span[contains(text(),"Address")]]/../..//div[contains(@class, "test-id")]/span[text()= "{}"]/../following-sibling::div//a[@title = "{}"]/div[contains(@class, "slds")]',
        "field": '//h3[contains(@class, "slds-section__title")][.//span[text()="{}"]]/../..//div[contains(@class, "test-id")]/span[text()= "{}"]/../following-sibling::div//span[text()="{}"]',
        "verify_field_value": '//div[contains(@class, "forcePageBlockItem")]/div/div//span[text()="{}"]/../../div[2]/span/span[text() = "{}"]',
    },
    "manage_hh_page": {
        "address": '//div[contains(@class, "uiInput")][.//label[contains(@class, "uiLabel")]/span[text()="{}"]]/',
        "mhh_checkbox": '//*[@id="SortCanvas"]/li//a[text()="{}"]/ancestor::div[contains(@class, "slds-card__header")]/following-sibling::div[contains(@class,"slds-card__body")]//form//div//label/span[@id = "{}"]',
        "button": '//*[contains(@title, "{}")]',
        "mhh_button": '//span[text()="{}"]',
    },
    "modal": {
        "checkbox": '//div[contains(@class,"uiInputCheckbox")]/label/span[text()="{}"]/../following-sibling::input[@type="checkbox"]'
    },
    "opportunity": {
        "contact_role": '//div[contains(@class,"listItemBody")][./h3//a[text()="{}"]]//parent::h3/following-sibling::ul/li/div[contains(@class,"forceListRecordItem")]/div[@title="Role:"]/following-sibling::div/span[text()="{}"]'
    },
    "object": {
        "contact_role": '//tbody//a[text()= "{}"]/../../following-sibling::td/span/span[text() = "{}"]',
        "record": '//tbody//a[text()= "{}"]',
    },
}


extra_locators = {
    "related_list_items1": '//div[@class = "forceRelatedListContainer"][.//a[contains(@class, "slds-card")]]//span[text() = "Relationships"]/ancestor::div[contains(@class, "slds-card")]/following-sibling::div[contains(@class, "slds-card")]//tbody//td/span[text()="{}"]'
}
dnd = {""}
