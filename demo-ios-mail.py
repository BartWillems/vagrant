#!/usr/bin/python3

from selenium.common.exceptions import TimeoutException, WebDriverException
import time
from time import gmtime, strftime
import quamotion
import sys

if len(sys.argv) != 3:
	print('./demo-ios-mail.py -i [udid] [mail]')
	sys.exit()

udid = sys.argv[1]
mail = sys.argv[2]

print('Running tests on iOS device ' + udid + ' as for e-mail ' + mail)

# Launch a new session on an iOS device
driver = quamotion.device(udid)

try:
	# Allow for up to 1 minute for elements to become visible
	driver.implicitly_wait(60000)

	# Go to the home screen
	driver.home_screen()

	# Test e-mail integration
	timestamp = strftime("%Y-%m-%d %H:%M:%S", gmtime())
	driver.launch_app('com.mobileiron.ios.emailplus')

	time.sleep(5)
	driver.switch_to_alert().accept()

	driver.find_element_by_xpath('//XCUIElementTypeOther').send_keys('0000')
	driver.find_element_by_xpath('//XCUIElementTypeOther').send_keys('0000')
	driver.find_element_by_link_text('Done').click()

	time.sleep(5)
	driver.find_element_by_link_text('Compose').click()
	driver.find_element_by_xpath('//XCUIElementTypeTextField[1]').send_keys(mail + '\n\n')
	driver.find_elements_by_xpath('//XCUIElementTypeTextField')[1].send_keys(timestamp)
	driver.find_element_by_link_text('Send').click()

except WebDriverException as e:
	print('An error occurred')
	print(str(e))

finally:
	driver.quit()

