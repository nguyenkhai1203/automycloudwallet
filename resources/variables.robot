*** Variables ***
# URLs
${TEMPMAIL_URL}                 https://tempmail.so/us/30-minutes-temporary-email
${MYCLOUDWALLET_URL}            https://mycloudwallet.com

# Timing
${PAGE_LOAD_TIME}               10s
${SHORT_WAIT}                   3s
${MEDIUM_WAIT}                  5s

# Chrome options (to avoid detection, if needed)
${user_data_dir}                --user-data-dir=/Users/nk/Library/Application Support/Google/Chrome/User Data
${profile_dir}                  --profile-directory=Profile 7
${CHROME_OPTIONS}               add_argument("--disable-blink-features=AutomationControlled");add_argument("--disable-dev-shm-usage");add_argument("--no-sandbox");add_argument("--disable-infobars");add_argument("--disable-browser-side-navigation");add_argument("--disable-gpu");add_experimental_option("excludeSwitches", ["enable-automation"]);add_experimental_option("useAutomationExtension", False)

# Credentials for sign-in (replace with actual values)
${SIGNIN_EMAIL}                 khai.nguyen@opskins.com
${SIGNIN_PASSWORD}              qwertyuiO.1
${SIGNUP_PASSWORD}              qwertyuiO.1

# Locators for tempmail.so
${TEMP_EMAIL_LOCATOR}           css=span.text-base.truncate
${EMAIL_LIST}                   css=.email-list .email-item
${ACTIVATION_LINK}              xpath=//a[contains(text(), 'Verify') or contains(text(), 'Activate') or contains(text(), 'activate')]
${ACTIVATION_CODE_SELECTOR}     xpath=//p[contains(@style, 'letter-spacing') and contains(@style, 'font-weight: bold')]
${VERIFICATION_EMAIL}    xpath=//div[contains(@class, 'order-3') and contains(text(), '[Cloud Wallet] Email verification')]

# Locators for mycloudwallet.com
${SIGN_UP_BUTTON}               xpath=//button//span[text()='Create Account']
${LOGIN_BUTTON}                 xpath=//button//span[text()='Login']
${EMAIL_FIELD}                  name=email
${EMAIL_INPUT}                  css=div.new-sign-up-div-7 input[inputmode='email']
${PASSWORD_FIELD}               name=password
${PASSWORD_INPUT}               xpath=(//div[@class='new-sign-up-div-7']//input[@name='password'])[1]
${CONFIRM_PASSWORD_FIELD}       name=confirm_password
${CONFIRM_PASSWORD_INPUT}       xpath=(//div[@class='new-sign-up-div-7']//input[@name='password'])[2]
${SIGN_UP_SUBMIT}               xpath=//button[text()='Sign Up']
${SIGN_UP_SUBMIT_BUTTON}        xpath=//button[@type='button' and @class='ant-btn ant-btn-default']//span[text()='Create Account']
${CONTINUE_BUTTON}              xpath=//button//span[text()='Continue']
${SIGN_IN_BUTTON}               xpath=//button//span[text()='Sign In']
${CONFIRM_MODAL_BUTTON}         css=body > div:nth-child(8) > div > div.ant-modal-wrap > div > div.ant-modal-content > div > div > div.content > div.sc-vuxumm-0.EwLhs > button

# Turnstile Captcha
${TURNSTILE_IFRAME}             iframe[src*='turnstile'], iframe[name^='cf-chl-widget']
${TURNSTILE_CHECKBOX}           css=.ctp-checkbox-label, css=div.checkbox, xpath://div[contains(@class,'checkbox')]
${SUCCESS_POPUP}                id=success-popup
${LOGIN_SUCCESS_ELEMENT}        xpath=//a[text()='Logout']
