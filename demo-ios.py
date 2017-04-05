#!/usr/bin/python3

import quamotion

# Launch a new session on an iOS device
driver = quamotion.device('72157b76f677f22c98864d62307fdff9d56fa62a')

# Allow for up to 1 minute for elements to become visible
driver.implicitly_wait(60000)

# Go to the home screen
driver.home_screen()

# Open app store and search for MobileIron Mobile@Work
driver.find_element_by_link_text('App Store').click()
driver.find_element_by_link_text('Search').click()
driver.find_element_by_xpath('//XCUIElementTypeSearchField').click()
driver.find_element_by_xpath('//XCUIElementTypeSearchField').send_keys('MobileIron Mobile@Work\n')

# Download MobileIron Mobile@Work
driver.find_element_by_xpath('//XCUIElementTypeButton[@name="PurchaseButton"]').click()
driver.find_element_by_xpath('//XCUIElementTypeButton[@label="OPEN"]').click()

