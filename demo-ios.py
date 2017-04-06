#!/usr/bin/python3

from selenium.common.exceptions import TimeoutException, WebDriverException
import time
from time import gmtime, strftime
import quamotion
import sys

if len(sys.argv) != 4:
	print('./demo-ios.py -i [udid] [user] [password]')
	sys.exit()

udid = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]

print('Running tests on iOS device ' + udid + ' as user ' + user)

# Launch a new session on an iOS device
driver = quamotion.device(udid)

try:
	apps = driver.get_installed_apps()

	for app in apps['value']:
		if app['AppId'] == 'com.mobileiron.phoneatwork':
			print('Uninstalling Mobile@Work')
			driver.uninstall_app('com.mobileiron.phoneatwork')

	# driver.kill_app('AppStore')

	# Allow for up to 1 minute for elements to become visible
	driver.implicitly_wait(60000)

	# Go to the home screen
	driver.home_screen()

	# Open app store and search for MobileIron Mobile@Work
	print('Opening the App Store')
	driver.find_element_by_link_text('App Store').click()

	time.sleep(2)
	print('Searching for MobileIron Mobile@Work')
	driver.find_element_by_link_text('Search').click()
	driver.find_element_by_xpath('//XCUIElementTypeSearchField').click()
	driver.find_element_by_xpath('//XCUIElementTypeSearchField').clear()
	driver.find_element_by_xpath('//XCUIElementTypeSearchField').send_keys('MobileIron Mobile@Work\n')

	# Download MobileIron Mobile@Work
	time.sleep(5)
	print('Clicking on the Purchase button')
	driver.find_element_by_xpath('//XCUIElementTypeButton[@name="PurchaseButton"]').click()

	time.sleep(15)
	print('Clicking on the OPEN button')
	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="OPEN"]').click()

	time.sleep(5)
	driver.switch_to_alert().accept()

	print('Setting the User Name')
	time.sleep(2)
	driver.find_element_by_xpath('//XCUIElementTypeTextField[@label="User Name"]').click()
	driver.find_element_by_xpath('//XCUIElementTypeTextField[@label="User Name"]').send_keys(user + '\n')

	print('Setting the Server')
	driver.find_element_by_xpath('//XCUIElementTypeTextField[@label="Server"]').click()
	driver.find_element_by_xpath('//XCUIElementTypeTextField[@label="Server"]').send_keys('emm.mob.co\n')

	#print('Accepting the Open this page in "MobileIron"? alert')
	#driver.switch_to_alert().accept()

	time.sleep(2)
	print('Enting the password')
	driver.find_element_by_xpath('//XCUIElementTypeSecureTextField[@label="Password"]').click()
	driver.find_element_by_xpath('//XCUIElementTypeSecureTextField[@label="Password"]').send_keys(password + '\n')

	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Continue"]').click()

	time.sleep(5)
	print('Accepting the Terms of Service')
	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Accept"]').click()

	# Sometimes there are two alerts, somtimes one - need to confirm there.
	time.sleep(5)
	print('Accepting the "MobileIron" to access your location even when you are not using the app?')
	driver.switch_to_alert().accept()

	time.sleep(2)
	print('Accepting Updating Configuration alert')
	try:
		driver.switch_to_alert().accept()
	except:
		pass

	print('Installing the Profile')
	# First install button in the upper right corner of the page
	print('1/3')
	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Install"]').click()

	print('Entering passcode')
	driver.find_element_by_xpath('//XCUIElementTypeOther').send_keys('000000')

	# Second confirmation at the bottom of the page
	time.sleep(3)
	print('2/3')
	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Install"]').click()

	# Root certificate
	time.sleep(3)
	print('3/3')
	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Install"]').click()

	print('Trusting the remote management')
	driver.switch_to_alert().accept()

	# print('Clicking Done')
	time.sleep(2)
	# driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Done"]').click()

	time.sleep(30)
	print('Accepting app installation for e-mail')
	driver.switch_to_alert().accept()

	print('Waiting for the e-mail client to install')
	time.sleep(30)

except WebDriverException as e:
	print('An error occurred')
	print(str(e))

finally:
	driver.quit()

