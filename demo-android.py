#!/usr/bin/python3
import quamotion
import sys

if len(sys.argv) != 4:
	print('./demo-ios.py [udid] [user] [password]')
	sys.exit()

udid = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]

print('Running tests on Android device ' + udid + ' as user ' + user)

# Launch a new session on an iOS device
driver = quamotion.device(udid)

try:
	print('Created test automation session')

	# driver.find_element_by_link_text('Play Store').click()
	driver.find_element_by_id('com.android.vending:id/search_box_idle_text').click()
	driver.find_element_by_id('com.android.vending:id/search_box_text_input').clear()
	driver.find_element_by_id('com.android.vending:id/search_box_text_input').send_keys('Mobile@Work\\n')
	driver.find_element_by_xpath("//android.widget.TextView[@text='Mobile@Work']").click()
	driver.find_element_by_id('com.android.vending:id/buy_button').click()
	driver.find_element_by_id('com.android.vending:id/launch_button').click()
	driver.find_element_by_xpath("//android.widget.Button[@text='OK']").click()
	driver.find_element_by_id('com.android.packageinstaller:id/permission_allow_button').click()
	driver.find_element_by_id('com.mobileiron:id/button_register_with_url').click()
	driver.find_element_by_id('com.mobileiron:id/geos_edit').click()
	driver.find_element_by_id('com.mobileiron:id/geos_edit').clear()
	driver.find_element_by_id('com.mobileiron:id/geos_edit').send_keys('emm.mob.co\\n')
	driver.find_element_by_id('com.mobileiron:id/button_geos_next').click()
	driver.find_element_by_id('com.mobileiron:id/button_privacy_continue').click()
	driver.find_element_by_id('com.mobileiron:id/user_edit').click()
	driver.find_element_by_id('com.mobileiron:id/user_edit').clear()
	driver.find_element_by_id('com.mobileiron:id/user_edit').send_keys(user + '\\n')
	driver.find_element_by_id('com.mobileiron:id/password_edit').click()
	driver.find_element_by_id('com.mobileiron:id/password_edit').clear()
	driver.find_element_by_id('com.mobileiron:id/password_edit').send_keys(password + '\\n')
except WebDriverException as e:
	print('An error occurred')
	print(str(e))

finally:
	driver.quit()
