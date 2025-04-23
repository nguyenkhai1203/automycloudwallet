*** Variables ***
# URLs
${TEMPMAIL_URL}          https://tempmail.so
${MYCLOUDWALLET_URL}     https://mycloudwallet.com

# Timing
${PAGE_LOAD_TIME}        10s

# Chrome options (to avoid detection, if needed)
${user_data_dir}   --user-data-dir=/Users/nk/Library/Application Support/Google/Chrome/User Data
${profile_dir}     --profile-directory=Profile 7
${CHROME_OPTIONS}    add_argument("--disable-blink-features=AutomationControlled");add_argument("--disable-dev-shm-usage");add_argument("--no-sandbox");add_argument("--disable-infobars");add_argument("--disable-browser-side-navigation");add_argument("--disable-gpu");add_experimental_option("excludeSwitches", ["enable-automation"]);add_experimental_option("useAutomationExtension", False)

# Credentials for sign-in (replace with actual values)
${SIGNIN_EMAIL}          your_email@example.com
${SIGNIN_PASSWORD}       your_password

# Locators for tempmail.co (adjust based on actual page inspection)
${COPY_BUTTON}        xpath=//div[contains(text(), 'Copy Address')]
${TEMP_EMAIL_LOCATOR}    css:.text-base.truncate  # Updated to match the email element


${TEMP_EMAIL_LOCATOR}    css=span.text-base.truncate
${EMAIL_LIST}            css:.email-list .email-item
${ACTIVATION_LINK}       xpath=//a[text()='Activate Account']

# Locators for mycloudwallet.com (adjust based on actual page inspection)
${SIGN_UP_BUTTON}        xpath=//a[text()='Sign Up']
${LOGIN_BUTTON}          xpath=//a[text()='Login']
${EMAIL_FIELD}           name=email
${PASSWORD_FIELD}        name=password
${CONFIRM_PASSWORD_FIELD}    name=confirm_password
${SIGN_UP_SUBMIT}        xpath=//button[text()='Sign Up']
${SIGN_IN_BUTTON}        xpath=//button[text()='Sign In']
${CAPTCHA_CHECKBOX}      xpath=//input[@type='checkbox']
${SUCCESS_POPUP}         id=success-popup
${LOGIN_SUCCESS_ELEMENT}    xpath=//a[text()='Logout']