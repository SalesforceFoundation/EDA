""" Locators for Winter '22 """

from locators_54 import *
import copy
eda_lex_locators = copy.deepcopy(eda_lex_locators)
#Override the locator selector value
eda_lex_locators['eda_settings_new']['dropdown_input']="//label[text()='{}']/../descendant::input[@role='combobox']"
