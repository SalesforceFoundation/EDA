"""Locators for winter '22"""

from locators_51 import *
import copy

eda_lex_locators = copy.deepcopy(eda_lex_locators)

"""Add the new locators specific for this release"""
new_eda_lex_locators = {
    "release_management": {
        "page_title": "//div[contains(@class, '{}')]"
    }
}
eda_lex_locators.update(new_eda_lex_locators)