#!/usr/bin/python3

from selenium.common.exceptions import TimeoutException, WebDriverException
import time
from time import gmtime, strftime
import quamotion
import sys
import requests

if len(sys.argv) != 4:
	print('./demo-ios.py [udid] [user] [password]')
	sys.exit()

udid = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]
core_fqdn = sys.argv[4]

print('Running tests on iOS device ' + udid + ' as user ' + user)

try:
	print('Retiring device from MDM')

	devices = requests.get('https://{}/api/v1/dm/devices'.format(core_fqdn), auth=(user, password)).json()

	for device in devices['devices']['device']:
		if device['principal'] == user:
			details = device['details']
			detail = details[0]
			entries = detail['entry']

			for entry in entries:
				if entry['key'] == 'iPhone UDID':
					print(entry)
					mdm_ios_udid = entry['value']
					mdm_uuid = device['uuid']

					print('Retiring iOS device with iOS UDID ' + mdm_ios_udid + ' and MDM UUID ' + mdm_uuid)

					r_url = ('https://{}/api/v1/dm/devices/retire/{}?Reason={}'.format(core_fqdn, mdm_uuid, 'Monitoring script'))
					requests.put(r_url, auth=(user, password))

except Exception as e:
	print(str(e))
	print('Failed to retire the device. If the device was not previously registered with MDM, you can ignore this.')
	pass

# Launch a new session on an iOS device
driver = quamotion.device(udid)

try:
	print('Created test automation session')
	apps = driver.get_installed_apps()

	for app in apps['value']:
		if app['AppId'] == 'com.mobileiron.phoneatwork':
			print('Uninstalling Mobile@Work')
			driver.uninstall_app('com.mobileiron.phoneatwork')

	# Killing the App Store
	processes = driver.get_running_processes()

	for process in processes['value']:
		if process['name'] == 'AppStore':
			print('Killing the App Store')
			driver.kill_app('com.apple.AppStore')

	# Allow for up to 1 minute for elements to become visible
	driver.implicitly_wait(60)

	# Go to the home screen
	driver.home_screen()

	# Open app store and search for MobileIron Mobile@Work
	print('Opening the App Store')
	driver.launch_app('com.apple.AppStore')

	print('Searching for MobileIron Mobile@Work')
	driver.find_element_by_link_text('Search').click()
	driver.find_element_by_xpath('//XCUIElementTypeSearchField').click()
	driver.find_element_by_xpath('//XCUIElementTypeSearchField').clear()
	driver.find_element_by_xpath('//XCUIElementTypeSearchField').send_keys('MobileIron Mobile@Work\n')

	# Download MobileIron Mobile@Work
	print('Clicking on the Purchase button')
	driver.find_element_by_xpath('//XCUIElementTypeButton[@name="PurchaseButton"]').click()

	print('Clicking on the OPEN button')
	driver.implicitly_wait(120)
	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="OPEN"]').click()
	driver.implicitly_wait(60)

	# Accept the 'MobileIron would like to send you notifications' alert
	print('Accepting the "MobileIron Would Like to Send You Notifications" alert')

	# Implicit wait for alerts is comming (FB WDA PR 410) soon!
	time.sleep(1)
	driver.switch_to_alert().accept()

	print('Setting the User Name')
	driver.find_element_by_xpath('//XCUIElementTypeTextField[@label="User Name"]').click()
	driver.find_element_by_xpath('//XCUIElementTypeTextField[@label="User Name"]').send_keys(user + '\n')

	print('Setting the Server')
	driver.find_element_by_xpath('//XCUIElementTypeTextField[@label="Server"]').click()
	driver.find_element_by_xpath('//XCUIElementTypeTextField[@label="Server"]').send_keys(core_fqdn + '\n')

	try:
		driver.implicitly_wait(10)
		print('Accepting the Open this page in "MobileIron"? alert')
		driver.switch_to_alert().accept()
	except:
		print('Could not click the Open this page in "MobileIron"? alert. Continuing')
		pass

	driver.implicitly_wait(60)

	print('Enting the password')
	driver.find_element_by_xpath('//XCUIElementTypeSecureTextField[@label="Password"]').click()
	driver.find_element_by_xpath('//XCUIElementTypeSecureTextField[@label="Password"]').send_keys(password + '\n')

	# There seems to be another 'continue' button which would bring us back to the app store - not where
	# we actually want to be
	time.sleep(1)
	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Continue"]').click()

	# Exit here if you don't want to actually have the device be managed by Mobile@Work
	# Useful when doing demos :)
	#
	# If at this point in time, you have a Mobile@Work screen with a 'Log In' button, this
	# means the device is still somehow managed and you'll need to undo that first.
	# sys.exit(0)

	print('Accepting the Terms of Service')
	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Accept"]').click()

	# Sometimes there are two alerts, somtimes one - need to confirm this
	print('Accepting the "MobileIron" to access your location even when you are not using the app?')
	driver.switch_to_alert().accept()

	print('Accepting Updating Configuration alert')
	try:
		driver.implicitly_wait(10)
		driver.switch_to_alert().accept()
	except:
		pass

	driver.implicitly_wait(60)

	print('Installing the Profile')
	# First install button in the upper right corner of the page
	print('1/3')
	time.sleep(1)
	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Install"]').click()

	print('Entering passcode')
	driver.find_element_by_xpath('//XCUIElementTypeOther').send_keys('000000')

	# Second confirmation at the bottom of the page
	print('2/3')
	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Install"]').click()

	# Root certificate
	# Because we're clicking twice on a button with the same XPath expression (but it is a different button),
	# we need an explicit sleep here
	time.sleep(3)
	print('3/3')
	driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Install"]').click()

	print('Trusting the remote management')
	driver.switch_to_alert().accept()

	# print('Clicking Done')
	time.sleep(2)
	# driver.find_element_by_xpath('//XCUIElementTypeButton[@label="Done"]').click()

	print('Accepting app installation for e-mail')
	driver.switch_to_alert().accept()

	print('Accepting app installation for Enterprise Files')
	driver.switch_to_alert().accept()

except WebDriverException as e:
	print('An error occurred')
	print(str(e))

finally:
	driver.quit()
